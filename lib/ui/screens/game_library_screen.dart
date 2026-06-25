import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/game.dart';
import '../../providers/providers.dart';
import 'game_details_screen.dart';

class GameLibraryScreen extends ConsumerWidget {
  const GameLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchRecordsAsync = ref.watch(matchRecordsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiele-Bibliothek'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: matchRecordsAsync.when(
        data: (records) {
          if (records.isEmpty) {
            return Center(
              child: Text(
                'Noch keine Spiele in der Bibliothek.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          // Extrahiere alle eindeutigen Spiele aus den Matches
          final Map<int, Game> uniqueGames = {};
          final Map<int, int> gameMatchCounts = {};
          for (var record in records) {
            final game = record.game.value;
            if (game != null) {
              if (!uniqueGames.containsKey(game.id)) {
                uniqueGames[game.id] = game;
              }
              gameMatchCounts[game.id] = (gameMatchCounts[game.id] ?? 0) + 1;
            }
          }

          final gamesList = uniqueGames.values.toList()
            ..sort((a, b) => a.name.compareTo(b.name));

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: gamesList.length,
            itemBuilder: (context, index) {
              final game = gamesList[index];
              final matchesCount = gameMatchCounts[game.id] ?? 0;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    child: const Icon(Icons.casino),
                  ),
                  title: Text(
                    game.name,
                    style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18),
                  ),
                  subtitle: Text('$matchesCount Partien gespielt'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameDetailsScreen(game: game),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Fehler beim Laden der Bibliothek')),
      ),
    );
  }
}
