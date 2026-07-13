import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/providers.dart';
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
                  final baseGameName = match.game.value?.name ?? 'Unbekanntes Spiel';
                  final gameName = '$baseGameName #$matchIndex';
                  final winner = match.playerScores.where((p) => p.placement == 1).firstOrNull;
                  
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    child: ListTile(
                      leading: match.imagePath != null
                          ? ClipOval(
                              child: Image.file(
                                File(match.imagePath!),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                cacheWidth: 100,
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              child: const Icon(Icons.history),
                            ),
                      title: Text(gameName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${DateFormat('dd.MM.yyyy').format(match.date)} • ${winner != null ? '${winner.playerName} hat gewonnen' : 'Unentschieden'}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        if (match.game.value != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameDetailsScreen(game: match.game.value!),
                            ),
                          );
                        }
                      },
                    ),
                  );
                }),
                if (recentMatches.length > 10) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
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
            error: (_, __) => const Center(child: Text('Fehler beim Laden der Partien')),
          ),
        ],
      ),
    );
  }
}
