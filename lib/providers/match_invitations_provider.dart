import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/match_invitation_service.dart';
import 'providers.dart';

final matchInvitationServiceProvider = Provider<MatchInvitationService>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  final db = ref.watch(databaseProvider);
  final storage = ref.watch(storageServiceProvider);
  return MatchInvitationService(supabase, db, storage);
});

final pendingMatchInvitationsProvider = FutureProvider<List<MatchInvitation>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final service = ref.watch(matchInvitationServiceProvider);
  return await service.getPendingMatchInvitations();
});
