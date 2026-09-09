import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';

/// Provider for the Supabase authentication & database service.
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

/// Stream provider for reactive Supabase authentication state.
final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.onAuthStateChange;
});

/// Provider for the currently authenticated Supabase user (or null if not logged in).
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.session?.user ??
      ref.watch(supabaseServiceProvider).currentUser;
});
