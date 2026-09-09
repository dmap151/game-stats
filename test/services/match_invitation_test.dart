import 'package:flutter_test/flutter_test.dart';
import 'package:game_stats/services/match_invitation_service.dart';

void main() {
  group('MatchInvitation & Participant Model Tests', () {
    test('MatchInvitationParticipant instantiates with correct values', () {
      const participant = MatchInvitationParticipant(
        playerName: 'Bob',
        rank: 1,
        score: 120,
        linkedUserId: 'bob-uuid',
      );

      expect(participant.playerName, 'Bob');
      expect(participant.rank, 1);
      expect(participant.score, 120);
      expect(participant.linkedUserId, 'bob-uuid');
    });

    test('MatchInvitation instantiates with all properties', () {
      final now = DateTime(2026, 9, 10, 15, 30);
      final invitation = MatchInvitation(
        matchId: 'match-123',
        creatorUserId: 'user-creator',
        creatorName: 'David',
        creatorFriendCode: '#DAVI-1234',
        gameName: 'Catan',
        date: now,
        imageUrl: 'https://example.com/match.jpg',
        imageUrls: ['https://example.com/match2.jpg'],
        latitude: 52.52,
        longitude: 13.405,
        myScoreId: 'score-456',
        myRank: 2,
        myScore: 85,
        participants: const [
          MatchInvitationParticipant(
            playerName: 'David',
            rank: 1,
            score: 100,
            linkedUserId: 'user-creator',
          ),
          MatchInvitationParticipant(
            playerName: 'Bob',
            rank: 2,
            score: 85,
            linkedUserId: 'my-uuid',
          ),
        ],
      );

      expect(invitation.matchId, 'match-123');
      expect(invitation.creatorUserId, 'user-creator');
      expect(invitation.creatorName, 'David');
      expect(invitation.creatorFriendCode, '#DAVI-1234');
      expect(invitation.gameName, 'Catan');
      expect(invitation.date, now);
      expect(invitation.imageUrl, 'https://example.com/match.jpg');
      expect(invitation.imageUrls.length, 1);
      expect(invitation.latitude, 52.52);
      expect(invitation.longitude, 13.405);
      expect(invitation.myScoreId, 'score-456');
      expect(invitation.myRank, 2);
      expect(invitation.myScore, 85);
      expect(invitation.participants.length, 2);
      expect(invitation.participants[0].playerName, 'David');
      expect(invitation.participants[1].playerName, 'Bob');
    });

    test('MatchInvitation list can be sorted by date descending', () {
      final invOld = MatchInvitation(
        matchId: 'old',
        creatorUserId: 'u1',
        creatorName: 'Alice',
        creatorFriendCode: '#ALIC-1111',
        gameName: 'Carcassonne',
        date: DateTime(2026, 9, 8),
        myScoreId: 's1',
        myRank: 1,
        participants: const [],
      );

      final invNew = MatchInvitation(
        matchId: 'new',
        creatorUserId: 'u2',
        creatorName: 'Bob',
        creatorFriendCode: '#BOB-2222',
        gameName: 'Wingspan',
        date: DateTime(2026, 9, 10),
        myScoreId: 's2',
        myRank: 2,
        participants: const [],
      );

      final list = [invOld, invNew]..sort((a, b) => b.date.compareTo(a.date));

      expect(list.first.matchId, 'new');
      expect(list.last.matchId, 'old');
    });
  });
}
