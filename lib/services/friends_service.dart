import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class FriendProfile {
  final String id;
  final String displayName;
  final String friendCode;
  final String? avatarUrl;

  const FriendProfile({
    required this.id,
    required this.displayName,
    required this.friendCode,
    this.avatarUrl,
  });

  factory FriendProfile.fromMap(Map<String, dynamic> map) {
    return FriendProfile(
      id: map['id'] as String,
      displayName: (map['display_name'] as String?) ?? 'Spieler',
      friendCode: (map['friend_code'] as String?) ?? '',
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}

class FriendRequest {
  final String id;
  final String userId;
  final String friendId;
  final String status;
  final DateTime createdAt;
  final FriendProfile profile;

  const FriendRequest({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.status,
    required this.createdAt,
    required this.profile,
  });
}

class FriendsService {
  final SupabaseService _supabase;

  FriendsService(this._supabase);

  SupabaseClient get _client => _supabase.client;

  /// Fetches the profile of the currently signed in user.
  Future<FriendProfile?> getMyProfile() async {
    final user = _supabase.currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data != null) {
      return FriendProfile.fromMap(data);
    }

    // Fallback: If trigger hasn't created profile yet, create one
    final name = user.userMetadata?['full_name'] as String? ??
        user.userMetadata?['name'] as String? ??
        (user.email?.split('@').first ?? 'Spieler');
    final code = '#${name.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '').padRight(4, 'X').substring(0, 4)}-${DateTime.now().millisecond.toString().padLeft(4, '0')}';

    final created = await _client
        .from('profiles')
        .insert({
          'id': user.id,
          'display_name': name,
          'friend_code': code,
          'avatar_url': user.userMetadata?['avatar_url'] as String?,
        })
        .select()
        .single();

    return FriendProfile.fromMap(created);
  }

  /// Updates the current user's profile display name or avatar.
  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    final user = _supabase.currentUser;
    if (user == null) return;
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (displayName != null && displayName.trim().isNotEmpty) {
      updates['display_name'] = displayName.trim();
    }
    if (avatarUrl != null) {
      updates['avatar_url'] = avatarUrl;
    }
    await _client.from('profiles').update(updates).eq('id', user.id);
  }

  /// Searches for a user profile by friend code (e.g. #DAVI-4821).
  Future<FriendProfile?> searchByFriendCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    final formatted = cleanCode.startsWith('#') ? cleanCode : '#$cleanCode';

    final data = await _client
        .from('profiles')
        .select()
        .eq('friend_code', formatted)
        .maybeSingle();

    if (data == null) return null;
    return FriendProfile.fromMap(data);
  }

  /// Sends a friend request with 'pending' status.
  /// Returns 'auto_accepted' if a reciprocal request was already pending,
  /// or 'pending' if a new request was created.
  Future<String> sendFriendRequest(String friendUserId) async {
    final user = _supabase.currentUser;
    if (user == null) throw Exception('not_authenticated');
    if (user.id == friendUserId) {
      throw Exception('self_request');
    }

    final List<dynamic> existing = await _client
        .from('friendships')
        .select()
        .or('and(user_id.eq.${user.id},friend_id.eq.$friendUserId),and(user_id.eq.$friendUserId,friend_id.eq.${user.id})');

    if (existing.isNotEmpty) {
      final rel = existing.first as Map<String, dynamic>;
      final status = rel['status'] as String;
      final senderId = rel['user_id'] as String;

      if (status == 'accepted') {
        throw Exception('already_friends');
      }
      if (senderId == user.id) {
        throw Exception('already_requested');
      } else {
        // Reciprocal request exists -> automatically accept
        await acceptFriendRequest(rel['id'] as String);
        return 'auto_accepted';
      }
    }

    await _client.from('friendships').insert({
      'user_id': user.id,
      'friend_id': friendUserId,
      'status': 'pending',
    });
    return 'pending';
  }

  /// Alias for sendFriendRequest for backward compatibility.
  Future<void> addFriend(String friendUserId) async {
    await sendFriendRequest(friendUserId);
  }

  /// Accepts a pending incoming friend request.
  Future<void> acceptFriendRequest(String friendshipId) async {
    final user = _supabase.currentUser;
    if (user == null) throw Exception('not_authenticated');
    await _client
        .from('friendships')
        .update({'status': 'accepted'})
        .eq('id', friendshipId);
  }

  /// Declines or cancels a friend request.
  Future<void> declineFriendRequest(String friendshipId) async {
    final user = _supabase.currentUser;
    if (user == null) throw Exception('not_authenticated');
    await _client
        .from('friendships')
        .delete()
        .eq('id', friendshipId);
  }

  /// Retrieves pending friend requests received by the current user.
  Future<List<FriendRequest>> getIncomingFriendRequests() async {
    final user = _supabase.currentUser;
    if (user == null) return [];

    final rawRows = await _client
        .from('friendships')
        .select()
        .eq('friend_id', user.id)
        .eq('status', 'pending');
    final rows = (rawRows as List).cast<Map<String, dynamic>>();

    if (rows.isEmpty) return [];

    final senderIds = rows.map((r) => r['user_id'] as String).toSet().toList();
    final rawProfiles = await _client
        .from('profiles')
        .select()
        .inFilter('id', senderIds);
    final profilesData = (rawProfiles as List).cast<Map<String, dynamic>>();

    final profilesMap = {
      for (final p in profilesData)
        p['id'] as String: FriendProfile.fromMap(p)
    };

    final results = <FriendRequest>[];
    for (final r in rows) {
      final senderId = r['user_id'] as String;
      final profile = profilesMap[senderId] ??
          FriendProfile(id: senderId, displayName: 'Spieler', friendCode: '');
      results.add(FriendRequest(
        id: r['id'] as String,
        userId: senderId,
        friendId: r['friend_id'] as String,
        status: r['status'] as String,
        createdAt: DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now(),
        profile: profile,
      ));
    }
    return results;
  }

  /// Retrieves pending friend requests sent by the current user.
  Future<List<FriendRequest>> getOutgoingFriendRequests() async {
    final user = _supabase.currentUser;
    if (user == null) return [];

    final rawRows = await _client
        .from('friendships')
        .select()
        .eq('user_id', user.id)
        .eq('status', 'pending');
    final rows = (rawRows as List).cast<Map<String, dynamic>>();

    if (rows.isEmpty) return [];

    final recipientIds = rows.map((r) => r['friend_id'] as String).toSet().toList();
    final rawProfiles = await _client
        .from('profiles')
        .select()
        .inFilter('id', recipientIds);
    final profilesData = (rawProfiles as List).cast<Map<String, dynamic>>();

    final profilesMap = {
      for (final p in profilesData)
        p['id'] as String: FriendProfile.fromMap(p)
    };

    final results = <FriendRequest>[];
    for (final r in rows) {
      final recipientId = r['friend_id'] as String;
      final profile = profilesMap[recipientId] ??
          FriendProfile(id: recipientId, displayName: 'Spieler', friendCode: '');
      results.add(FriendRequest(
        id: r['id'] as String,
        userId: r['user_id'] as String,
        friendId: recipientId,
        status: r['status'] as String,
        createdAt: DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now(),
        profile: profile,
      ));
    }
    return results;
  }

  /// Retrieves the list of accepted friends for the current user.
  Future<List<FriendProfile>> getFriends() async {
    final user = _supabase.currentUser;
    if (user == null) return [];

    final List<dynamic> sent = await _client
        .from('friendships')
        .select('friend_id')
        .eq('user_id', user.id)
        .eq('status', 'accepted');

    final List<dynamic> received = await _client
        .from('friendships')
        .select('user_id')
        .eq('friend_id', user.id)
        .eq('status', 'accepted');

    final friendIds = <String>{};
    for (final s in sent) {
      friendIds.add((s as Map<String, dynamic>)['friend_id'] as String);
    }
    for (final r in received) {
      friendIds.add((r as Map<String, dynamic>)['user_id'] as String);
    }

    if (friendIds.isEmpty) return [];

    final List<dynamic> profilesData = await _client
        .from('profiles')
        .select()
        .inFilter('id', friendIds.toList());

    return profilesData
        .map((p) => FriendProfile.fromMap(p as Map<String, dynamic>))
        .toList();
  }

  /// Removes a friendship or request.
  Future<void> removeFriend(String friendUserId) async {
    final user = _supabase.currentUser;
    if (user == null) return;

    await _client
        .from('friendships')
        .delete()
        .or('and(user_id.eq.${user.id},friend_id.eq.$friendUserId),and(user_id.eq.$friendUserId,friend_id.eq.${user.id})');
  }
}
