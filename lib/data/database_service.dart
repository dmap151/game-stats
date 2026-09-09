import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/game.dart';
import 'models/match_record.dart';
import 'models/player.dart';

class DatabaseService {
  late Isar isar;

  /// Initializes the Isar database and opens the necessary schemas.
  /// This must be called before any other database operations.
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [GameSchema, MatchRecordSchema, PlayerSchema],
      directory: dir.path,
    );
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
