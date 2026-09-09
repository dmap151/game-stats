import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/player.dart';
import '../../l10n/l10n_extension.dart';
import '../../providers/providers.dart';
import '../../services/friends_service.dart';
import '../../services/sync_service.dart';
import '../widgets/auth_dialog.dart';
import '../widgets/backup_settings_dialog.dart';
import 'compare_players_screen.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final syncState = ref.watch(syncProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navAccount),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.manageDataTooltip,
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) => const BackupSettingsDialog(),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          if (user != null)
            _buildLoggedInContent(context, ref, theme, user, syncState)
          else
            _buildLoggedOutContent(context, ref, theme),
          const SizedBox(height: 20),
          _buildDuelsCard(context, theme),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLoggedInContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    User user,
    SyncState syncState,
  ) {
    final userEmail = user.email ?? 'Angemeldet';
    final userInitial = userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U';
    final lastSyncString = syncState.lastSyncTime != null
        ? DateFormat('dd.MM.yyyy HH:mm').format(syncState.lastSyncTime!)
        : 'Noch nicht synchronisiert';

    final myProfileAsync = ref.watch(myProfileProvider);
    final myPlayerAsync = ref.watch(myPlayerProvider);
    final friendsAsync = ref.watch(friendsListProvider);
    final allPlayers = ref.watch(playersProvider).value ?? [];

    return Column(
      children: [
        // 1. Profile Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
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
              Text(
                userEmail,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_done_rounded,
                      size: 16,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Supabase Cloud aktiv',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Friend Code Badge
              const SizedBox(height: 16),
              myProfileAsync.when(
                data: (profile) {
                  if (profile == null) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tag_rounded, size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dein Freundes-Code',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              profile.friendCode,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          tooltip: 'Code kopieren',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: profile.friendCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Freundes-Code in Zwischenablage kopiert!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Local Player Profile Card ("Ich")
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_pin_circle_rounded, color: theme.colorScheme.primary, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Mein lokales Spielerprofil',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Wähle aus, welcher lokale Spieler "Du" bist. Bei neuen Partien wirst du automatisch vorausgewählt.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              myPlayerAsync.when(
                data: (myPlayer) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: myPlayer?.imagePath != null
                              ? ClipOval(
                                  child: Image.file(
                                    File(myPlayer!.imagePath!),
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    cacheWidth: 100,
                                    gaplessPlayback: true,
                                  ),
                                )
                              : Text(
                                  myPlayer != null && myPlayer.name.isNotEmpty
                                      ? myPlayer.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                myPlayer?.name ?? 'Kein Profil ausgewählt',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                myPlayer != null ? 'Als "ICH" markiert' : 'Tippe zum Auswählen',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: myPlayer != null
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.tonal(
                          onPressed: () => _showSelectMyPlayerSheet(context, ref, allPlayers),
                          child: Text(myPlayer != null ? 'Ändern' : 'Auswählen'),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. Friends Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people_alt_rounded, color: theme.colorScheme.primary, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Freunde',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showAddFriendDialog(context, ref),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: const Text('Hinzufügen'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Füge Freunde über ihren Freundes-Code hinzu. Verknüpfe sie mit deinen lokalen Spielern, um Partien zu teilen.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              friendsAsync.when(
                data: (friends) {
                  if (friends.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.group_off_rounded,
                            size: 40,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Noch keine Freunde hinzugefügt',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tippe auf "Hinzufügen", um einen Freundes-Code einzugeben.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: friends.map((friend) {
                      final linkedPlayer = allPlayers.cast<Player?>().firstWhere(
                        (p) => p?.linkedUserId == friend.id,
                        orElse: () => null,
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: theme.colorScheme.secondaryContainer,
                              child: Text(
                                friend.displayName.isNotEmpty
                                    ? friend.displayName[0].toUpperCase()
                                    : 'F',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          friend.displayName,
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        friend.friendCode,
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    linkedPlayer != null
                                        ? 'Verknüpft: ${linkedPlayer.name}'
                                        : 'Nicht verknüpft',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: linkedPlayer != null
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                linkedPlayer != null ? Icons.link_rounded : Icons.link_off_rounded,
                                color: linkedPlayer != null
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              tooltip: linkedPlayer != null
                                  ? 'Verknüpfung verwalten'
                                  : 'Mit lokalem Spieler verknüpfen',
                              onPressed: () => _showLinkFriendSheet(
                                context,
                                ref,
                                friend,
                                linkedPlayer,
                                allPlayers,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.person_remove_outlined, size: 20),
                              color: theme.colorScheme.error,
                              tooltip: 'Freund entfernen',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Freund entfernen'),
                                    content: Text('${friend.displayName} wirklich aus deinen Freunden entfernen?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('Abbrechen'),
                                      ),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: theme.colorScheme.error,
                                        ),
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('Entfernen'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await ref.read(friendsServiceProvider).removeFriend(friend.id);
                                  if (linkedPlayer != null) {
                                    await ref.read(databaseProvider).unlinkPlayer(linkedPlayer.id);
                                  }
                                  ref.invalidate(friendsListProvider);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text(
                  'Fehler beim Laden der Freunde: $err',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 4. Sync Management Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.cloud_sync_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Online Synchronisation',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Zuletzt synchronisiert: $lastSyncString',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: syncState.status == SyncStatus.syncing
                      ? null
                      : () => ref.read(syncProvider.notifier).performSync(),
                  icon: syncState.status == SyncStatus.syncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.sync_rounded),
                  label: Text(
                    syncState.status == SyncStatus.syncing
                        ? 'Synchronisiere...'
                        : 'Jetzt synchronisieren',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    final db = ref.read(databaseProvider);
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
                  icon: const Icon(Icons.cleaning_services_outlined, size: 18),
                  label: const Text('Doppelte Partien bereinigen'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 5. Sign Out Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              await ref.read(supabaseServiceProvider).signOut();
              if (context.mounted) {
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
              side: BorderSide(
                color: theme.colorScheme.error.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text(
              'Abmelden',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  void _showSelectMyPlayerSheet(
    BuildContext context,
    WidgetRef ref,
    List<Player> allPlayers,
  ) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Wähle dein Spielerprofil',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Dies verknüpft deinen Account mit deinen Statistiken.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Divider(height: 24),
              if (allPlayers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Noch keine lokalen Spieler vorhanden.'),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: allPlayers.length,
                    itemBuilder: (context, index) {
                      final p = allPlayers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: p.imagePath != null
                              ? ClipOval(
                                  child: Image.file(
                                    File(p.imagePath!),
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                    cacheWidth: 100,
                                    gaplessPlayback: true,
                                  ),
                                )
                              : Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : '?'),
                        ),
                        title: Text(
                          p.name,
                          style: TextStyle(
                            fontWeight: p.isMe ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: p.isMe
                            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                            : null,
                        onTap: () async {
                          final db = ref.read(databaseProvider);
                          await db.setMyPlayer(p.id);
                          final user = ref.read(currentUserProvider);
                          if (user != null) {
                            p.linkedUserId = user.id;
                            await db.savePlayer(p);
                          }
                          ref.invalidate(myPlayerProvider);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context, WidgetRef ref) {
    final codeController = TextEditingController();
    bool isLoading = false;
    String? errorText;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Freund hinzufügen'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gib den Freundes-Code ein (z. B. #NAME-1234):'),
                const SizedBox(height: 14),
                TextField(
                  controller: codeController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: '#NAME-1234',
                    prefixIcon: const Icon(Icons.tag_rounded),
                    errorText: errorText,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(dialogCtx),
                child: const Text('Abbrechen'),
              ),
              FilledButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final code = codeController.text.trim();
                        if (code.isEmpty) {
                          setDialogState(() => errorText = 'Bitte Code eingeben');
                          return;
                        }

                        setDialogState(() {
                          isLoading = true;
                          errorText = null;
                        });

                        try {
                          final friendsService = ref.read(friendsServiceProvider);
                          final found = await friendsService.searchByFriendCode(code);
                          if (found == null) {
                            setDialogState(() {
                              isLoading = false;
                              errorText = 'Kein Spieler mit diesem Code gefunden.';
                            });
                            return;
                          }

                          await friendsService.addFriend(found.id);
                          ref.invalidate(friendsListProvider);

                          if (dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${found.displayName} wurde als Freund hinzugefügt!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() {
                            isLoading = false;
                            errorText = e.toString().replaceAll('Exception: ', '');
                          });
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Hinzufügen'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLinkFriendSheet(
    BuildContext context,
    WidgetRef ref,
    FriendProfile friend,
    Player? currentLinkedPlayer,
    List<Player> allPlayers,
  ) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${friend.displayName} verknüpfen',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Wähle einen lokalen Spieler aus oder erstelle einen neuen, der mit diesem Freund synchronisiert wird.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Divider(height: 24),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person_add_rounded),
                ),
                title: Text('Neuen Spieler für "${friend.displayName}" anlegen'),
                onTap: () async {
                  final db = ref.read(databaseProvider);
                  final newPlayer = Player()
                    ..name = friend.displayName
                    ..linkedUserId = friend.id
                    ..friendCode = friend.friendCode;
                  await db.savePlayer(newPlayer);
                  ref.invalidate(playersProvider);
                  ref.invalidate(friendsListProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              if (currentLinkedPlayer != null)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.errorContainer,
                    child: Icon(Icons.link_off_rounded, color: theme.colorScheme.onErrorContainer),
                  ),
                  title: Text('Verknüpfung mit "${currentLinkedPlayer.name}" aufheben'),
                  onTap: () async {
                    final db = ref.read(databaseProvider);
                    await db.unlinkPlayer(currentLinkedPlayer.id);
                    ref.invalidate(playersProvider);
                    ref.invalidate(friendsListProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              const Divider(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allPlayers.length,
                  itemBuilder: (context, index) {
                    final p = allPlayers[index];
                    final isLinked = p.id == currentLinkedPlayer?.id;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: p.imagePath != null
                            ? ClipOval(
                                child: Image.file(
                                  File(p.imagePath!),
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                  cacheWidth: 100,
                                  gaplessPlayback: true,
                                ),
                              )
                            : Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : '?'),
                      ),
                      title: Text(p.name),
                      subtitle: p.friendCode != null
                          ? Text('Bereits verknüpft mit ${p.friendCode}')
                          : null,
                      trailing: isLinked
                          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                          : null,
                      onTap: () async {
                        final db = ref.read(databaseProvider);
                        if (currentLinkedPlayer != null && currentLinkedPlayer.id != p.id) {
                          await db.unlinkPlayer(currentLinkedPlayer.id);
                        }
                        await db.linkPlayerToFriend(p.id, friend.id, friend.friendCode);
                        ref.invalidate(playersProvider);
                        ref.invalidate(friendsListProvider);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoggedOutContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primaryContainer,
            ),
            child: Icon(
              Icons.account_circle_outlined,
              size: 36,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Konto & Cloud-Sync',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Melde dich mit Google oder E-Mail an, um deine Partien, Spieler und Statistiken sicher online zu sichern.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => const AuthDialog(),
                );
              },
              icon: const Icon(Icons.login_rounded),
              label: const Text(
                'Anmelden / Registrieren',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuelsCard(BuildContext context, ThemeData theme) {
    return Material(
      color: theme.colorScheme.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.query_stats_rounded,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        title: const Text(
          'Duelle & Spielervergleich',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Head-to-Head Statistiken zweier Spieler anzeigen'),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const ComparePlayersScreen(),
            ),
          );
        },
      ),
    );
  }
}
