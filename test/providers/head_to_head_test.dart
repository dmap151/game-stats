import 'package:flutter_test/flutter_test.dart';
import 'package:game_stats/data/models/match_record.dart';
import 'package:game_stats/providers/head_to_head_provider.dart';

void main() {
  group('HeadToHead Calculation Tests', () {
    test('Correctly calculates head-to-head wins and comparisons', () {
      const p1Id = 1;
      const p2Id = 2;

      // Match 1: Player 1 wins (placement 1), Player 2 gets placement 2
      final match1 = MatchRecord()
        ..id = 101
        ..date = DateTime(2025, 1, 1)
        ..numberOfPlayers = 2
        ..playerScores = [
          PlayerScore()
            ..playerId = p1Id
            ..playerName = 'David'
            ..placement = 1
            ..score = 50,
          PlayerScore()
            ..playerId = p2Id
            ..playerName = 'Alex'
            ..placement = 2
            ..score = 40,
        ];

      // Match 2: Player 2 wins (placement 1), Player 1 gets placement 3
      final match2 = MatchRecord()
        ..id = 102
        ..date = DateTime(2025, 1, 2)
        ..numberOfPlayers = 4
        ..playerScores = [
          PlayerScore()
            ..playerId = p2Id
            ..playerName = 'Alex'
            ..placement = 1
            ..score = 70,
          PlayerScore()
            ..playerId = p1Id
            ..playerName = 'David'
            ..placement = 3
            ..score = 30,
        ];

      // Match 3: Unrelated match with only Player 1
      final match3 = MatchRecord()
        ..id = 103
        ..date = DateTime(2025, 1, 3)
        ..numberOfPlayers = 2
        ..playerScores = [
          PlayerScore()
            ..playerId = p1Id
            ..playerName = 'David'
            ..placement = 1
            ..score = 100,
          PlayerScore()
            ..playerId = 99
            ..playerName = 'Other'
            ..placement = 2
            ..score = 80,
        ];

      final records = [match1, match2, match3];

      int p1BetterCount = 0;
      int p2BetterCount = 0;
      int ties = 0;
      int matchesTogether = 0;
      int p1Wins = 0;
      int p2Wins = 0;

      for (var record in records) {
        final p1Score = record.playerScores.where((s) => s.playerId == p1Id).firstOrNull;
        final p2Score = record.playerScores.where((s) => s.playerId == p2Id).firstOrNull;

        if (p1Score != null && p2Score != null) {
          matchesTogether++;
          if (p1Score.placement < p2Score.placement) {
            p1BetterCount++;
          } else if (p2Score.placement < p1Score.placement) {
            p2BetterCount++;
          } else {
            ties++;
          }

          if (p1Score.placement == 1) p1Wins++;
          if (p2Score.placement == 1) p2Wins++;
        }
      }

      final stats = HeadToHeadStats(
        player1BetterCount: p1BetterCount,
        player2BetterCount: p2BetterCount,
        ties: ties,
        matchesTogether: matchesTogether,
        player1AveragePlacement: 2.0,
        player2AveragePlacement: 1.5,
        player1Wins: p1Wins,
        player2Wins: p2Wins,
        sharedMatches: [match1, match2],
      );

      expect(stats.matchesTogether, 2);
      expect(stats.player1BetterCount, 1);
      expect(stats.player2BetterCount, 1);
      expect(stats.player1Wins, 1);
      expect(stats.player2Wins, 1);
      expect(stats.ties, 0);
    });
  });
}
