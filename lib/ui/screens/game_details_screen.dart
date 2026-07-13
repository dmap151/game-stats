import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/game.dart';
import '../../data/models/match_record.dart';
import '../../data/models/player.dart';
import '../../providers/providers.dart';
import '../widgets/score_chart.dart';
import '../widgets/full_screen_image_viewer.dart';
import 'match_entry_screen.dart';

enum SortMode { dateDesc, dateAsc }

class GameDetailsScreen extends ConsumerStatefulWidget {
  final Game game;

  const GameDetailsScreen({
    super.key,
    required this.game,
  });

  @override
  ConsumerState<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends ConsumerState<GameDetailsScreen> {
  SortMode _sortMode = SortMode.dateDesc;

  List<MatchRecord> _sortRecords(List<MatchRecord> records) {
    final sorted = List<MatchRecord>.from(records);
    switch (_sortMode) {
      case SortMode.dateDesc:
        sorted.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortMode.dateAsc:
        sorted.sort((a, b) => a.date.compareTo(b.date));
        break;
    }
    return sorted;
  }

  void _deleteMatch(MatchRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Partie löschen?'),
        content: const Text('Möchtest du diese Partie wirklich unwiderruflich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final db = ref.read(databaseProvider);
      await db.deleteMatchRecord(record.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partie wurde gelöscht.')),
        );
      }
    }
  }

  void _editMatch(MatchRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchEntryScreen(existingMatch: record),
      ),
    );
  }

  Widget _buildImageThumbnail(BuildContext context, String path, String heroTag) {
    return GestureDetector(
      onTap: () {
        FullScreenImageViewer.show(context, File(path), heroTag);
      },
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(path),
            height: 150,
            width: 150,
            fit: BoxFit.cover,
            cacheWidth: 400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchRecordsAsync = ref.watch(matchRecordsProvider);
    final playersAsync = ref.watch(playersProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.game.name),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Historie & Chart'),
              Tab(text: 'Spieler-Ranking'),
            ],
          ),
        ),
        body: matchRecordsAsync.when(
          data: (records) {
            final gameRecords = records.where((r) => r.game.value?.id == widget.game.id).toList();
            
            if (gameRecords.isEmpty) {
              return const Center(child: Text('Keine Statistiken verfügbar.'));
            }

            final sortedRecords = _sortRecords(gameRecords);
            
            // Calculate Player Rankings (using Player ID to accurately map to pictures)
            final playerWins = <int, int>{};
            final playerMatches = <int, int>{};
            final playerNames = <int, String>{};

            for (var r in gameRecords) {
              for (var score in r.playerScores) {
                final id = score.playerId ?? -1;
                playerNames[id] = score.playerName ?? 'Unbekannt';
                playerMatches[id] = (playerMatches[id] ?? 0) + 1;
                if (score.placement == 1) {
                  playerWins[id] = (playerWins[id] ?? 0) + 1;
                }
              }
            }
            final rankingList = playerMatches.keys.toList()
              ..sort((a, b) => (playerWins[b] ?? 0).compareTo(playerWins[a] ?? 0));

            return playersAsync.when(
              data: (allPlayers) {
                Player? getPlayer(int id) => allPlayers.where((p) => p.id == id).firstOrNull;

                return TabBarView(
                  children: [
                    // TAB 1: Historie
                    ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        Text('Höchste Punkte Verlauf', style: theme.textTheme.headlineMedium),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 0,
                          color: theme.colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ScoreChart(records: gameRecords),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Partien', style: theme.textTheme.headlineMedium),
                            DropdownButton<SortMode>(
                              value: _sortMode,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(value: SortMode.dateDesc, child: Text('Neueste zuerst')),
                                DropdownMenuItem(value: SortMode.dateAsc, child: Text('Älteste zuerst')),
                              ],
                              onChanged: (mode) {
                                if (mode != null) {
                                  setState(() => _sortMode = mode);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...sortedRecords.map((r) {
                          // Find winner
                          final winner = r.playerScores.where((p) => p.placement == 1).firstOrNull;
                          return Card(
                            elevation: 0,
                            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.secondary,
                                child: const Icon(Icons.emoji_events, color: Colors.white, size: 20),
                              ),
                              title: Row(
                                children: [
                                  Expanded(child: Text(winner != null ? '${winner.playerName} hat gewonnen' : 'Unentschieden')),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') _editMatch(r);
                                      if (value == 'delete') _deleteMatch(r);
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: ListTile(
                                          leading: Icon(Icons.edit),
                                          title: Text('Bearbeiten'),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: ListTile(
                                          leading: Icon(Icons.delete, color: Colors.red),
                                          title: Text('Löschen', style: TextStyle(color: Colors.red)),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                '${DateFormat('dd.MM.yyyy').format(r.date)} - ${r.numberOfPlayers} Spieler',
                              ),
                              children: [
                                if (r.imagePath != null || r.imagePaths.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          if (r.imagePath != null) ...[
                                            _buildImageThumbnail(context, r.imagePath!, 'match_${r.id}_0'),
                                            const SizedBox(width: 8),
                                          ],
                                          ...r.imagePaths.asMap().entries.map((entry) {
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: _buildImageThumbnail(context, entry.value, 'match_${r.id}_${entry.key + 1}'),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ...((r.playerScores.toList()..sort((a, b) => a.placement.compareTo(b.placement))).map((ps) {
                                  final pInfo = getPlayer(ps.playerId ?? -1);
                                  return ListTile(
                                    leading: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: theme.colorScheme.primaryContainer,
                                      backgroundImage: pInfo?.imagePath != null ? FileImage(File(pInfo!.imagePath!)) : null,
                                      child: pInfo?.imagePath == null 
                                        ? Text(ps.playerName?.isNotEmpty == true ? ps.playerName!.substring(0, 1).toUpperCase() : '?') 
                                        : null,
                                    ),
                                    title: Text(ps.playerName ?? 'Unbekannt'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('${ps.score} Punkte', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.secondaryContainer,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '#${ps.placement}',
                                            style: TextStyle(
                                              color: theme.colorScheme.onSecondaryContainer,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList()),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                    
                    // TAB 2: Ranking
                    ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: rankingList.length,
                      itemBuilder: (context, index) {
                        final playerId = rankingList[index];
                        final pInfo = getPlayer(playerId);
                        final playerName = playerNames[playerId] ?? 'Unbekannt';
                        final wins = playerWins[playerId] ?? 0;
                        final matches = playerMatches[playerId] ?? 0;
                        final winRate = (wins / matches) * 100;

                        return Card(
                          elevation: 0,
                          color: index == 0 ? theme.colorScheme.primaryContainer.withOpacity(0.3) : theme.colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                          ),
                          child: ListTile(
                            leading: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (pInfo?.imagePath != null) {
                                      FullScreenImageViewer.show(context, File(pInfo!.imagePath!), 'ranking_player_${pInfo.id}');
                                    }
                                  },
                                  child: Hero(
                                    tag: 'ranking_player_${pInfo?.id ?? playerId}',
                                    child: CircleAvatar(
                                      backgroundColor: index == 0 ? theme.colorScheme.secondary : theme.colorScheme.primaryContainer,
                                      backgroundImage: pInfo?.imagePath != null ? FileImage(File(pInfo!.imagePath!)) : null,
                                      child: pInfo?.imagePath == null 
                                        ? Text(playerName.substring(0, 1).toUpperCase()) 
                                        : null,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -5,
                                  right: -5,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: theme.colorScheme.outlineVariant),
                                    ),
                                    child: Text(
                                      '#${index + 1}',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: Text(playerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('$matches gespielte Partien'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('$wins Siege', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                                Text('${winRate.toStringAsFixed(1)}% Win Rate', style: theme.textTheme.labelSmall),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Fehler beim Laden der Spieler')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Fehler beim Laden der Statistiken.')),
        ),
      ),
    );
  }
}
