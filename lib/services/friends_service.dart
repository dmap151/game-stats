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

  /// Adds a friend by creating a friendship entry.
  Future<void> addFriend(String friendUserId) async {
    final user = _supabase.currentUser;
    if (user == null) throw Exception('Nicht angemeldet.');
    if (user.id == friendUserId) {
      throw Exception('Du kannst dich nicht selbst als Freund hinzufügen.');
    }

    await _client.from('friendships').upsert({
      'user_id': user.id,
      'friend_id': friendUserId,
      'status': 'accepted',
    });
  }

  /// Retrieves the list of all friends for the current user.
  Future<List<FriendProfile>> getFriends() async {
    final user = _supabase.currentUser;
    if (user == null) return [];

    // Query friendships where user is either user_id or friend_id
    final List<dynamic> sent = await _client
        .from('friendships')
        .select('friend_id')
        .eq('user_id', user.id);

    final List<dynamic> received = await _client
        .from('friendships')
        .select('user_id')
        .eq('friend_id', user.id);

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
        .filter('id', 'in', friendIds.toList());

    return profilesData
        .map((p) => FriendProfile.fromMap(p as Map<String, dynamic>))
        .toList();
  }

  /// Removes a friendship.
  Future<void> removeFriend(String friendUserId) async {
    final user = _supabase.currentUser;
    if (user == null) return;

    await _client
        .from('friendships')
        .delete()
        .or('and(user_id.eq.${user.id},friend_id.eq.$friendUserId),and(user_id.eq.$friendUserId,friend_id.eq.${user.id})');
  }
}
