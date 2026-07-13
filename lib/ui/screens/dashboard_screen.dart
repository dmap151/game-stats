import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/providers.dart';
import '../widgets/stat_card.dart';
import 'game_details_screen.dart';

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

              // Sort matches by date descending and take the top 10
              final recentMatches = List.of(records)
                ..sort((a, b) => b.date.compareTo(a.date));
              final displayMatches = recentMatches.take(10).toList();

              return Column(
                children: displayMatches.map((match) {
                  final gameName = match.game.value?.name ?? 'Unbekanntes Spiel';
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
                }).toList(),
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
