import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_stats/services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DummySupabaseClient extends Fake implements SupabaseClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late StorageService storageService;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('storage_sync_test_');
    storageService = StorageService(
      DummySupabaseClient(),
      docsDirProvider: () async => tempDir,
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('StorageService Tests', () {
    test('Storage bucket name is match-images', () {
      expect(StorageService.matchImagesBucket, 'match-images');
    });

    test('downloadPhotoToLocalCache returns null for empty or non-http URLs', () async {
      final resEmpty = await storageService.downloadPhotoToLocalCache(
        imageUrl: '',
        localFileName: 'test.jpg',
      );
      expect(resEmpty, isNull);

      final resInvalid = await storageService.downloadPhotoToLocalCache(
        imageUrl: '/local/file/path.jpg',
        localFileName: 'test.jpg',
      );
      expect(resInvalid, isNull);
    });

    test('downloadPhotoToLocalCache returns existing local file immediately without network', () async {
      final existingFile = File('${tempDir.path}/existing.jpg');
      existingFile.writeAsStringSync('fake-image-bytes-data');

      final result = await storageService.downloadPhotoToLocalCache(
        imageUrl: 'https://example.com/existing.jpg',
        localFileName: 'existing.jpg',
      );

      expect(result, existingFile.path);
      expect(File(result!).existsSync(), isTrue);
    });

    test('uploadMatchPhoto gracefully returns null for non-existent file', () async {
      final nonExistent = File('${tempDir.path}/does_not_exist.jpg');
      final result = await storageService.uploadMatchPhoto(
        userId: 'user-123',
        file: nonExistent,
        fileName: 'test.jpg',
      );

      expect(result, isNull);
    });
  });
}
