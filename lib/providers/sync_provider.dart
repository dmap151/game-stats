import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sync_service.dart';
import 'providers.dart';

final syncServiceProvider = Provider<SyncService?>((ref) {
  try {
    final db = ref.watch(databaseProvider);
    final supabase = ref.watch(supabaseServiceProvider);
    return SyncService(db, supabase);
  } catch (_) {
    return null;
  }
});

class SyncNotifier extends StateNotifier<SyncState> {
  final SyncService? _syncService;

  SyncNotifier(this._syncService) : super(const SyncState());

  Future<void> performSync() async {
    if (_syncService == null) return;
    if (state.status == SyncStatus.syncing) return;

    state = state.copyWith(status: SyncStatus.syncing, errorMessage: null);

    try {
      final count = await _syncService.syncAll();
      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncTime: DateTime.now(),
        syncedCount: count,
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return SyncNotifier(syncService);
});
