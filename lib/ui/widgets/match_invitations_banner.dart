import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n_extension.dart';
import '../../providers/providers.dart';
import '../../services/match_invitation_service.dart';

class MatchInvitationsBanner extends ConsumerStatefulWidget {
  const MatchInvitationsBanner({super.key});

  @override
  ConsumerState<MatchInvitationsBanner> createState() => _MatchInvitationsBannerState();
}

class _MatchInvitationsBannerState extends ConsumerState<MatchInvitationsBanner> {
  final Set<String> _processingIds = {};
  final Set<String> _dismissedIds = {};

  @override
  Widget build(BuildContext context) {
    final invitationsAsync = ref.watch(pendingMatchInvitationsProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return invitationsAsync.when(
      data: (invitations) {
        final visibleInvitations = invitations
            .where((inv) => !_dismissedIds.contains(inv.matchId))
            .toList();
        if (visibleInvitations.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_unread_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.matchInvitationsTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${visibleInvitations.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // List of Invitations
              ...visibleInvitations.map((inv) => _buildInvitationCard(context, theme, inv)),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildInvitationCard(
    BuildContext context,
    ThemeData theme,
    MatchInvitation inv,
  ) {
    final l10n = context.l10n;
    final isProcessing = _processingIds.contains(inv.matchId);
    final dateString = DateFormat('dd.MM.yyyy').format(inv.date);
    final participantsString = inv.participants.map((p) => p.playerName).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo or Game Icon
              if (inv.imageUrl != null && inv.imageUrl!.startsWith('http'))
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    inv.imageUrl!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _buildGameIcon(theme),
                  ),
                )
              else
                _buildGameIcon(theme),
              const SizedBox(width: 12),

              // Title and Creator
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inv.gameName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      inv.creatorFriendCode.isNotEmpty
                          ? '${l10n.invitedBy(inv.creatorName)} (${inv.creatorFriendCode})'
                          : l10n.invitedBy(inv.creatorName),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Chips info: Date, Placement, Score
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildBadge(
                theme: theme,
                icon: Icons.calendar_today_rounded,
                text: dateString,
              ),
              _buildBadge(
                theme: theme,
                icon: Icons.emoji_events_rounded,
                text: l10n.yourPlacement(inv.myRank),
                color: inv.myRank == 1
                    ? Colors.amber.shade700
                    : theme.colorScheme.primary,
              ),
              if (inv.myScore != null)
                _buildBadge(
                  theme: theme,
                  icon: Icons.sports_score_rounded,
                  text: l10n.yourScore(inv.myScore!),
                ),
            ],
          ),

          if (participantsString.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '👥 $participantsString',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 14),

          // Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: isProcessing ? null : () => _declineInvitation(inv),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(
                    color: theme.colorScheme.error.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(l10n.declineMatch),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: isProcessing ? null : () => _acceptInvitation(inv),
                icon: isProcessing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                label: Text(l10n.acceptMatch),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameIcon(ThemeData theme) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.casino_rounded,
        color: theme.colorScheme.onPrimaryContainer,
        size: 26,
      ),
    );
  }

  Widget _buildBadge({
    required ThemeData theme,
    required IconData icon,
    required String text,
    Color? color,
  }) {
    final effectiveColor = color ?? theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: effectiveColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: effectiveColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptInvitation(MatchInvitation inv) async {
    final l10n = context.l10n;
    setState(() {
      _processingIds.add(inv.matchId);
      _dismissedIds.add(inv.matchId);
    });

    try {
      final service = ref.read(matchInvitationServiceProvider);
      await service.acceptMatchInvitation(inv);

      ref.invalidate(pendingMatchInvitationsProvider);
      ref.invalidate(matchRecordsProvider);
      ref.invalidate(playerStatisticsProvider);
      ref.invalidate(playersProvider);
      ref.invalidate(gamesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.matchInvitationAccepted),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _dismissedIds.remove(inv.matchId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processingIds.remove(inv.matchId));
      }
    }
  }

  Future<void> _declineInvitation(MatchInvitation inv) async {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.declineMatch),
        content: Text(l10n.declineMatchInvitationPrompt(inv.gameName)),
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
            child: Text(l10n.declineMatch),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _processingIds.add(inv.matchId);
      _dismissedIds.add(inv.matchId);
    });

    try {
      final service = ref.read(matchInvitationServiceProvider);
      await service.declineMatchInvitation(inv);

      ref.invalidate(pendingMatchInvitationsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.matchInvitationDeclined),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _dismissedIds.remove(inv.matchId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processingIds.remove(inv.matchId));
      }
    }
  }
}
