import 'package:flutter_test/flutter_test.dart';
import 'package:game_stats/data/models/game.dart';
import 'package:game_stats/data/models/match_record.dart';
import 'package:game_stats/utils/game_sorting_helper.dart';

void main() {
  group('GameSortingHelper Tests', () {
    late Game catan;
    late Game carcassonne;
    late Game wingspan;
    late List<Game> games;
    late List<MatchRecord> records;

    setUp(() {
      catan = Game()
        ..id = 1
        ..name = 'Catan';

      carcassonne = Game()
        ..id = 2
        ..name = 'Carcassonne';

      wingspan = Game()
        ..id = 3
        ..name = 'Flügelschlag';

      games = [catan, carcassonne, wingspan];

      // Catan: 1 match on 2025-01-10
      final m1 = MatchRecord()
        ..id = 101
        ..date = DateTime(2025, 1, 10);
      m1.game.value = catan;

      // Carcassonne: 3 matches, latest on 2025-01-25
      final m2 = MatchRecord()
        ..id = 102
        ..date = DateTime(2025, 1, 5);
      m2.game.value = carcassonne;

      final m3 = MatchRecord()
        ..id = 103
        ..date = DateTime(2025, 1, 25);
      m3.game.value = carcassonne;

      final m4 = MatchRecord()
        ..id = 104
        ..date = DateTime(2025, 1, 15);
      m4.game.value = carcassonne;

      // Wingspan: 2 matches, latest on 2025-01-20
      final m5 = MatchRecord()
        ..id = 105
        ..date = DateTime(2025, 1, 12);
      m5.game.value = wingspan;

      final m6 = MatchRecord()
        ..id = 106
        ..date = DateTime(2025, 1, 20);
      m6.game.value = wingspan;

      records = [m1, m2, m3, m4, m5, m6];
    });

    test('calculateStats computes correct match counts and lastPlayed', () {
      final stats = GameSortingHelper.calculateStats(games, records);

      expect(stats[1]?.matchesCount, 1);
      expect(stats[1]?.lastPlayed, DateTime(2025, 1, 10));

      expect(stats[2]?.matchesCount, 3);
      expect(stats[2]?.lastPlayed, DateTime(2025, 1, 25));

      expect(stats[3]?.matchesCount, 2);
      expect(stats[3]?.lastPlayed, DateTime(2025, 1, 20));
    });

    test('Sorts by name ascending (A–Z)', () {
      final stats = GameSortingHelper.calculateStats(games, records);
      final sorted = GameSortingHelper.sortGames(
        games: [wingspan, catan, carcassonne],
        sortOption: GameSortOption.nameAsc,
        stats: stats,
      );

      expect(sorted.map((g) => g.name).toList(), [
        'Carcassonne',
        'Catan',
        'Flügelschlag',
      ]);
    });

    test('Sorts by name descending (Z–A)', () {
      final stats = GameSortingHelper.calculateStats(games, records);
      final sorted = GameSortingHelper.sortGames(
        games: [catan, carcassonne, wingspan],
        sortOption: GameSortOption.nameDesc,
        stats: stats,
      );

      expect(sorted.map((g) => g.name).toList(), [
        'Flügelschlag',
        'Catan',
        'Carcassonne',
      ]);
    });

    test('Sorts by most matches (matchesDesc)', () {
      final stats = GameSortingHelper.calculateStats(games, records);
      final sorted = GameSortingHelper.sortGames(
        games: [catan, wingspan, carcassonne],
        sortOption: GameSortOption.matchesDesc,
        stats: stats,
      );

      // Carcassonne (3), Wingspan (2), Catan (1)
      expect(sorted.map((g) => g.name).toList(), [
        'Carcassonne',
        'Flügelschlag',
        'Catan',
      ]);
    });

    test('Sorts by fewest matches (matchesAsc)', () {
      final stats = GameSortingHelper.calculateStats(games, records);
      final sorted = GameSortingHelper.sortGames(
        games: [carcassonne, wingspan, catan],
        sortOption: GameSortOption.matchesAsc,
        stats: stats,
      );

      // Catan (1), Wingspan (2), Carcassonne (3)
      expect(sorted.map((g) => g.name).toList(), [
        'Catan',
        'Flügelschlag',
        'Carcassonne',
      ]);
    });

    test('Sorts by recently played (recentlyPlayed)', () {
      final stats = GameSortingHelper.calculateStats(games, records);
      final sorted = GameSortingHelper.sortGames(
        games: [catan, carcassonne, wingspan],
        sortOption: GameSortOption.recentlyPlayed,
        stats: stats,
      );

      // Carcassonne (2025-01-25), Wingspan (2025-01-20), Catan (2025-01-10)
      expect(sorted.map((g) => g.name).toList(), [
        'Carcassonne',
        'Flügelschlag',
        'Catan',
      ]);
    });

    test('Sorts by newest (newest by ID desc)', () {
      final stats = GameSortingHelper.calculateStats(games, records);
      final sorted = GameSortingHelper.sortGames(
        games: [catan, carcassonne, wingspan],
        sortOption: GameSortOption.newest,
        stats: stats,
      );

      // Wingspan (3), Carcassonne (2), Catan (1)
      expect(sorted.map((g) => g.name).toList(), [
        'Flügelschlag',
        'Carcassonne',
        'Catan',
      ]);
    });

    test('fromKey returns matching option or defaults to nameAsc', () {
      expect(
        GameSortOption.fromKey('recentlyPlayed'),
        GameSortOption.recentlyPlayed,
      );
      expect(GameSortOption.fromKey('unknown'), GameSortOption.nameAsc);
      expect(GameSortOption.fromKey(null), GameSortOption.nameAsc);
    });
  });
}
