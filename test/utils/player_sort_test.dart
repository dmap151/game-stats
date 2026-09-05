import 'package:flutter_test/flutter_test.dart';
import 'package:game_stats/data/models/match_record.dart';
import 'package:game_stats/data/models/player.dart';
import 'package:game_stats/utils/player_sorting_helper.dart';

void main() {
  group('PlayerSortingHelper Tests', () {
    late Player alice;
    late Player bob;
    late Player charlie;
    late List<Player> players;
    late List<MatchRecord> records;

    setUp(() {
      alice = Player()
        ..id = 1
        ..name = 'Alice';

      bob = Player()
        ..id = 2
        ..name = 'Bob';

      charlie = Player()
        ..id = 3
        ..name = 'Charlie';

      players = [alice, bob, charlie];

      // Alice: 3 matches, 2 wins (66.7%)
      // Bob: 2 matches, 2 wins (100%)
      // Charlie: 1 match, 0 wins (0%)
      final match1 = MatchRecord()
        ..id = 101
        ..date = DateTime(2025, 1, 10)
        ..playerScores = [
          PlayerScore()
            ..playerId = 1
            ..placement = 1,
          PlayerScore()
            ..playerId = 2
            ..placement = 2,
        ];

      final match2 = MatchRecord()
        ..id = 102
        ..date = DateTime(2025, 1, 15)
        ..playerScores = [
          PlayerScore()
            ..playerId = 1
            ..placement = 1,
          PlayerScore()
            ..playerId = 3
            ..placement = 2,
        ];

      final match3 = MatchRecord()
        ..id = 103
        ..date = DateTime(2025, 1, 20)
        ..playerScores = [
          PlayerScore()
            ..playerId = 2
            ..placement = 1,
          PlayerScore()
            ..playerId = 1
            ..placement = 2,
        ];

      records = [match1, match2, match3];
    });

    test(
      'calculateStats computes correct matches, wins, win rates and lastPlayed',
      () {
        final stats = PlayerSortingHelper.calculateStats(players, records);

        expect(stats[1]?.matches, 3);
        expect(stats[1]?.wins, 2);
        expect(stats[1]?.winRate, closeTo(66.66, 0.1));
        expect(stats[1]?.lastPlayed, DateTime(2025, 1, 20));

        expect(stats[2]?.matches, 2);
        expect(stats[2]?.wins, 1);
        expect(stats[2]?.winRate, 50.0);
        expect(stats[2]?.lastPlayed, DateTime(2025, 1, 20));

        expect(stats[3]?.matches, 1);
        expect(stats[3]?.wins, 0);
        expect(stats[3]?.winRate, 0.0);
        expect(stats[3]?.lastPlayed, DateTime(2025, 1, 15));
      },
    );

    test('Sorts by name ascending (A–Z)', () {
      final stats = PlayerSortingHelper.calculateStats(players, records);
      final sorted = PlayerSortingHelper.sortPlayers(
        players: [charlie, alice, bob],
        sortOption: PlayerSortOption.nameAsc,
        stats: stats,
      );

      expect(sorted.map((p) => p.name).toList(), ['Alice', 'Bob', 'Charlie']);
    });

    test('Sorts by name descending (Z–A)', () {
      final stats = PlayerSortingHelper.calculateStats(players, records);
      final sorted = PlayerSortingHelper.sortPlayers(
        players: [alice, charlie, bob],
        sortOption: PlayerSortOption.nameDesc,
        stats: stats,
      );

      expect(sorted.map((p) => p.name).toList(), ['Charlie', 'Bob', 'Alice']);
    });

    test('Sorts by most matches (matchesDesc)', () {
      final stats = PlayerSortingHelper.calculateStats(players, records);
      final sorted = PlayerSortingHelper.sortPlayers(
        players: [charlie, bob, alice],
        sortOption: PlayerSortOption.matchesDesc,
        stats: stats,
      );

      // Alice (3), Bob (2), Charlie (1)
      expect(sorted.map((p) => p.name).toList(), ['Alice', 'Bob', 'Charlie']);
    });

    test('Sorts by fewest matches (matchesAsc)', () {
      final stats = PlayerSortingHelper.calculateStats(players, records);
      final sorted = PlayerSortingHelper.sortPlayers(
        players: [alice, bob, charlie],
        sortOption: PlayerSortOption.matchesAsc,
        stats: stats,
      );

      // Charlie (1), Bob (2), Alice (3)
      expect(sorted.map((p) => p.name).toList(), ['Charlie', 'Bob', 'Alice']);
    });

    test('Sorts by most wins (winsDesc)', () {
      final stats = PlayerSortingHelper.calculateStats(players, records);
      final sorted = PlayerSortingHelper.sortPlayers(
        players: [charlie, bob, alice],
        sortOption: PlayerSortOption.winsDesc,
        stats: stats,
      );

      // Alice (2 wins), Bob (1 win), Charlie (0 wins)
      expect(sorted.map((p) => p.name).toList(), ['Alice', 'Bob', 'Charlie']);
    });

    test('Sorts by best win rate (winRateDesc)', () {
      final stats = PlayerSortingHelper.calculateStats(players, records);
      final sorted = PlayerSortingHelper.sortPlayers(
        players: [charlie, bob, alice],
        sortOption: PlayerSortOption.winRateDesc,
        stats: stats,
      );

      // Alice (66.7%), Bob (50%), Charlie (0%)
      expect(sorted.map((p) => p.name).toList(), ['Alice', 'Bob', 'Charlie']);
    });

    test('Sorts by newest (newest by ID desc)', () {
      final stats = PlayerSortingHelper.calculateStats(players, records);
      final sorted = PlayerSortingHelper.sortPlayers(
        players: [alice, bob, charlie],
        sortOption: PlayerSortOption.newest,
        stats: stats,
      );

      // Charlie (3), Bob (2), Alice (1)
      expect(sorted.map((p) => p.name).toList(), ['Charlie', 'Bob', 'Alice']);
    });

    test('fromKey returns matching option or defaults to nameAsc', () {
      expect(
        PlayerSortOption.fromKey('matchesDesc'),
        PlayerSortOption.matchesDesc,
      );
      expect(PlayerSortOption.fromKey('invalid_key'), PlayerSortOption.nameAsc);
      expect(PlayerSortOption.fromKey(null), PlayerSortOption.nameAsc);
    });
  });
}
