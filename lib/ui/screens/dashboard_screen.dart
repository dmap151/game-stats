import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n_extension.dart';
import '../../providers/providers.dart';
import '../../utils/game_image_helper.dart';
import '../widgets/backup_settings_dialog.dart';
import '../widgets/match_preview_card.dart';
import '../widgets/stat_card.dart';
import 'game_details_screen.dart';
import 'match_history_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stats = ref.watch(playerStatisticsProvider);
    final matchRecordsAsync = ref.watch(matchRecordsProvider);
    final theme = Theme.of(context);
    final records = matchRecordsAsync.value ?? const [];
    final mostPlayedGame = stats.mostPlayedGame;
    final mostPlayedImage = mostPlayedGame != null
        ? GameImageHelper.getDisplayImage(mostPlayedGame, records)
        : null;

    final totalMatchesCard = StatCard(
      title: l10n.matchesPlayed,
      value: stats.totalMatchesPlayed.toString(),
      subtitle: stats.totalMatchesPlayed == 0
          ? l10n.noMatchesRecorded
          : l10n.totalRecorded,
      icon: Icons.casino_outlined,
      color: theme.colorScheme.primary,
      valueStyle: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );

    final mostPlayedGameCard = StatCard(
      title: l10n.mostPlayedGame,
      value: mostPlayedGame?.name ?? l10n.noMatchesYet,
      subtitle: mostPlayedGame != null
          ? l10n.matchesPlayedCount(stats.mostPlayedGameMatches)
          : null,
      color: theme.colorScheme.secondary,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.secondary.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: mostPlayedImage != null
              ? ClipOval(
                  child: Image.file(
                    File(mostPlayedImage),
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    cacheWidth: 120,
                    gaplessPlayback: true,
                  ),
                )
              : Icon(
                  Icons.favorite_outline,
                  color: theme.colorScheme.onSecondaryContainer,
                  size: 22,
                ),
        ),
      ),
      trailing: mostPlayedGame != null
          ? Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: theme.colorScheme.secondary,
              ),
            )
          : null,
      onTap: mostPlayedGame != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => GameDetailsScreen(
                    game: mostPlayedGame,
                  ),
                ),
              );
            }
          : null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navDashboard),
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
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            l10n.globalStatistics,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 600) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: totalMatchesCard),
                    const SizedBox(width: 16),
                    Expanded(child: mostPlayedGameCard),
                  ],
                );
              }
              return Column(
                children: [
                  totalMatchesCard,
                  const SizedBox(height: 12),
                  mostPlayedGameCard,
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            l10n.recentlyPlayed,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          
          matchRecordsAsync.when(
            data: (records) {
              if (records.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      l10n.noMatchesRecordedPrompt,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              final chronologicalRecords = List.of(records)
                ..sort((a, b) => a.date.compareTo(b.date));
                
              final matchIndices = <int, int>{};
              final gameCounts = <int, int>{};
              for (final r in chronologicalRecords) {
                final gameId = r.game.value?.id;
                if (gameId != null) {
                  final count = (gameCounts[gameId] ?? 0) + 1;
                  gameCounts[gameId] = count;
                  matchIndices[r.id] = count;
                }
              }

              final recentMatches = List.of(chronologicalRecords.reversed);
              final displayMatches = recentMatches.take(10).toList();

              return Column(
                children: [
                  ...displayMatches.map((match) {
                  final matchIndex = matchIndices[match.id] ?? 1;

                  
                  return MatchPreviewCard(
                    match: match,
                    matchIndex: matchIndex,
                  );
                }),
                if (recentMatches.length > 10) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const MatchHistoryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: Text(l10n.viewFullHistory),
                  ),
                ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(child: Text(l10n.errorLoadingMatches)),
          ),
        ],
      ),
    );
  }
}
