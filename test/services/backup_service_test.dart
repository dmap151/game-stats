import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_stats/data/database_service.dart';
import 'package:game_stats/services/backup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('backup_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('BackupPreview correctly parses JSON data', () async {
    final jsonData = {
      'version': 1,
      'app': 'game_stats',
      'exportedAt': '2026-08-30T10:00:00.000Z',
      'games': [
        {'name': 'Catan', 'image': 'images/games/img_1.jpg'},
        {'name': 'Carcassonne', 'image': null},
      ],
      'players': [
        {'name': 'David', 'image': 'images/players/img_2.jpg'},
      ],
      'matches': [
        {
          'gameName': 'Catan',
          'date': '2026-08-20T19:00:00.000Z',
          'numberOfPlayers': 2,
          'image': 'images/matches/img_3.jpg',
          'imagePaths': ['images/matches/img_3.jpg'],
          'latitude': 48.13,
          'longitude': 11.58,
          'playerScores': [
            {'playerName': 'David', 'placement': 1, 'score': 10},
          ],
        },
      ],
    };

    final jsonFile = File('${tempDir.path}/test_backup.json');
    await jsonFile.writeAsString(jsonEncode(jsonData));

    // We can instantiate BackupService with a dummy or use parseBackupFile
    final backupService = BackupService(
      DummyDatabaseService(),
      tempDirProvider: () async => tempDir,
      docDirProvider: () async => tempDir,
    );
    final preview = await backupService.parseBackupFile(jsonFile);

    expect(preview.version, 1);
    expect(preview.gamesCount, 2);
    expect(preview.playersCount, 1);
    expect(preview.matchesCount, 1);
    final gamesList = preview.rawJson['games'] as List<dynamic>;
    final firstGame = gamesList[0] as Map<String, dynamic>;
    expect(firstGame['name'], 'Catan');
  });

  test('BackupPreview correctly extracts and parses ZIP archive with images', () async {
    final archive = Archive();

    final jsonData = <String, dynamic>{
      'version': 1,
      'app': 'game_stats',
      'exportedAt': '2026-08-30T10:00:00.000Z',
      'games': [
        {'name': 'Wingspan', 'image': 'images/games/img_1.png'},
      ],
      'players': [
        {'name': 'Anna', 'image': null},
      ],
      'matches': <Map<String, dynamic>>[],
    };

    final jsonBytes = utf8.encode(jsonEncode(jsonData));
    archive.addFile(ArchiveFile('data.json', jsonBytes.length, jsonBytes));

    final dummyImgBytes = [0xFF, 0xD8, 0xFF, 0xE0];
    archive.addFile(ArchiveFile('images/games/img_1.png', dummyImgBytes.length, dummyImgBytes));

    final zipBytes = ZipEncoder().encode(archive)!;
    final zipFile = File('${tempDir.path}/backup.zip');
    await zipFile.writeAsBytes(zipBytes);

    final backupService = BackupService(
      DummyDatabaseService(),
      tempDirProvider: () async => tempDir,
      docDirProvider: () async => tempDir,
    );
    final preview = await backupService.parseBackupFile(zipFile);

    expect(preview.gamesCount, 1);
    expect(preview.playersCount, 1);
    expect(preview.imagesCount, 1);
    expect(preview.tempImagesDir, isNotNull);
    expect(File('${preview.tempImagesDir!.path}/images/games/img_1.png').existsSync(), isTrue);

    // Clean up temp images dir created by parseBackupFile
    if (preview.tempImagesDir != null && preview.tempImagesDir!.existsSync()) {
      preview.tempImagesDir!.deleteSync(recursive: true);
    }
  });
}

class DummyDatabaseService implements DatabaseService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
