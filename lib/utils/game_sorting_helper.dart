import 'package:flutter/material.dart';

import '../data/models/game.dart';
import '../data/models/match_record.dart';

/// Available sorting options for the games library list.
enum GameSortOption {
  nameAsc,
  nameDesc,
  matchesDesc,
  matchesAsc,
  recentlyPlayed,
  newest;

  String get label {
    switch (this) {
      case GameSortOption.nameAsc:
        return 'Name (A–Z)';
      case GameSortOption.nameDesc:
        return 'Name (Z–A)';
      case GameSortOption.matchesDesc:
        return 'Meiste Partien';
      case GameSortOption.matchesAsc:
        return 'Wenigste Partien';
      case GameSortOption.recentlyPlayed:
        return 'Zuletzt gespielt';
      case GameSortOption.newest:
        return 'Neueste zuerst';
    }
  }

  IconData get icon {
    switch (this) {
      case GameSortOption.nameAsc:
      case GameSortOption.nameDesc:
        return Icons.sort_by_alpha;
      case GameSortOption.matchesDesc:
      case GameSortOption.matchesAsc:
        return Icons.sports_esports_outlined;
      case GameSortOption.recentlyPlayed:
        return Icons.history;
      case GameSortOption.newest:
        return Icons.access_time;
    }
  }

  static GameSortOption fromKey(String? key) {
    if (key == null) return GameSortOption.nameAsc;
    return GameSortOption.values.firstWhere(
      (e) => e.name == key,
      orElse: () => GameSortOption.nameAsc,
    );
  }
}

/// Holds summary statistics used for sorting and displaying game items.
class GameSortStats {
  final int matchesCount;
  final DateTime? lastPlayed;

  const GameSortStats({this.matchesCount = 0, this.lastPlayed});
}

/// Helper methods to compute game statistics and sort games list.
class GameSortingHelper {
  /// Computes stats (matchesCount, lastPlayed) for all games in a single pass.
  static Map<int, GameSortStats> calculateStats(
    Iterable<Game> games,
    List<MatchRecord> matchRecords,
  ) {
    final matchCounts = <int, int>{};
    final lastPlayedMap = <int, DateTime>{};

    for (final record in matchRecords) {
      final game = record.game.value;
      if (game != null) {
        matchCounts[game.id] = (matchCounts[game.id] ?? 0) + 1;
        final prevDate = lastPlayedMap[game.id];
        if (prevDate == null || record.date.isAfter(prevDate)) {
          lastPlayedMap[game.id] = record.date;
        }
      }
    }

    final result = <int, GameSortStats>{};
    for (final game in games) {
      result[game.id] = GameSortStats(
        matchesCount: matchCounts[game.id] ?? 0,
        lastPlayed: lastPlayedMap[game.id],
      );
    }
    return result;
  }

  /// Returns a new list of games sorted according to the given [sortOption].
  static List<Game> sortGames({
    required List<Game> games,
    required GameSortOption sortOption,
    required Map<int, GameSortStats> stats,
  }) {
    final list = List<Game>.from(games);
    list.sort((a, b) {
      final statsA = stats[a.id] ?? const GameSortStats();
      final statsB = stats[b.id] ?? const GameSortStats();

      switch (sortOption) {
        case GameSortOption.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());

        case GameSortOption.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());

        case GameSortOption.matchesDesc:
          final cmp = statsB.matchesCount.compareTo(statsA.matchesCount);
          if (cmp != 0) return cmp;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());

        case GameSortOption.matchesAsc:
          final cmp = statsA.matchesCount.compareTo(statsB.matchesCount);
          if (cmp != 0) return cmp;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());

        case GameSortOption.recentlyPlayed:
          if (statsA.lastPlayed == null && statsB.lastPlayed == null) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          }
          if (statsA.lastPlayed == null) return 1;
          if (statsB.lastPlayed == null) return -1;
          final cmp = statsB.lastPlayed!.compareTo(statsA.lastPlayed!);
          if (cmp != 0) return cmp;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());

        case GameSortOption.newest:
          return b.id.compareTo(a.id);
      }
    });
    return list;
  }
}
