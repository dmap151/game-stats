import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final stats = ref.watch(playerStatisticsProvider);
    final matchRecordsAsync = ref.watch(matchRecordsProvider);
    final theme = Theme.of(context);
    final records = matchRecordsAsync.value ?? const [];
    final mostPlayedGame = stats.mostPlayedGame;
    final mostPlayedImage = mostPlayedGame != null
        ? GameImageHelper.getDisplayImage(mostPlayedGame, records)
        : null;

    final totalMatchesCard = StatCard(
      title: 'Partien gespielt',
      value: stats.totalMatchesPlayed.toString(),
      subtitle: stats.totalMatchesPlayed == 0
          ? 'Noch keine Partien erfasst'
          : 'Insgesamt erfasst',
      icon: Icons.casino_outlined,
      color: theme.colorScheme.primary,
      valueStyle: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );

    final mostPlayedGameCard = StatCard(
      title: 'Häufigstes Spiel',
      value: mostPlayedGame?.name ?? 'Noch keine Partien',
      subtitle: mostPlayedGame != null
          ? '${stats.mostPlayedGameMatches} ${stats.mostPlayedGameMatches == 1 ? 'Partie' : 'Partien'} gespielt'
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
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync_outlined),
            tooltip: 'Daten sichern & importieren',
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
            'Globale Statistiken',
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
            'Zuletzt gespielt',
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
                      'Noch keine Partien eingetragen.',
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
                    label: const Text('Gesamte Historie ansehen'),
                  ),
                ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Center(child: Text('Fehler beim Laden der Partien')),
          ),
        ],
      ),
    );
  }
}
