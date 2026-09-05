import 'package:flutter/material.dart';

import '../data/models/match_record.dart';
import '../data/models/player.dart';

/// Available sorting options for the players list.
enum PlayerSortOption {
  nameAsc,
  nameDesc,
  matchesDesc,
  matchesAsc,
  winsDesc,
  winRateDesc,
  newest;

  String get label {
    switch (this) {
      case PlayerSortOption.nameAsc:
        return 'Name (A–Z)';
      case PlayerSortOption.nameDesc:
        return 'Name (Z–A)';
      case PlayerSortOption.matchesDesc:
        return 'Meiste Partien';
      case PlayerSortOption.matchesAsc:
        return 'Wenigste Partien';
      case PlayerSortOption.winsDesc:
        return 'Meiste Siege';
      case PlayerSortOption.winRateDesc:
        return 'Beste Siegquote';
      case PlayerSortOption.newest:
        return 'Neueste zuerst';
    }
  }

  IconData get icon {
    switch (this) {
      case PlayerSortOption.nameAsc:
      case PlayerSortOption.nameDesc:
        return Icons.sort_by_alpha;
      case PlayerSortOption.matchesDesc:
      case PlayerSortOption.matchesAsc:
        return Icons.sports_esports_outlined;
      case PlayerSortOption.winsDesc:
        return Icons.emoji_events_outlined;
      case PlayerSortOption.winRateDesc:
        return Icons.percent;
      case PlayerSortOption.newest:
        return Icons.access_time;
    }
  }

  static PlayerSortOption fromKey(String? key) {
    if (key == null) return PlayerSortOption.nameAsc;
    return PlayerSortOption.values.firstWhere(
      (e) => e.name == key,
      orElse: () => PlayerSortOption.nameAsc,
    );
  }
}

/// Holds summary statistics used for sorting and displaying player items.
class PlayerSortStats {
  final int matches;
  final int wins;
  final DateTime? lastPlayed;

  const PlayerSortStats({this.matches = 0, this.wins = 0, this.lastPlayed});

  double get winRate => matches > 0 ? (wins / matches) * 100 : 0.0;
}

/// Helper methods to compute player statistics and sort players list.
class PlayerSortingHelper {
  /// Computes stats (matches, wins, win rate) for all players in a single pass.
  static Map<int, PlayerSortStats> calculateStats(
    List<Player> players,
    List<MatchRecord> matchRecords,
  ) {
    final matchCounts = <int, int>{};
    final winCounts = <int, int>{};
    final lastPlayedMap = <int, DateTime>{};

    for (final record in matchRecords) {
      for (final score in record.playerScores) {
        final pId = score.playerId;
        if (pId != null) {
          matchCounts[pId] = (matchCounts[pId] ?? 0) + 1;
          if (score.placement == 1) {
            winCounts[pId] = (winCounts[pId] ?? 0) + 1;
          }
          final prevDate = lastPlayedMap[pId];
          if (prevDate == null || record.date.isAfter(prevDate)) {
            lastPlayedMap[pId] = record.date;
          }
        }
      }
    }

    final result = <int, PlayerSortStats>{};
    for (final player in players) {
      result[player.id] = PlayerSortStats(
        matches: matchCounts[player.id] ?? 0,
        wins: winCounts[player.id] ?? 0,
        lastPlayed: lastPlayedMap[player.id],
      );
    }
    return result;
  }

  /// Returns a new list of players sorted according to the given [sortOption].
  static List<Player> sortPlayers({
    required List<Player> players,
    required PlayerSortOption sortOption,
    required Map<int, PlayerSortStats> stats,
  }) {
    final list = List<Player>.from(players);
    list.sort((a, b) {
      final statsA = stats[a.id] ?? const PlayerSortStats();
      final statsB = stats[b.id] ?? const PlayerSortStats();

      switch (sortOption) {
        case PlayerSortOption.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());

        case PlayerSortOption.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());

        case PlayerSortOption.matchesDesc:
          final cmp = statsB.matches.compareTo(statsA.matches);
          if (cmp != 0) return cmp;
          final winCmp = statsB.wins.compareTo(statsA.wins);
          if (winCmp != 0) return winCmp;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());

        case PlayerSortOption.matchesAsc:
          final cmp = statsA.matches.compareTo(statsB.matches);
          if (cmp != 0) return cmp;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());

        case PlayerSortOption.winsDesc:
          final cmp = statsB.wins.compareTo(statsA.wins);
          if (cmp != 0) return cmp;
          final rateCmp = statsB.winRate.compareTo(statsA.winRate);
          if (rateCmp != 0) return rateCmp;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());

        case PlayerSortOption.winRateDesc:
          final cmp = statsB.winRate.compareTo(statsA.winRate);
          if (cmp != 0) return cmp;
          final matchCmp = statsB.matches.compareTo(statsA.matches);
          if (matchCmp != 0) return matchCmp;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());

        case PlayerSortOption.newest:
          return b.id.compareTo(a.id);
      }
    });
    return list;
  }
}
