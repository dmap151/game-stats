import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/game.dart';
import 'models/match_record.dart';
import 'models/player.dart';

class DatabaseService {
  late Isar isar;
  String? _currentUserId;
  final Future<Directory> Function()? baseDirProvider;

  DatabaseService({this.baseDirProvider});

  String? get currentUserId => _currentUserId;

  /// Initializes the Isar database for a specific user, or guest if userId is null.
  Future<void> init({String? userId}) async {
    _currentUserId = userId;
    final baseDir = baseDirProvider != null
        ? await baseDirProvider!()
        : await getApplicationDocumentsDirectory();
    final String instanceName = userId != null
        ? 'user_${userId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')}'
        : 'guest';

    // If an instance is already open with this name, reuse it
    final existingInstance = Isar.getInstance(instanceName);
    if (existingInstance != null && existingInstance.isOpen) {
      isar = existingInstance;
      return;
    }

    // Directory for this user
    final String targetPath = userId != null
        ? '${baseDir.path}/users/$userId'
        : '${baseDir.path}/guest';

    final targetDir = Directory(targetPath);
    if (!targetDir.existsSync()) {
      await targetDir.create(recursive: true);
    }

    isar = await Isar.open(
      [GameSchema, MatchRecordSchema, PlayerSchema],
      directory: targetPath,
      name: instanceName,
    );

    // Always run legacy migration and photo recovery if legacy data exists
    await recoverLostMatchImagesAndData();
  }

  /// Recovers lost match images, game thumbnails, and player avatars from legacy
  /// databases (e.g. default.isar, guest/guest.isar) or from local device storage.
  /// Also migrates any legacy records that were not previously imported.
  Future<int> recoverLostMatchImagesAndData() async {
    final baseDir = baseDirProvider != null
        ? await baseDirProvider!()
        : await getApplicationDocumentsDirectory();

    int recoveredCount = 0;

    // List of candidate legacy database directories to inspect
    final candidateDirs = <String>[
      baseDir.path, // default.isar (root instance)
    ];
    if (_currentUserId != null) {
      candidateDirs.add('${baseDir.path}/guest'); // guest.isar
    }

    for (final dirPath in candidateDirs) {
      final isRoot = dirPath == baseDir.path;
      final instanceName = isRoot ? 'default' : 'guest';
      final isarFile = File('$dirPath/$instanceName.isar');
      if (!isarFile.existsSync()) continue;

      // Don't inspect self if current instance is guest and dir is guest
      if (_currentUserId == null && !isRoot) continue;

      try {
        final legacyInstance = Isar.getInstance(instanceName) ??
            await Isar.open(
              [GameSchema, MatchRecordSchema, PlayerSchema],
              directory: dirPath,
              name: instanceName,
            );

        final legacyGames = await legacyInstance.games.where().findAll();
        final legacyPlayers = await legacyInstance.players.where().findAll();
        final legacyMatches = await legacyInstance.matchRecords.where().findAll();

        // 1. Ensure game links are loaded on legacy matches
        for (final m in legacyMatches) {
          await m.game.load();
        }

        // 2. Sync Games
        final currentGames = await isar.games.where().findAll();
        final gameByName = <String, Game>{
          for (final g in currentGames) g.name.toLowerCase(): g,
        };

        for (final lg in legacyGames) {
          final key = lg.name.toLowerCase();
          final existing = gameByName[key];
          if (existing == null) {
            final newGame = Game()
              ..name = lg.name
              ..imagePath = lg.imagePath;
            final id = await isar.writeTxn(() => isar.games.put(newGame));
            newGame.id = id;
            gameByName[key] = newGame;
          } else if ((existing.imagePath == null || existing.imagePath!.isEmpty) &&
              lg.imagePath != null &&
              lg.imagePath!.isNotEmpty) {
            existing.imagePath = lg.imagePath;
            await isar.writeTxn(() => isar.games.put(existing));
          }
        }

        // 3. Sync Players
        final currentPlayers = await isar.players.where().findAll();
        final playerByName = <String, Player>{
          for (final p in currentPlayers) p.name.toLowerCase(): p,
        };

        for (final lp in legacyPlayers) {
          final key = lp.name.toLowerCase();
          final existing = playerByName[key];
          if (existing == null) {
            final newPlayer = Player()
              ..name = lp.name
              ..imagePath = lp.imagePath
              ..isMe = lp.isMe
              ..linkedUserId = lp.linkedUserId
              ..friendCode = lp.friendCode;
            final id = await isar.writeTxn(() => isar.players.put(newPlayer));
            newPlayer.id = id;
            playerByName[key] = newPlayer;
          } else if ((existing.imagePath == null || existing.imagePath!.isEmpty) &&
              lp.imagePath != null &&
              lp.imagePath!.isNotEmpty) {
            existing.imagePath = lp.imagePath;
            await isar.writeTxn(() => isar.players.put(existing));
          }
        }

        // 4. Recover & Merge Matches
        final currentMatches = await getAllMatchRecords();

        for (final lm in legacyMatches) {
          final lmGameName = lm.game.value?.name;

          // Find candidate in current matches
          MatchRecord? matchingCurrent;
          for (final cm in currentMatches) {
            final diffMinutes = (cm.date.difference(lm.date)).abs().inMinutes;
            if (diffMinutes > 180) continue;

            final sameGame = lmGameName != null &&
                cm.game.value?.name != null &&
                cm.game.value!.name.toLowerCase() == lmGameName.toLowerCase();

            final s1 = cm.playerScores.map((s) => '${s.playerName}:${s.score}:${s.placement}').toList()..sort();
            final s2 = lm.playerScores.map((s) => '${s.playerName}:${s.score}:${s.placement}').toList()..sort();
            final scoresMatch = s1.isNotEmpty && s1.join(',') == s2.join(',');

            if (sameGame || scoresMatch) {
              matchingCurrent = cm;
              break;
            }
          }

          if (matchingCurrent != null) {
            bool updated = false;

            // Merge images
            final allImages = <String>{};
            if (matchingCurrent.imagePath != null && matchingCurrent.imagePath!.isNotEmpty) {
              allImages.add(matchingCurrent.imagePath!);
            }
            for (final img in matchingCurrent.imagePaths) {
              if (img.isNotEmpty) allImages.add(img);
            }
            if (lm.imagePath != null && lm.imagePath!.isNotEmpty) {
              allImages.add(lm.imagePath!);
            }
            for (final img in lm.imagePaths) {
              if (img.isNotEmpty) allImages.add(img);
            }

            if (allImages.isNotEmpty) {
              final imgList = allImages.toList();
              if (matchingCurrent.imagePath != imgList.first) {
                matchingCurrent.imagePath = imgList.first;
                updated = true;
              }
              final newSub = imgList.length > 1 ? imgList.sublist(1) : <String>[];
              if (matchingCurrent.imagePaths.length != newSub.length) {
                matchingCurrent.imagePaths = newSub;
                updated = true;
              }
            }

            // Restore game link if missing
            if (matchingCurrent.game.value == null && lmGameName != null) {
              final g = gameByName[lmGameName.toLowerCase()];
              if (g != null) {
                matchingCurrent.game.value = g;
                updated = true;
              }
            }

            // Restore location if missing
            if (matchingCurrent.latitude == null && lm.latitude != null) {
              matchingCurrent.latitude = lm.latitude;
              matchingCurrent.longitude = lm.longitude;
              updated = true;
            }

            if (updated) {
              await isar.writeTxn(() async {
                await isar.matchRecords.put(matchingCurrent!);
                if (matchingCurrent.game.value != null) {
                  await matchingCurrent.game.save();
                }
              });
              recoveredCount++;
            }
          } else {
            // Completely missing match from legacy: insert into current DB
            Game? matchingGame;
            if (lmGameName != null) {
              matchingGame = gameByName[lmGameName.toLowerCase()];
            }

            final newMatch = MatchRecord()
              ..date = lm.date
              ..numberOfPlayers = lm.numberOfPlayers
              ..imagePath = lm.imagePath
              ..imagePaths = List.from(lm.imagePaths)
              ..latitude = lm.latitude
              ..longitude = lm.longitude
              ..playerScores = lm.playerScores
                  .map((ps) => PlayerScore()
                    ..playerId = ps.playerId
                    ..playerName = ps.playerName
                    ..placement = ps.placement
                    ..score = ps.score
                    ..linkedUserId = ps.linkedUserId)
                  .toList();

            newMatch.game.value = matchingGame;
            await isar.writeTxn(() async {
              await isar.matchRecords.put(newMatch);
              if (newMatch.game.value != null) {
                await newMatch.game.save();
              }
            });
            currentMatches.add(newMatch);
            recoveredCount++;
          }
        }
      } catch (e) {
        // Non-fatal legacy recovery
      }
    }

    // 5. Disk Photo Fallback: scan documents directory for image files
    try {
      final docFiles = Directory(baseDir.path)
          .listSync()
          .whereType<File>()
          .where((f) {
            final ext = f.path.toLowerCase();
            return ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png');
          })
          .toList();

      if (docFiles.isNotEmpty) {
        final matches = await getAllMatchRecords();
        for (final m in matches) {
          if ((m.imagePath != null && m.imagePath!.isNotEmpty) || m.imagePaths.isNotEmpty) {
            continue;
          }

          final mMillis = m.date.millisecondsSinceEpoch;
          File? bestFile;
          int smallestDiff = 24 * 60 * 60 * 1000; // max 24 hours

          for (final file in docFiles) {
            final name = file.uri.pathSegments.last;
            final digits = name.replaceAll(RegExp(r'[^0-9]'), '');
            int? fileTime;
            if (digits.length >= 10) {
              fileTime = int.tryParse(digits);
            }
            fileTime ??= file.lastModifiedSync().millisecondsSinceEpoch;

            final diff = (fileTime - mMillis).abs();
            if (diff < smallestDiff) {
              smallestDiff = diff;
              bestFile = file;
            }
          }

          if (bestFile != null && smallestDiff <= 12 * 60 * 60 * 1000) {
            m.imagePath = bestFile.path;
            await isar.writeTxn(() async {
              await isar.matchRecords.put(m);
              if (m.game.value != null) {
                await m.game.save();
              }
            });
            recoveredCount++;
          }
        }
      }
    } catch (_) {}

    return recoveredCount;
  }

  /// Switches the database to the specified user (or guest if null).
  Future<void> switchUser(String? newUserId) async {
    if (_currentUserId == newUserId && isar.isOpen) {
      return;
    }
    await init(userId: newUserId);
    await deduplicateMatchRecords();
  }

  // --- Player Methods ---

  /// Saves a new player to the database or updates an existing one if the ID is set.
  /// Returns the ID of the saved player.
  Future<int> savePlayer(Player player) async {
    return await isar.writeTxn(() async {
      return await isar.players.put(player);
    });
  }

  /// Updates a player's profile (name and image).
  /// If the name is changed, it intelligently updates the embedded player names
  /// in all historical `MatchRecord`s to ensure consistency.
  Future<void> updatePlayerProfile(Player player, String newName, String? newImagePath) async {
    await isar.writeTxn(() async {
      final oldName = player.name;
      
      // 1. Update the player object
      player.name = newName;
      player.imagePath = newImagePath;
      await isar.players.put(player);

      // 2. Find all matches where this player was involved to update their embedded name
      if (oldName != newName) {
        final allMatches = await isar.matchRecords.where().findAll();
        for (var match in allMatches) {
          bool needsUpdate = false;
          
          final updatedScores = match.playerScores.map((score) {
            if (score.playerId == player.id && score.playerName != newName) {
              score.playerName = newName;
              needsUpdate = true;
            }
            return score;
          }).toList();

          if (needsUpdate) {
            match.playerScores = updatedScores;
            await isar.matchRecords.put(match);
          }
        }
      }
    });
  }

  /// Retrieves a list of all players currently in the database.
  Future<List<Player>> getAllPlayers() async {
    return await isar.players.where().findAll();
  }

  /// Returns a stream that emits a new list of players whenever the players collection changes.
  /// Useful for reactive UI updates via Riverpod.
  Stream<List<Player>> listenToPlayers() {
    return isar.players.where().watch(fireImmediately: true);
  }

  Future<Player?> getPlayerByName(String name) async {
    return await isar.players.where().nameEqualTo(name).findFirst();
  }
  
  Future<bool> deletePlayer(int id) async {
    return await isar.writeTxn(() async {
      return await isar.players.delete(id);
    });
  }

  /// Returns the player designated as "Me" (current device user), if set.
  Future<Player?> getMyPlayer({String? currentUserId}) async {
    final me = await isar.players.filter().isMeEqualTo(true).findFirst();
    if (me != null) return me;
    if (currentUserId != null && currentUserId.isNotEmpty) {
      return await isar.players.filter().linkedUserIdEqualTo(currentUserId).findFirst();
    }
    return null;
  }

  /// Returns a stream that emits the player designated as "Me", or null.
  Stream<Player?> listenToMyPlayer({String? currentUserId}) {
    return isar.players
        .where()
        .watch(fireImmediately: true)
        .map((players) {
          final me = players.where((p) => p.isMe).firstOrNull;
          if (me != null) return me;
          if (currentUserId != null && currentUserId.isNotEmpty) {
            return players.where((p) => p.linkedUserId == currentUserId).firstOrNull;
          }
          return null;
        });
  }

  /// Sets exactly one player as "Me" and unsets isMe on all other players.
  /// Also optionally associates the player with the Supabase auth user ID and friend code.
  Future<void> setMyPlayer(int playerId, {String? linkedUserId, String? friendCode}) async {
    await isar.writeTxn(() async {
      final allPlayers = await isar.players.where().findAll();
      for (final p in allPlayers) {
        final shouldBeMe = p.id == playerId;
        bool changed = false;
        if (p.isMe != shouldBeMe) {
          p.isMe = shouldBeMe;
          changed = true;
        }
        if (shouldBeMe) {
          if (linkedUserId != null && p.linkedUserId != linkedUserId) {
            p.linkedUserId = linkedUserId;
            changed = true;
          }
          if (friendCode != null && p.friendCode != friendCode) {
            p.friendCode = friendCode;
            changed = true;
          }
        }
        if (changed) {
          await isar.players.put(p);
        }
      }
    });
  }

  /// Links a local player to a Supabase friend account by user ID and friend code.
  Future<void> linkPlayerToFriend(int playerId, String friendUserId, String friendCode) async {
    final player = await isar.players.get(playerId);
    if (player != null) {
      player.linkedUserId = friendUserId;
      player.friendCode = friendCode;
      await isar.writeTxn(() async {
        await isar.players.put(player);
      });
    }
  }

  /// Unlinks a player from any friend account.
  Future<void> unlinkPlayer(int playerId) async {
    final player = await isar.players.get(playerId);
    if (player != null) {
      player.linkedUserId = null;
      player.friendCode = null;
      await isar.writeTxn(() async {
        await isar.players.put(player);
      });
    }
  }

  // --- Game Methods ---

  Future<int> saveGame(Game game) async {
    return await isar.writeTxn(() async {
      return await isar.games.put(game);
    });
  }

  Future<List<Game>> getAllGames() async {
    return await isar.games.where().findAll();
  }

  Future<Game?> getGameByName(String name) async {
    return await isar.games.where().nameEqualTo(name).findFirst();
  }

  Future<void> updateGameImage(Game game, String? newImagePath) async {
    await isar.writeTxn(() async {
      game.imagePath = newImagePath;
      await isar.games.put(game);
    });
  }

  Stream<List<Game>> listenToGames() {
    return isar.games.where().watch(fireImmediately: true);
  }

  // --- MatchRecord Methods ---

  /// Saves a match record to the database and ensures the linked game is saved.
  /// Returns the ID of the saved match record.
  Future<int> saveMatchRecord(MatchRecord record) async {
    return await isar.writeTxn(() async {
      final id = await isar.matchRecords.put(record);
      await record.game.save();
      return id;
    });
  }

  Future<List<MatchRecord>> getAllMatchRecords() async {
    final records = await isar.matchRecords.where().findAll();
    for (final r in records) {
      await r.game.load();
    }
    return records;
  }

  Future<List<MatchRecord>> getMatchRecordsForGame(int gameId) async {
    return await isar.matchRecords.filter().game((q) => q.idEqualTo(gameId)).findAll();
  }

  Stream<List<MatchRecord>> listenToMatchRecords() {
    return isar.matchRecords.where().watch(fireImmediately: true);
  }
  
  Future<bool> deleteMatchRecord(int id) async {
    return await isar.writeTxn(() async {
      return await isar.matchRecords.delete(id);
    });
  }

  /// Finds and removes duplicate match records created by sync or multiple imports.
  /// Matches are considered duplicates if they have the same game name,
  /// identical player scores, and occurred within 3 hours (timezone shifts).
  /// Any photos or metadata on the duplicate are safely preserved in the kept record.
  Future<int> deduplicateMatchRecords() async {
    final matches = await getAllMatchRecords();
    final toDelete = <int>[];
    final kept = <MatchRecord>[];
    final updatedKept = <MatchRecord>[];

    for (final match in matches) {
      bool isDuplicate = false;
      for (final k in kept) {
        final sameGame = k.game.value?.name != null &&
            match.game.value?.name != null &&
            k.game.value!.name.toLowerCase() == match.game.value!.name.toLowerCase();
        final dateDiffMinutes = (k.date.difference(match.date)).abs().inMinutes;
        final sameTime = dateDiffMinutes <= 180;

        if (sameGame && sameTime) {
          final s1 = k.playerScores.map((s) => '${s.playerName}:${s.score}:${s.placement}').toList()..sort();
          final s2 = match.playerScores.map((s) => '${s.playerName}:${s.score}:${s.placement}').toList()..sort();
          if (s1.join(',') == s2.join(',')) {
            isDuplicate = true;

            // Merge photos and metadata into k before discarding match
            bool kModified = false;
            final allImages = <String>{};
            if (k.imagePath != null && k.imagePath!.isNotEmpty) allImages.add(k.imagePath!);
            for (final p in k.imagePaths) {
              if (p.isNotEmpty) allImages.add(p);
            }
            if (match.imagePath != null && match.imagePath!.isNotEmpty) allImages.add(match.imagePath!);
            for (final p in match.imagePaths) {
              if (p.isNotEmpty) allImages.add(p);
            }

            if (allImages.isNotEmpty) {
              final imgList = allImages.toList();
              if (k.imagePath != imgList.first) {
                k.imagePath = imgList.first;
                kModified = true;
              }
              final sub = imgList.length > 1 ? imgList.sublist(1) : <String>[];
              if (k.imagePaths.length != sub.length) {
                k.imagePaths = sub;
                kModified = true;
              }
            }

            if (k.game.value == null && match.game.value != null) {
              k.game.value = match.game.value;
              kModified = true;
            }

            if (k.latitude == null && match.latitude != null) {
              k.latitude = match.latitude;
              k.longitude = match.longitude;
              kModified = true;
            }

            if (kModified) {
              updatedKept.add(k);
            }
            break;
          }
        }
      }

      if (isDuplicate) {
        toDelete.add(match.id);
      } else {
        kept.add(match);
      }
    }

    if (updatedKept.isNotEmpty) {
      await isar.writeTxn(() async {
        for (final k in updatedKept) {
          await isar.matchRecords.put(k);
          if (k.game.value != null) {
            await k.game.save();
          }
        }
      });
    }

    if (toDelete.isNotEmpty) {
      await isar.writeTxn(() async {
        for (final id in toDelete) {
          await isar.matchRecords.delete(id);
        }
      });
    }

    return toDelete.length;
  }

  /// Clears all tables in the database (Game, MatchRecord, Player).
  Future<void> clearAllData() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }
}
