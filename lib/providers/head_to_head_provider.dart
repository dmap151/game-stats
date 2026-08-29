import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../data/models/match_record.dart';
import 'providers.dart';

class HeadToHeadStats {
  final int player1BetterCount;
  final int player2BetterCount;
  final int ties;
  final int matchesTogether;
  final double player1AveragePlacement;
  final double player2AveragePlacement;
  final int player1Wins;
  final int player2Wins;
  final List<MatchRecord> sharedMatches;

  HeadToHeadStats({
    required this.player1BetterCount,
    required this.player2BetterCount,
    required this.ties,
    required this.matchesTogether,
    required this.player1AveragePlacement,
    required this.player2AveragePlacement,
    required this.player1Wins,
    required this.player2Wins,
    required this.sharedMatches,
  });
}

typedef PlayerPair = ({int p1, int p2});

final headToHeadStatsProvider = Provider.family<HeadToHeadStats, PlayerPair>((ref, ids) {
  final recordsAsync = ref.watch(matchRecordsProvider);

  return recordsAsync.when(
    data: (records) {
      int p1BetterCount = 0;
      int p2BetterCount = 0;
      int ties = 0;
      int matchesTogether = 0;
      int p1TotalPlacement = 0;
      int p2TotalPlacement = 0;
      int p1Wins = 0;
      int p2Wins = 0;
      final List<MatchRecord> sharedMatches = [];

      for (var record in records) {
        final scores = record.playerScores;
        final p1ScoreOpt = scores.firstWhereOrNull((s) => s.playerId == ids.p1);
        final p2ScoreOpt = scores.firstWhereOrNull((s) => s.playerId == ids.p2);

        if (p1ScoreOpt != null && p2ScoreOpt != null) {
          matchesTogether++;
          p1TotalPlacement += p1ScoreOpt.placement;
          p2TotalPlacement += p2ScoreOpt.placement;

          if (p1ScoreOpt.placement < p2ScoreOpt.placement) {
            p1BetterCount++;
          } else if (p2ScoreOpt.placement < p1ScoreOpt.placement) {
            p2BetterCount++;
          } else {
            ties++;
          }

          if (p1ScoreOpt.placement == 1) {
            p1Wins++;
          }
          if (p2ScoreOpt.placement == 1) {
            p2Wins++;
          }
          
          sharedMatches.add(record);
        }
      }

      return HeadToHeadStats(
        player1BetterCount: p1BetterCount,
        player2BetterCount: p2BetterCount,
        ties: ties,
        matchesTogether: matchesTogether,
        player1AveragePlacement: matchesTogether > 0 ? p1TotalPlacement / matchesTogether : 0.0,
        player2AveragePlacement: matchesTogether > 0 ? p2TotalPlacement / matchesTogether : 0.0,
        player1Wins: p1Wins,
        player2Wins: p2Wins,
        sharedMatches: sharedMatches,
      );
    },
    loading: () => HeadToHeadStats(
      player1BetterCount: 0,
      player2BetterCount: 0,
      ties: 0,
      matchesTogether: 0,
      player1AveragePlacement: 0.0,
      player2AveragePlacement: 0.0,
      player1Wins: 0,
      player2Wins: 0,
      sharedMatches: [],
    ),
    error: (_, _) => HeadToHeadStats(
      player1BetterCount: 0,
      player2BetterCount: 0,
      ties: 0,
      matchesTogether: 0,
      player1AveragePlacement: 0.0,
      player2AveragePlacement: 0.0,
      player1Wins: 0,
      player2Wins: 0,
      sharedMatches: [],
    ),
  );
});
