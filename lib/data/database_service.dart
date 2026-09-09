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
    final bool isFirstTimeUser = !targetDir.existsSync();
    if (!targetDir.existsSync()) {
      await targetDir.create(recursive: true);
    }

    isar = await Isar.open(
      [GameSchema, MatchRecordSchema, PlayerSchema],
      directory: targetPath,
      name: instanceName,
    );

    // If this is the first time a user is opened on this device,
    // and legacy default.isar exists in baseDir, migrate data into this user's DB
    if (userId != null && isFirstTimeUser) {
      await _migrateLegacyDataIfPresent(baseDir.path);
    }
  }

  /// Migrates legacy records from the default root Isar instance if it exists.
  Future<void> _migrateLegacyDataIfPresent(String basePath) async {
    final legacyFile = File('$basePath/default.isar');
    if (!legacyFile.existsSync()) return;

    try {
      final legacyInstance = Isar.getInstance('default') ??
          await Isar.open(
            [GameSchema, MatchRecordSchema, PlayerSchema],
            directory: basePath,
            name: 'default',
          );

      final legacyGames = await legacyInstance.games.where().findAll();
      final legacyPlayers = await legacyInstance.players.where().findAll();
      final legacyMatches = await legacyInstance.matchRecords.where().findAll();

      if (legacyGames.isNotEmpty || legacyPlayers.isNotEmpty || legacyMatches.isNotEmpty) {
        await isar.writeTxn(() async {
          for (final g in legacyGames) {
            await isar.games.put(Game()
              ..name = g.name
              ..imagePath = g.imagePath);
          }
          for (final p in legacyPlayers) {
            await isar.players.put(Player()
              ..name = p.name
              ..imagePath = p.imagePath
              ..isMe = p.isMe
              ..linkedUserId = p.linkedUserId
              ..friendCode = p.friendCode);
          }
          for (final m in legacyMatches) {
            final gameName = m.game.value?.name;
            Game? matchingGame;
            if (gameName != null) {
              matchingGame = await isar.games.where().nameEqualTo(gameName).findFirst();
            }
            final newMatch = MatchRecord()
              ..date = m.date
              ..numberOfPlayers = m.numberOfPlayers
              ..imagePath = m.imagePath
              ..imagePaths = List.from(m.imagePaths)
              ..latitude = m.latitude
              ..longitude = m.longitude
              ..playerScores = m.playerScores.map((ps) => PlayerScore()
                ..playerId = ps.playerId
                ..playerName = ps.playerName
                ..placement = ps.placement
                ..score = ps.score
                ..linkedUserId = ps.linkedUserId).toList();
            newMatch.game.value = matchingGame;
            await isar.matchRecords.put(newMatch);
            await newMatch.game.save();
          }
        });
      }
    } catch (_) {
      // Non-critical migration fallback
    }
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
  Future<Player?> getMyPlayer() async {
    return await isar.players.filter().isMeEqualTo(true).findFirst();
  }

  /// Returns a stream that emits the player designated as "Me", or null.
  Stream<Player?> listenToMyPlayer() {
    return isar.players
        .filter()
        .isMeEqualTo(true)
        .watch(fireImmediately: true)
        .map((list) => list.isEmpty ? null : list.first);
  }

  /// Sets exactly one player as "Me" and unsets isMe on all other players.
  Future<void> setMyPlayer(int playerId) async {
    await isar.writeTxn(() async {
      final allPlayers = await isar.players.where().findAll();
      for (final p in allPlayers) {
        final shouldBeMe = p.id == playerId;
        if (p.isMe != shouldBeMe) {
          p.isMe = shouldBeMe;
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
  Future<int> deduplicateMatchRecords() async {
    final matches = await getAllMatchRecords();
    final toDelete = <int>[];
    final kept = <MatchRecord>[];

    for (final match in matches) {
      bool isDuplicate = false;
      for (final k in kept) {
        final sameGame = k.game.value?.name == match.game.value?.name;
        final dateDiffMinutes = (k.date.difference(match.date)).abs().inMinutes;
        final sameTime = dateDiffMinutes <= 180;

        if (sameGame && sameTime) {
          final s1 = k.playerScores.map((s) => '${s.playerName}:${s.score}:${s.placement}').toList()..sort();
          final s2 = match.playerScores.map((s) => '${s.playerName}:${s.score}:${s.placement}').toList()..sort();
          if (s1.join(',') == s2.join(',')) {
            isDuplicate = true;
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
