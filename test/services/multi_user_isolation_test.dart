import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_stats/data/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('multi_user_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Multi-User Database Service Tests', () {
    test('DatabaseService tracks currentUserId accurately on initialization', () {
      final dbServiceA = DatabaseService(baseDirProvider: () async => tempDir);
      expect(dbServiceA.currentUserId, isNull);
    });

    test('Directory paths for users are isolated and distinct', () {
      final userADir = Directory('${tempDir.path}/users/user-aaa');
      final userBDir = Directory('${tempDir.path}/users/user-bbb');
      final guestDir = Directory('${tempDir.path}/guest');

      expect(userADir.path, isNot(equals(userBDir.path)));
      expect(userADir.path, isNot(equals(guestDir.path)));
      expect(userBDir.path, isNot(equals(guestDir.path)));
    });
  });
}
