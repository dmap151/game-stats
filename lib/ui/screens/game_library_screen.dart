import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/game.dart';
import '../../providers/providers.dart';
import '../../utils/game_image_helper.dart';
import '../widgets/full_screen_image_viewer.dart';
import 'game_details_screen.dart';

class GameLibraryScreen extends ConsumerWidget {
  const GameLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchRecordsAsync = ref.watch(matchRecordsProvider);
    final gamesAsync = ref.watch(gamesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiele-Bibliothek'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: matchRecordsAsync.when(
        data: (records) {
          // Extrahiere alle Spiele mit ihren Match-Counts
          final Map<int, Game> gamesMap = {};
          final Map<int, int> gameMatchCounts = {};

          if (gamesAsync.value != null) {
            for (var g in gamesAsync.value!) {
              gamesMap[g.id] = g;
            }
          }

          for (var record in records) {
            final game = record.game.value;
            if (game != null) {
              gamesMap[game.id] = game;
              gameMatchCounts[game.id] = (gameMatchCounts[game.id] ?? 0) + 1;
            }
          }

          // Nur Spiele anzeigen, die mindestens 1 Partie haben
          final gamesList = gamesMap.values
              .where((g) => (gameMatchCounts[g.id] ?? 0) > 0)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));

          if (gamesList.isEmpty) {
            return Center(
              child: Text(
                'Noch keine Spiele in der Bibliothek.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          // Bilder vorab in einem schnellen Durchlauf auflösen
          final gameImages = GameImageHelper.resolveGameImages(gamesList, records);

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: gamesList.length,
            itemBuilder: (context, index) {
              final game = gamesList[index];
              final matchesCount = gameMatchCounts[game.id] ?? 0;
              final imagePath = gameImages[game.id];

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: GestureDetector(
                    onTap: () {
                      if (imagePath != null) {
                        FullScreenImageViewer.show(
                          context,
                          File(imagePath),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => GameDetailsScreen(game: game),
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: imagePath != null
                          ? ClipOval(
                              child: Image.file(
                                File(imagePath),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                cacheWidth: 120,
                                gaplessPlayback: true,
                                filterQuality: FilterQuality.low,
                              ),
                            )
                          : Icon(
                              Icons.casino,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                    ),
                  ),
                  title: Text(
                    game.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('$matchesCount ${matchesCount == 1 ? 'Partie' : 'Partien'} gespielt'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
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
        error: (_, _) =>
            const Center(child: Text('Fehler beim Laden der Bibliothek')),
      ),
    );
  }
}
