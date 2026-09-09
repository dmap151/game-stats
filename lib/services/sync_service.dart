import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/database_service.dart';
import '../data/models/game.dart';
import '../data/models/match_record.dart';
import '../data/models/player.dart';
import 'supabase_service.dart';

enum SyncStatus { idle, syncing, success, error }

class SyncState {
  final SyncStatus status;
  final String? errorMessage;
  final DateTime? lastSyncTime;
  final int syncedCount;

  const SyncState({
    this.status = SyncStatus.idle,
    this.errorMessage,
    this.lastSyncTime,
    this.syncedCount = 0,
  });

  SyncState copyWith({
    SyncStatus? status,
    String? errorMessage,
    DateTime? lastSyncTime,
    int? syncedCount,
  }) {
    return SyncState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      syncedCount: syncedCount ?? this.syncedCount,
    );
  }
}

class SyncService {
  final DatabaseService _db;
  final SupabaseService _supabase;

  SyncService(this._db, this._supabase);

  SupabaseClient get _client => _supabase.client;

  /// Performs full bidirectional synchronization between local Isar DB and Supabase.
  Future<int> syncAll() async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw Exception('Benutzer nicht angemeldet.');
    }

    // 0. Clean local duplicates if any exist
    await _db.deduplicateMatchRecords();

    // 1. Clean remote duplicates if previous sync created any
    await _cleanRemoteDuplicateMatches(user.id);

    int syncedTotal = 0;

    // 2. Sync Players
    syncedTotal += await _syncPlayers(user.id);

    // 3. Sync Games
    syncedTotal += await _syncGames(user.id);

    // 4. Sync Matches
    syncedTotal += await _syncMatches(user.id);

    // 5. Final local deduplication safety check
    await _db.deduplicateMatchRecords();

    return syncedTotal;
  }

  /// Removes duplicate matches in Supabase that have identical date and game_name
  Future<void> _cleanRemoteDuplicateMatches(String userId) async {
    try {
      final List<dynamic> remoteMatches = await _client
          .from('matches')
          .select('id, date, game_name, local_id')
          .eq('user_id', userId);

      final seen = <String, String>{};
      final duplicatesToDelete = <String>[];

      for (final item in remoteMatches) {
        final m = item as Map<String, dynamic>;
        final id = m['id'] as String;
        final date = m['date'] as String;
        final game = m['game_name'] as String;
        final key = '$game|$date';

        if (seen.containsKey(key)) {
          duplicatesToDelete.add(id);
        } else {
          seen[key] = id;
        }
      }

      for (final id in duplicatesToDelete) {
        await _client.from('matches').delete().eq('id', id);
      }
    } catch (_) {
      // Non-critical cleanup
    }
  }

  Future<int> _syncPlayers(String userId) async {
    int count = 0;
    final localPlayers = await _db.getAllPlayers();

    // 1. Upload local players
    for (final player in localPlayers) {
      final existing = await _client
          .from('players')
          .select('id')
          .eq('user_id', userId)
          .eq('name', player.name)
          .maybeSingle();

      if (existing == null) {
        await _client.from('players').insert({
          'user_id': userId,
          'local_id': player.id,
          'name': player.name,
          'avatar_url': player.imagePath,
        });
        count++;
      }
    }

    // 2. Download remote players
    final List<dynamic> remotePlayers = await _client
        .from('players')
        .select()
        .eq('user_id', userId);

    for (final item in remotePlayers) {
      final remote = item as Map<String, dynamic>;
      final name = remote['name'] as String;
      final existingLocal = await _db.getPlayerByName(name);
      if (existingLocal == null) {
        final newPlayer = Player()
          ..name = name
          ..imagePath = remote['avatar_url'] as String?;
        await _db.savePlayer(newPlayer);
        count++;
      }
    }

    return count;
  }

  Future<int> _syncGames(String userId) async {
    int count = 0;
    final localGames = await _db.getAllGames();

    // 1. Upload local games
    for (final game in localGames) {
      final existing = await _client
          .from('games')
          .select('id')
          .eq('user_id', userId)
          .eq('name', game.name)
          .maybeSingle();

      if (existing == null) {
        await _client.from('games').insert({
          'user_id': userId,
          'local_id': game.id,
          'name': game.name,
          'image_url': game.imagePath,
        });
        count++;
      }
    }

    // 2. Download remote games
    final List<dynamic> remoteGames = await _client
        .from('games')
        .select()
        .eq('user_id', userId);

    for (final item in remoteGames) {
      final remote = item as Map<String, dynamic>;
      final name = remote['name'] as String;
      final existingLocal = await _db.getGameByName(name);
      if (existingLocal == null) {
        final newGame = Game()
          ..name = name
          ..imagePath = remote['image_url'] as String?;
        await _db.saveGame(newGame);
        count++;
      }
    }

    return count;
  }

  Future<int> _syncMatches(String userId) async {
    int count = 0;
    final localMatches = await _db.getAllMatchRecords();

    // 1. Upload local matches
    for (final match in localMatches) {
      final gameName = match.game.value?.name ?? 'Unbekanntes Spiel';
      final matchDateUtcIso = match.date.toUtc().toIso8601String();

      // Check if match already uploaded by local_id or date
      final existing = await _client
          .from('matches')
          .select('id')
          .eq('user_id', userId)
          .eq('local_id', match.id)
          .maybeSingle();

      if (existing == null) {
        // Also check by date + game_name
        final existingByDate = await _client
            .from('matches')
            .select('id')
            .eq('user_id', userId)
            .eq('date', matchDateUtcIso)
            .eq('game_name', gameName)
            .maybeSingle();

        if (existingByDate == null) {
          final insertedMatch = await _client
              .from('matches')
              .insert({
                'user_id': userId,
                'local_id': match.id,
                'game_name': gameName,
                'date': matchDateUtcIso,
                'duration_minutes': 0,
                'latitude': match.latitude,
                'longitude': match.longitude,
              })
              .select('id')
              .single();

          final matchId = insertedMatch['id'] as String;

          for (final score in match.playerScores) {
            await _client.from('match_player_scores').insert({
              'match_id': matchId,
              'player_name': score.playerName ?? 'Spieler',
              'score': (score.score ?? 0).toDouble(),
              'is_winner': score.placement == 1,
              'rank': score.placement,
            });
          }
          count++;
        }
      }
    }

    // 2. Download remote matches
    // Reload local matches after upload
    final currentLocalMatches = await _db.getAllMatchRecords();

    final List<dynamic> remoteMatches = await _client
        .from('matches')
        .select('*, match_player_scores(*)')
        .eq('user_id', userId);

    for (final item in remoteMatches) {
      final remote = item as Map<String, dynamic>;
      final remoteLocalId = remote['local_id'] as num?;
      final remoteDateUtc = DateTime.parse(remote['date'] as String).toUtc();
      final gameName = remote['game_name'] as String;

      // Check if already present on this device by local_id
      if (remoteLocalId != null) {
        final matchWithId = currentLocalMatches.any((m) => m.id == remoteLocalId.toInt());
        if (matchWithId) {
          continue;
        }
      }

      // Check if already present on this device by date & game name (within 10 minutes)
      final matchWithTimeAndGame = currentLocalMatches.any((m) {
        final diffMinutes = (m.date.toUtc().difference(remoteDateUtc)).abs().inMinutes;
        return diffMinutes <= 10 && m.game.value?.name == gameName;
      });

      if (matchWithTimeAndGame) {
        continue;
      }

      var game = await _db.getGameByName(gameName);
      if (game == null) {
        game = Game()..name = gameName;
        await _db.saveGame(game);
      }

      final rawScores = (remote['match_player_scores'] as List<dynamic>?) ?? [];
      final scores = rawScores.map((s) {
        final sm = s as Map<String, dynamic>;
        return PlayerScore()
          ..playerName = sm['player_name'] as String?
          ..placement = (sm['rank'] as num?)?.toInt() ?? 1
          ..score = (sm['score'] as num?)?.toInt();
      }).toList();

      final newMatch = MatchRecord()
        ..date = remoteDateUtc.toLocal()
        ..numberOfPlayers = scores.isNotEmpty ? scores.length : 1
        ..latitude = (remote['latitude'] as num?)?.toDouble()
        ..longitude = (remote['longitude'] as num?)?.toDouble()
        ..playerScores = scores;

      newMatch.game.value = game;
      await _db.saveMatchRecord(newMatch);
      count++;
    }

    return count;
  }
}
