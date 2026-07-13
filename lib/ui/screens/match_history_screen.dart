import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/providers.dart';
import 'game_details_screen.dart';

class MatchHistoryScreen extends ConsumerWidget {
  const MatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchRecordsAsync = ref.watch(matchRecordsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesamte Historie'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: matchRecordsAsync.when(
        data: (records) {
          if (records.isEmpty) {
            return Center(
              child: Text(
                'Noch keine Partien eingetragen.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          final sortedRecords = List.of(records)
            ..sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: sortedRecords.length,
            itemBuilder: (context, index) {
              final match = sortedRecords[index];
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
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Fehler beim Laden der Historie')),
      ),
    );
  }
}
