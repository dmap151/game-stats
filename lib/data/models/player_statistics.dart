import 'game.dart';

class PlayerStatistics {
  final int totalMatchesPlayed;
  final int totalWins;
  final double globalWinRate;
  final Game? mostPlayedGame;
  final int mostPlayedGameMatches;

  PlayerStatistics({
    required this.totalMatchesPlayed,
    required this.totalWins,
    required this.globalWinRate,
    this.mostPlayedGame,
    this.mostPlayedGameMatches = 0,
  });
}
