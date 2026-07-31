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
import '../widgets/match_record_tile.dart';
import '../widgets/player_ranking_card.dart';
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
            
            final chronologicalGameRecords = List.of(gameRecords)..sort((a, b) => a.date.compareTo(b.date));
            final matchIndices = <int, int>{};
            for (int i = 0; i < chronologicalGameRecords.length; i++) {
              matchIndices[chronologicalGameRecords[i].id] = i + 1;
            }
            
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
                          return MatchRecordTile(
                            record: r,
                            game: widget.game,
                            matchIndex: matchIndices[r.id] ?? 1,
                            getPlayer: getPlayer,
                            onEdit: () => _editMatch(r),
                            onDelete: () => _deleteMatch(r),
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

                        return PlayerRankingCard(
                          playerId: playerId,
                          playerName: playerName,
                          playerInfo: pInfo,
                          wins: wins,
                          matches: matches,
                          winRate: winRate,
                          rank: index + 1,
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
