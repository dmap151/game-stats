import 'package:flutter_test/flutter_test.dart';
import 'package:game_stats/data/models/match_record.dart';
import 'package:game_stats/data/models/player.dart';
import 'package:game_stats/services/friends_service.dart';

void main() {
  group('Friends & Player Account Linking Tests', () {
    test('FriendProfile.fromMap parses Supabase data correctly', () {
      final map = {
        'id': 'user-123-abc',
        'display_name': 'David',
        'friend_code': '#DAVI-9821',
        'avatar_url': 'https://example.com/avatar.png',
      };

      final profile = FriendProfile.fromMap(map);

      expect(profile.id, 'user-123-abc');
      expect(profile.displayName, 'David');
      expect(profile.friendCode, '#DAVI-9821');
      expect(profile.avatarUrl, 'https://example.com/avatar.png');
    });

    test('FriendProfile.fromMap uses sensible defaults when fields are missing', () {
      final map = {
        'id': 'user-456-xyz',
      };

      final profile = FriendProfile.fromMap(map);

      expect(profile.id, 'user-456-xyz');
      expect(profile.displayName, 'Spieler');
      expect(profile.friendCode, '');
      expect(profile.avatarUrl, isNull);
    });

    test('Player model correctly supports isMe, linkedUserId, and friendCode', () {
      final player = Player()
        ..name = 'Alice'
        ..isMe = true
        ..linkedUserId = 'user-auth-id'
        ..friendCode = '#ALIC-1122';

      expect(player.name, 'Alice');
      expect(player.isMe, isTrue);
      expect(player.linkedUserId, 'user-auth-id');
      expect(player.friendCode, '#ALIC-1122');
    });

    test('PlayerScore model correctly supports linkedUserId', () {
      final score = PlayerScore()
        ..playerId = 1
        ..playerName = 'Bob'
        ..placement = 1
        ..score = 42
        ..linkedUserId = 'bob-user-id';

      expect(score.playerId, 1);
      expect(score.playerName, 'Bob');
      expect(score.placement, 1);
      expect(score.score, 42);
      expect(score.linkedUserId, 'bob-user-id');
    });

    test('MatchRecord stores player scores with linkedUserId', () {
      final match = MatchRecord()
        ..date = DateTime(2026, 9, 9)
        ..numberOfPlayers = 2
        ..playerScores = [
          PlayerScore()
            ..playerName = 'David'
            ..placement = 1
            ..score = 100
            ..linkedUserId = 'david-user-id',
          PlayerScore()
            ..playerName = 'Anna'
            ..placement = 2
            ..score = 80
            ..linkedUserId = 'anna-user-id',
        ];

      expect(match.playerScores.length, 2);
      expect(match.playerScores[0].linkedUserId, 'david-user-id');
      expect(match.playerScores[1].linkedUserId, 'anna-user-id');
    });

    test('Player model defaults isMe to false and fields to null', () {
      final player = Player()..name = 'Test';
      expect(player.isMe, isFalse);
      expect(player.linkedUserId, isNull);
      expect(player.friendCode, isNull);
    });
  });
}
