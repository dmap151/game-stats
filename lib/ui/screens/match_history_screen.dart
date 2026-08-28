import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../widgets/match_preview_card.dart';

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

          final sortedRecords = List.of(chronologicalRecords.reversed);

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: sortedRecords.length,
            itemBuilder: (context, index) {
              final match = sortedRecords[index];
              final matchIndex = matchIndices[match.id] ?? 1;

              return MatchPreviewCard(
                match: match,
                matchIndex: matchIndex,
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
