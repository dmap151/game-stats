import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/providers.dart';
import '../../services/sync_service.dart';

class UserProfileDialog extends ConsumerWidget {
  const UserProfileDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final syncState = ref.watch(syncProvider);

    if (user == null) {
      return const SizedBox.shrink();
    }

    final userEmail = user.email ?? 'Angemeldet';
    final userInitial = userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U';

    final lastSyncString = syncState.lastSyncTime != null
        ? DateFormat('dd.MM.yyyy HH:mm').format(syncState.lastSyncTime!)
        : 'Noch nicht synchronisiert';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  userInitial,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Email / User Info
              Text(
                userEmail,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Cloud-Konto aktiv',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sync Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_sync_rounded,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Supabase Sync',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Zuletzt: $lastSyncString',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (syncState.errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Fehler: ${syncState.errorMessage}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: syncState.status == SyncStatus.syncing
                            ? null
                            : () => ref.read(syncProvider.notifier).performSync(),
                        icon: syncState.status == SyncStatus.syncing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.sync_rounded, size: 20),
                        label: Text(
                          syncState.status == SyncStatus.syncing
                              ? 'Synchronisiere...'
                              : 'Jetzt synchronisieren',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final db = ref.read(databaseProvider);
                        await db.recoverLostMatchImagesAndData();
                        final deleted = await db.deduplicateMatchRecords();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                deleted > 0
                                    ? '$deleted doppelte Partien entfernt.'
                                    : 'Keine Duplikate vorhanden.',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.cleaning_services_outlined, size: 16),
                      label: const Text('Doppelte Partien bereinigen', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Sign Out Button
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(supabaseServiceProvider).signOut();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erfolgreich abgemeldet.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Abmelden'),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Schließen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
