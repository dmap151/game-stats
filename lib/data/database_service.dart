import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/game.dart';
import 'models/match_record.dart';
import 'models/player.dart';

class DatabaseService {
  late Isar isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [GameSchema, MatchRecordSchema, PlayerSchema],
      directory: dir.path,
    );
  }

  // --- Player Methods ---

  Future<int> savePlayer(Player player) async {
    return await isar.writeTxn(() async {
      return await isar.players.put(player);
    });
  }

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

  Future<List<Player>> getAllPlayers() async {
    return await isar.players.where().findAll();
  }

  Stream<List<Player>> listenToPlayers() {
    return isar.players.where().watch(fireImmediately: true);
  }
  
  Future<bool> deletePlayer(int id) async {
    return await isar.writeTxn(() async {
      return await isar.players.delete(id);
    });
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

  // --- MatchRecord Methods ---

  Future<int> saveMatchRecord(MatchRecord record) async {
    return await isar.writeTxn(() async {
      final id = await isar.matchRecords.put(record);
      await record.game.save();
      return id;
    });
  }

  Future<List<MatchRecord>> getAllMatchRecords() async {
    return await isar.matchRecords.where().findAll();
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
}
