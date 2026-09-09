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
    final l10n = context.l10n;
    final userEmail = user.email ?? l10n.accountLoggedInStatus;
    final userInitial = userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U';
    final lastSyncString = syncState.lastSyncTime != null
        ? DateFormat('dd.MM.yyyy HH:mm').format(syncState.lastSyncTime!)
        : l10n.syncNever;

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
                      l10n.cloudActive,
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
                              l10n.yourFriendCode,
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
                          tooltip: l10n.copyCodeTooltip,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: profile.friendCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.friendCodeCopied),
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
                    l10n.myLocalProfileTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.myLocalProfileDescription,
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
                                myPlayer?.name ?? l10n.noProfileSelected,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                myPlayer != null ? l10n.markedAsMe : l10n.tapToSelect,
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
                          child: Text(myPlayer != null ? l10n.change : l10n.select),
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
                        l10n.friendsSectionTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showAddFriendDialog(context, ref),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: Text(l10n.add),
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
                l10n.friendsSectionDescription,
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
                            l10n.noFriendsYet,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.noFriendsPrompt,
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
                                        ? l10n.linkedPlayer(linkedPlayer.name)
                                        : l10n.notLinked,
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
                                  ? l10n.manageLinkTooltip
                                  : l10n.linkToLocalPlayerTooltip,
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
                              tooltip: l10n.remove,
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(l10n.removeFriendTitle),
                                    content: Text(l10n.removeFriendPrompt(friend.displayName)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: Text(l10n.cancel),
                                      ),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: theme.colorScheme.error,
                                        ),
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: Text(l10n.remove),
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
                    l10n.syncSectionTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.lastSyncedAt(lastSyncString),
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
                        ? l10n.syncing
                        : l10n.syncNow,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    final db = ref.read(databaseProvider);
                    await db.recoverLostMatchImagesAndData();
                    final deleted = await db.deduplicateMatchRecords();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            deleted > 0
                                ? l10n.duplicatesRemoved(deleted)
                                : l10n.noDuplicatesFound,
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.cleaning_services_outlined, size: 18),
                  label: Text(l10n.cleanDuplicates),
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
                  SnackBar(
                    content: Text(l10n.signOutSuccess),
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
            label: Text(
              l10n.signOut,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
    final l10n = context.l10n;
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
                l10n.selectMyPlayerTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.selectMyPlayerSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Divider(height: 24),
              if (allPlayers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(l10n.noLocalPlayersYet),
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
                          final user = ref.read(currentUserProvider);
                          final myProfile = ref.read(myProfileProvider).value;
                          await db.setMyPlayer(
                            p.id,
                            linkedUserId: user?.id,
                            friendCode: myProfile?.friendCode,
                          );
                          if (user != null) {
                            try {
                              final friendsService = ref.read(friendsServiceProvider);
                              await friendsService.updateProfile(displayName: p.name);
                              ref.invalidate(myProfileProvider);
                            } catch (_) {}
                          }
                          ref.invalidate(myPlayerProvider);
                          ref.invalidate(playersProvider);
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
    final l10n = context.l10n;
    final codeController = TextEditingController();
    bool isLoading = false;
    String? errorText;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(l10n.addFriend),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.enterFriendCodePrompt),
                const SizedBox(height: 14),
                TextField(
                  controller: codeController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: '#NAME-1234',
                    labelText: l10n.friendCodeLabel,
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
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final code = codeController.text.trim();
                        if (code.isEmpty) {
                          setDialogState(() => errorText = l10n.invalidOrOwnFriendCode);
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
                              errorText = l10n.friendNotFound;
                            });
                            return;
                          }

                          await friendsService.addFriend(found.id);
                          ref.invalidate(friendsListProvider);

                          if (dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.friendAddedSuccess),
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
                    : Text(l10n.add),
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
    final l10n = context.l10n;
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
                l10n.linkFriendTitle(friend.displayName),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.linkFriendDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Divider(height: 24),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person_add_rounded),
                ),
                title: Text(l10n.createNewPlayerFor(friend.displayName)),
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
                  title: Text(l10n.unlinkPlayerFrom(currentLinkedPlayer.name)),
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
                          ? Text(l10n.alreadyLinkedWith(p.friendCode!))
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
    final l10n = context.l10n;
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
            l10n.cloudAndFriendsTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.cloudAndFriendsDescription,
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
              label: Text(
                l10n.signInOrRegister,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
    final l10n = context.l10n;
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
        title: Text(
          l10n.duelsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(l10n.duelsSubtitle),
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
