import 'dart:io';
import '../data/models/game.dart';
import '../data/models/match_record.dart';

class GameImageHelper {
  /// Resolves images for a list of games in a single fast, optimized pass.
  /// Returns a Map of Game ID -> Image Path.
  static Map<int, String?> resolveGameImages(
    Iterable<Game> games,
    List<MatchRecord> allMatches,
  ) {
    final result = <int, String?>{};

    // Group matches by game ID
    final matchesByGame = <int, List<MatchRecord>>{};
    for (final match in allMatches) {
      final gId = match.game.value?.id;
      if (gId != null) {
        (matchesByGame[gId] ??= []).add(match);
      }
    }

    for (final game in games) {
      // 1. Check custom uploaded image on Game
      if (game.imagePath != null && game.imagePath!.isNotEmpty) {
        if (File(game.imagePath!).existsSync()) {
          result[game.id] = game.imagePath;
          continue;
        }
      }

      // 2. Check matches chronologically
      final gameMatches = matchesByGame[game.id];
      if (gameMatches != null && gameMatches.isNotEmpty) {
        // Sort earliest match first
        gameMatches.sort((a, b) => a.date.compareTo(b.date));

        String? foundImage;
        for (final match in gameMatches) {
          if (match.imagePath != null && match.imagePath!.isNotEmpty) {
            if (File(match.imagePath!).existsSync()) {
              foundImage = match.imagePath;
              break;
            }
          }
          for (final imgPath in match.imagePaths) {
            if (imgPath.isNotEmpty && File(imgPath).existsSync()) {
              foundImage = imgPath;
              break;
            }
          }
          if (foundImage != null) break;
        }
        result[game.id] = foundImage;
      } else {
        result[game.id] = null;
      }
    }

    return result;
  }

  /// Returns the image path to display for a single game.
  static String? getDisplayImage(Game game, List<MatchRecord> allMatches) {
    if (game.imagePath != null && game.imagePath!.isNotEmpty) {
      if (File(game.imagePath!).existsSync()) {
        return game.imagePath;
      }
    }

    return getFallbackMatchImage(game, allMatches);
  }

  /// Returns the fallback image path found from matches only (if any).
  static String? getFallbackMatchImage(Game game, List<MatchRecord> allMatches) {
    final gameMatches = allMatches
        .where((m) => m.game.value?.id == game.id)
        .toList();
    
    if (gameMatches.isEmpty) return null;
    gameMatches.sort((a, b) => a.date.compareTo(b.date));

    for (final match in gameMatches) {
      if (match.imagePath != null && match.imagePath!.isNotEmpty) {
        if (File(match.imagePath!).existsSync()) {
          return match.imagePath;
        }
      }
      for (final imgPath in match.imagePaths) {
        if (imgPath.isNotEmpty && File(imgPath).existsSync()) {
          return imgPath;
        }
      }
    }

    return null;
  }
}
