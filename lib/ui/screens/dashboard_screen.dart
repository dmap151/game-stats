import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../widgets/stat_card.dart';
import '../widgets/match_preview_card.dart';
import 'match_history_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(playerStatisticsProvider);
    final matchRecordsAsync = ref.watch(matchRecordsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Globale Statistiken',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Partien gespielt',
                  value: stats.totalMatchesPlayed.toString(),
                  icon: Icons.casino_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Häufigstes Spiel',
                  value: stats.mostPlayedGame?.name ?? '-',
                  icon: Icons.favorite_outline,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
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
