import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../data/models/player.dart';
import '../services/friends_service.dart';
import 'providers.dart';

final friendsServiceProvider = Provider<FriendsService>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return FriendsService(supabase);
});

final myProfileProvider = FutureProvider<FriendProfile?>((ref) async {
  final service = ref.watch(friendsServiceProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return await service.getMyProfile();
});

final friendsListProvider = FutureProvider<List<FriendProfile>>((ref) async {
  final service = ref.watch(friendsServiceProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return await service.getFriends();
});

/// Streams the local player marked as "Me", or null if not yet selected.
final myPlayerProvider = StreamProvider<Player?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.isar.players
      .filter()
      .isMeEqualTo(true)
      .watch(fireImmediately: true)
      .map((list) => list.isEmpty ? null : list.first);
});
