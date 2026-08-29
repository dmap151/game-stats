import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_stats/data/models/game.dart';
import 'package:game_stats/data/models/match_record.dart';
import 'package:game_stats/utils/game_image_helper.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('game_stats_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  String createTestImage(String filename) {
    final file = File('${tempDir.path}/$filename');
    file.writeAsStringSync('dummy image data');
    return file.path;
  }

  group('GameImageHelper Tests', () {
    test('Prioritizes custom game image over match photos', () {
      final customPath = createTestImage('custom.jpg');
      final matchPath = createTestImage('match1.jpg');

      final game = Game()
        ..id = 1
        ..name = 'Catan'
        ..imagePath = customPath;

      final match = MatchRecord()
        ..id = 10
        ..imagePath = matchPath;
      match.game.value = game;

      final resolvedImage = GameImageHelper.getDisplayImage(game, [match]);
      expect(resolvedImage, customPath);
    });

    test('Falls back to first match photo if custom image is null', () {
      final photo1 = createTestImage('carc1.jpg');
      final photo2 = createTestImage('carc2.jpg');

      final game = Game()
        ..id = 2
        ..name = 'Carcassonne';

      final match1 = MatchRecord()
        ..id = 20
        ..date = DateTime(2025, 1, 1)
        ..imagePath = photo1;
      match1.game.value = game;

      final match2 = MatchRecord()
        ..id = 21
        ..date = DateTime(2025, 1, 2)
        ..imagePath = photo2;
      match2.game.value = game;

      final resolvedImage = GameImageHelper.getDisplayImage(game, [match2, match1]);
      // Should pick match 1 (oldest chronological match)
      expect(resolvedImage, photo1);
    });

    test('Falls back to additional match photos in imagePaths list', () {
      final extraPhoto = createTestImage('extra.jpg');

      final game = Game()
        ..id = 3
        ..name = 'Azul';

      final match = MatchRecord()
        ..id = 30
        ..date = DateTime(2025, 2, 1)
        ..imagePath = null
        ..imagePaths = [extraPhoto];
      match.game.value = game;

      final resolvedImage = GameImageHelper.getDisplayImage(game, [match]);
      expect(resolvedImage, extraPhoto);
    });

    test('Returns null when no image exists anywhere', () {
      final game = Game()
        ..id = 4
        ..name = 'Uno';

      final match = MatchRecord()
        ..id = 40
        ..date = DateTime(2025, 3, 1);
      match.game.value = game;

      final resolvedImage = GameImageHelper.getDisplayImage(game, [match]);
      expect(resolvedImage, isNull);
    });
  });
}
