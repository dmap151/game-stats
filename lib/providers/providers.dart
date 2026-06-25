import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database_service.dart';
import '../data/models/game.dart';
import '../data/models/match_record.dart';
import '../data/models/player_statistics.dart';
import '../data/models/player.dart';

final databaseProvider = Provider<DatabaseService>((ref) {
  throw UnimplementedError('DatabaseService is not initialized');
});

final matchRecordsProvider = StreamProvider<List<MatchRecord>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.listenToMatchRecords();
});

final playersProvider = StreamProvider<List<Player>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.listenToPlayers();
});

final playerStatisticsProvider = Provider<PlayerStatistics>((ref) {
  final recordsAsync = ref.watch(matchRecordsProvider);
  
  return recordsAsync.when(
    data: (records) {
      if (records.isEmpty) {
        return PlayerStatistics(
          totalMatchesPlayed: 0,
          totalWins: 0,
          globalWinRate: 0.0,
          mostPlayedGame: null,
        );
      }

      int totalWins = 0; // In a multi-player scenario, this could be the number of matches where someone won? 
      // Actually, let's just count total matches played for now.
      // If we want a specific player's stats, we'd need to filter by playerId.
      // For now, totalWins = matches where at least one player got placement == 1
      
      final gameCounts = <int, int>{};
      final gamesMap = <int, Game>{};

      for (var record in records) {
        bool hasWinner = record.playerScores.any((score) => score.placement == 1);
        if (hasWinner) {
          totalWins++;
        }
        
        final game = record.game.value;
        if (game != null) {
          gameCounts[game.id] = (gameCounts[game.id] ?? 0) + 1;
          gamesMap[game.id] = game;
        }
      }

      Game? mostPlayedGame;
      if (gameCounts.isNotEmpty) {
        final mostPlayedGameId = gameCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
        mostPlayedGame = gamesMap[mostPlayedGameId];
      }

      return PlayerStatistics(
        totalMatchesPlayed: records.length,
        totalWins: totalWins,
        globalWinRate: totalWins / records.length,
        mostPlayedGame: mostPlayedGame,
      );
    },
    loading: () => PlayerStatistics(
      totalMatchesPlayed: 0,
      totalWins: 0,
      globalWinRate: 0.0,
      mostPlayedGame: null,
    ),
    error: (_, __) => PlayerStatistics(
      totalMatchesPlayed: 0,
      totalWins: 0,
      globalWinRate: 0.0,
      mostPlayedGame: null,
    ),
  );
});
