import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/database_service.dart';
import '../data/models/game.dart';
import '../data/models/match_record.dart';
import '../data/models/player.dart';
import 'storage_service.dart';
import 'supabase_service.dart';

class MatchInvitationParticipant {
  final String playerName;
  final int rank;
  final int? score;
  final String? linkedUserId;

  const MatchInvitationParticipant({
    required this.playerName,
    required this.rank,
    this.score,
    this.linkedUserId,
  });
}

class MatchInvitation {
  final String matchId;
  final String creatorUserId;
  final String creatorName;
  final String creatorFriendCode;
  final String gameName;
  final DateTime date;
  final String? imageUrl;
  final List<String> imageUrls;
  final double? latitude;
  final double? longitude;
  final String myScoreId;
  final int myRank;
  final int? myScore;
  final List<MatchInvitationParticipant> participants;

  const MatchInvitation({
    required this.matchId,
    required this.creatorUserId,
    required this.creatorName,
    required this.creatorFriendCode,
    required this.gameName,
    required this.date,
    this.imageUrl,
    this.imageUrls = const [],
    this.latitude,
    this.longitude,
    required this.myScoreId,
    required this.myRank,
    this.myScore,
    required this.participants,
  });
}

class MatchInvitationService {
  final SupabaseService _supabase;
  final DatabaseService _db;
  final StorageService? _storage;

  MatchInvitationService(this._supabase, this._db, [this._storage]);

  SupabaseClient get _client => _supabase.client;

  /// Fetches pending match invitations for the current user.
  Future<List<MatchInvitation>> getPendingMatchInvitations() async {
    final user = _supabase.currentUser;
    if (user == null) return [];

    // 1. Find all pending scores for the current user
    final rawScores = await _client
        .from('match_player_scores')
        .select('id, match_id, player_name, rank, score, linked_user_id, invitation_status')
        .eq('linked_user_id', user.id)
        .eq('invitation_status', 'pending');

    final myPendingScores = (rawScores as List).cast<Map<String, dynamic>>();
    if (myPendingScores.isEmpty) return [];

    final matchIds = myPendingScores.map((s) => s['match_id'] as String).toSet().toList();

    // 2. Fetch the corresponding matches and all participant scores
    final rawMatches = await _client
        .from('matches')
        .select('*, match_player_scores(*)')
        .inFilter('id', matchIds)
        .neq('user_id', user.id); // exclude self-created matches if any

    final matches = (rawMatches as List).cast<Map<String, dynamic>>();
    if (matches.isEmpty) return [];

    // 3. Fetch creator profiles to show their display name and friend code
    final creatorIds = matches.map((m) => m['user_id'] as String).toSet().toList();
    final rawProfiles = await _client
        .from('profiles')
        .select('id, display_name, friend_code')
        .inFilter('id', creatorIds);

    final profiles = (rawProfiles as List).cast<Map<String, dynamic>>();
    final profileMap = {
      for (final p in profiles) p['id'] as String: p,
    };

    final invitations = <MatchInvitation>[];

    for (final match in matches) {
      final matchId = match['id'] as String;
      final creatorId = match['user_id'] as String;
      final creatorProfile = profileMap[creatorId];
      final creatorName = (creatorProfile?['display_name'] as String?) ?? 'Spieler';
      final creatorCode = (creatorProfile?['friend_code'] as String?) ?? '';

      // Find my score in this match
      final myScoreRow = myPendingScores.firstWhere(
        (s) => s['match_id'] == matchId,
        orElse: () => <String, dynamic>{},
      );
      if (myScoreRow.isEmpty) continue;

      final myScoreId = myScoreRow['id'] as String;
      final myRank = (myScoreRow['rank'] as num?)?.toInt() ?? 1;
      final myScore = (myScoreRow['score'] as num?)?.toInt();

      final rawRemoteScores = (match['match_player_scores'] as List<dynamic>?) ?? [];
      final participants = <MatchInvitationParticipant>[];
      for (final item in rawRemoteScores) {
        final s = item as Map<String, dynamic>;
        participants.add(
          MatchInvitationParticipant(
            playerName: (s['player_name'] as String?) ?? 'Spieler',
            rank: (s['rank'] as num?)?.toInt() ?? 1,
            score: (s['score'] as num?)?.toInt(),
            linkedUserId: s['linked_user_id'] as String?,
          ),
        );
      }

      participants.sort((a, b) => a.rank.compareTo(b.rank));

      final rawImageUrls = match['image_urls'];
      final List<String> imageUrls = rawImageUrls is List
          ? rawImageUrls.map((e) => e.toString()).toList()
          : <String>[];

      final dateStr = match['date'] as String? ?? '';
      final date = DateTime.tryParse(dateStr)?.toLocal() ?? DateTime.now();

      invitations.add(
        MatchInvitation(
          matchId: matchId,
          creatorUserId: creatorId,
          creatorName: creatorName,
          creatorFriendCode: creatorCode,
          gameName: (match['game_name'] as String?) ?? 'Spiel',
          date: date,
          imageUrl: match['image_url'] as String?,
          imageUrls: imageUrls,
          latitude: (match['latitude'] as num?)?.toDouble(),
          longitude: (match['longitude'] as num?)?.toDouble(),
          myScoreId: myScoreId,
          myRank: myRank,
          myScore: myScore,
          participants: participants,
        ),
      );
    }

    // Sort by date descending (newest first)
    invitations.sort((a, b) => b.date.compareTo(a.date));
    return invitations;
  }

  Future<void> _updateInvitationStatus(String scoreId, String status) async {
    try {
      await _client.rpc<bool>('respond_to_match_invitation', params: {
        'p_score_id': scoreId,
        'p_status': status,
      });
    } catch (_) {
      await _client
          .from('match_player_scores')
          .update({'invitation_status': status})
          .eq('id', scoreId);
    }
  }

  /// Accepts an invitation, updates Supabase status to 'accepted',
  /// and saves the match into the local database.
  Future<void> acceptMatchInvitation(MatchInvitation invitation) async {
    final user = _supabase.currentUser;
    if (user == null) return;

    // 1. Update status in Supabase
    await _updateInvitationStatus(invitation.myScoreId, 'accepted');

    // 2. Download photos to local cache if storage is available
    String? localMainImagePath;
    final localAdditionalImagePaths = <String>[];
    final s = _storage;
    if (s != null) {
      if (invitation.imageUrl != null && invitation.imageUrl!.startsWith('http')) {
        final ext = p.extension(invitation.imageUrl!).split('?').first;
        final cleanExt = ext.isNotEmpty ? ext : '.jpg';
        localMainImagePath = await s.downloadPhotoToLocalCache(
          imageUrl: invitation.imageUrl!,
          localFileName: 'match_${invitation.matchId}_0$cleanExt',
        );
      }

      for (int i = 0; i < invitation.imageUrls.length; i++) {
        final url = invitation.imageUrls[i];
        if (url.startsWith('http')) {
          final ext = p.extension(url).split('?').first;
          final cleanExt = ext.isNotEmpty ? ext : '.jpg';
          final downloadedPath = await s.downloadPhotoToLocalCache(
            imageUrl: url,
            localFileName: 'match_${invitation.matchId}_${i + 1}$cleanExt',
          );
          if (downloadedPath != null) {
            localAdditionalImagePaths.add(downloadedPath);
          }
        }
      }
    }

    // 3. Resolve or create local Game
    var game = await _db.getGameByName(invitation.gameName);
    if (game == null) {
      game = Game()..name = invitation.gameName;
      await _db.saveGame(game);
    }

    // 4. Resolve or create local Players
    var currentLocalPlayers = await _db.getAllPlayers();
    final scores = <PlayerScore>[];

    for (final participant in invitation.participants) {
      Player? matchingPlayer;
      final linkedId = participant.linkedUserId;

      if (linkedId != null) {
        if (linkedId == user.id) {
          // This is ME
          matchingPlayer = currentLocalPlayers.cast<Player?>().firstWhere(
            (p) => p?.isMe == true,
            orElse: () => null,
          );
        } else {
          // This is a friend
          matchingPlayer = currentLocalPlayers.cast<Player?>().firstWhere(
            (p) => p?.linkedUserId == linkedId,
            orElse: () => null,
          );
        }
      }

      matchingPlayer ??= currentLocalPlayers.cast<Player?>().firstWhere(
        (p) => p?.name == participant.playerName,
        orElse: () => null,
      );

      if (matchingPlayer == null) {
        final isMe = linkedId == user.id;
        final newPlayer = Player()
          ..name = participant.playerName
          ..isMe = isMe
          ..linkedUserId = linkedId;
        final newId = await _db.savePlayer(newPlayer);
        newPlayer.id = newId;
        currentLocalPlayers = await _db.getAllPlayers();
        matchingPlayer = newPlayer;
      }

      scores.add(
        PlayerScore()
          ..playerId = matchingPlayer.id
          ..playerName = matchingPlayer.name
          ..placement = participant.rank
          ..score = participant.score
          ..linkedUserId = linkedId,
      );
    }

    // 5. Save the local match record
    final newMatch = MatchRecord()
      ..date = invitation.date
      ..numberOfPlayers = scores.isNotEmpty ? scores.length : 1
      ..imagePath = localMainImagePath
      ..imagePaths = localAdditionalImagePaths
      ..latitude = invitation.latitude
      ..longitude = invitation.longitude
      ..playerScores = scores;

    newMatch.game.value = game;
    await _db.saveMatchRecord(newMatch);
  }

  /// Declines an invitation and updates Supabase status to 'declined'.
  Future<void> declineMatchInvitation(MatchInvitation invitation) async {
    final user = _supabase.currentUser;
    if (user == null) return;

    await _updateInvitationStatus(invitation.myScoreId, 'declined');
  }
}
