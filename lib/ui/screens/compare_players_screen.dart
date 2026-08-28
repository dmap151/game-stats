import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/player.dart';
import '../../providers/providers.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/head_to_head_provider.dart';
import 'game_details_screen.dart';
import '../widgets/match_preview_card.dart';
import '../widgets/full_screen_image_viewer.dart';

final comparePlayer1Provider = StateProvider<int?>((ref) => null);
final comparePlayer2Provider = StateProvider<int?>((ref) => null);

class ComparePlayersScreen extends ConsumerStatefulWidget {
  const ComparePlayersScreen({super.key});

  @override
  ConsumerState<ComparePlayersScreen> createState() =>
      _ComparePlayersScreenState();
}

class _ComparePlayersScreenState extends ConsumerState<ComparePlayersScreen> {
  static const _p1Key = 'compare_player1_id';
  static const _p2Key = 'compare_player2_id';

  @override
  void initState() {
    super.initState();
    _loadSavedPlayers();
  }

  Future<void> _loadSavedPlayers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final p1Id = prefs.getInt(_p1Key);
      final p2Id = prefs.getInt(_p2Key);

      // Only load from prefs if our memory state is currently empty
      if (ref.read(comparePlayer1Provider) == null &&
          ref.read(comparePlayer2Provider) == null) {
        if (p1Id != null)
          ref.read(comparePlayer1Provider.notifier).state = p1Id;
        if (p2Id != null)
          ref.read(comparePlayer2Provider.notifier).state = p2Id;
      }
    } catch (e) {
      debugPrint('SharedPreferences error: $e');
    }
  }

  Future<void> _savePlayer(int playerNum, int? pId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = playerNum == 1 ? _p1Key : _p2Key;
      if (pId == null) {
        await prefs.remove(key);
      } else {
        await prefs.setInt(key, pId);
      }
    } catch (e) {
      debugPrint('SharedPreferences error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(playersProvider);
    final theme = Theme.of(context);

    final p1Id = ref.watch(comparePlayer1Provider);
    final p2Id = ref.watch(comparePlayer2Provider);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Spieler Vergleich'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: playersAsync.when(
        data: (players) {
          if (players.isEmpty) {
            return const Center(child: Text('Keine Spieler verfügbar.'));
          }

          final player1 = players.firstWhereOrNull((p) => p.id == p1Id);
          final player2 = players.firstWhereOrNull((p) => p.id == p2Id);

          return Column(
            children: [
              // Player Selection Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPlayerSelector(1, player1, players, theme),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    _buildPlayerSelector(2, player2, players, theme),
                  ],
                ),
              ),
              const Divider(),
              // Stats Body
              Expanded(
                child: player1 != null && player2 != null
                    ? _buildStatsView(player1, player2, theme)
                    : const Center(
                        child: Text('Bitte wähle zwei Spieler aus.'),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Fehler beim Laden der Spieler')),
        ),
      ),
    );
  }

  Widget _buildPlayerSelector(
    int playerNum,
    Player? selectedPlayer,
    List<Player> allPlayers,
    ThemeData theme,
  ) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Autocomplete<String>(
            key: ValueKey('autocomplete_$playerNum'),
            initialValue: TextEditingValue(text: selectedPlayer?.name ?? ''),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return allPlayers.map((p) => p.name).toList();
              }
              return allPlayers.map((p) => p.name).where((String option) {
                return option.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                );
              }).toList();
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        final player = allPlayers.firstWhere(
                          (p) => p.name == option,
                        );
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  child: player.imagePath != null
                                      ? ClipOval(
                                          child: Image.file(
                                            File(player.imagePath!),
                                            width: 32,
                                            height: 32,
                                            fit: BoxFit.cover,
                                            cacheWidth: 100, // Fast loading
                                          ),
                                        )
                                      : Text(
                                          player.name
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            onSelected: (String selection) {
              final selectedP = allPlayers.firstWhereOrNull(
                (p) => p.name == selection,
              );
              if (selectedP != null) {
                final currentP1 = ref.read(comparePlayer1Provider);
                final currentP2 = ref.read(comparePlayer2Provider);

                if (playerNum == 1) {
                  ref.read(comparePlayer1Provider.notifier).state =
                      selectedP.id;
                  _savePlayer(1, selectedP.id);
                  if (currentP2 == selectedP.id) {
                    ref.read(comparePlayer2Provider.notifier).state = null;
                    _savePlayer(2, null);
                  }
                } else {
                  ref.read(comparePlayer2Provider.notifier).state =
                      selectedP.id;
                  _savePlayer(2, selectedP.id);
                  if (currentP1 == selectedP.id) {
                    ref.read(comparePlayer1Provider.notifier).state = null;
                    _savePlayer(1, null);
                  }
                }
              }
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
                  return ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, child) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: playerNum == 1 ? 'Spieler 1' : 'Spieler 2',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          suffixIcon: value.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    controller.clear();
                                    if (playerNum == 1) {
                                      ref.read(comparePlayer1Provider.notifier).state =
                                          null;
                                      _savePlayer(1, null);
                                    } else {
                                      ref.read(comparePlayer2Provider.notifier).state =
                                          null;
                                      _savePlayer(2, null);
                                    }
                                  },
                                )
                              : null,
                        ),
                        onFieldSubmitted: (_) => onFieldSubmitted(),
                        onChanged: (val) {
                          if (val.isEmpty) {
                            if (playerNum == 1) {
                              ref.read(comparePlayer1Provider.notifier).state =
                                  null;
                              _savePlayer(1, null);
                            } else {
                              ref.read(comparePlayer2Provider.notifier).state =
                                  null;
                              _savePlayer(2, null);
                            }
                          }
                        },
                      );
                    },
                  );
                },
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              if (selectedPlayer?.imagePath != null) {
                FullScreenImageViewer.show(
                  context,
                  File(selectedPlayer!.imagePath!),
                );
              }
            },
            child: CircleAvatar(
              radius: 36,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: selectedPlayer != null
                  ? (selectedPlayer.imagePath != null
                        ? ClipOval(
                            child: Image.file(
                              File(selectedPlayer.imagePath!),
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              cacheWidth: 180,
                              gaplessPlayback: true,
                            ),
                          )
                        : Text(
                            selectedPlayer.name.isNotEmpty
                                ? selectedPlayer.name
                                      .substring(0, 1)
                                      .toUpperCase()
                                : '?',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ))
                  : Icon(
                      Icons.person_outline,
                      size: 36,
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsView(Player p1, Player p2, ThemeData theme) {
    final stats = ref.watch(headToHeadStatsProvider((p1: p1.id, p2: p2.id)));

    if (stats.matchesTogether == 0) {
      return const Center(
        child: Text('Diese Spieler haben noch keine Spiele zusammen gespielt.'),
      );
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(16.0),
      children: [
        // Main Head to Head Score
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${stats.player1BetterCount}',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  ':',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${stats.player2BetterCount}',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Bessere Platzierung',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Data Table
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Detaillierte Stats', style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildStatRow(
                  'Gemeinsame Spiele',
                  '${stats.matchesTogether}',
                  '${stats.matchesTogether}',
                  theme,
                  isShared: true,
                ),
                const Divider(),
                _buildStatRow(
                  'Unentschieden',
                  '${stats.ties}',
                  '${stats.ties}',
                  theme,
                  isShared: true,
                ),
                const Divider(),
                _buildStatRow(
                  '1. Plätze (in gleichen Partien)',
                  '${stats.player1Wins}',
                  '${stats.player2Wins}',
                  theme,
                ),
                const Divider(),
                _buildStatRow(
                  'Durchschnittliche Platzierung',
                  stats.player1AveragePlacement.toStringAsFixed(1),
                  stats.player2AveragePlacement.toStringAsFixed(1),
                  theme,
                  invertGoodness: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Shared Matches List
        Center(
          child: Text(
            'Gemeinsame Spiele',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (stats.sharedMatches.isEmpty)
          const Center(child: Text('Keine gemeinsamen Spiele.'))
        else
          ...stats.sharedMatches.map((match) {
            final p1ScoreOpt = match.playerScores.firstWhereOrNull(
              (s) => s.playerId == p1.id,
            );
            final p2ScoreOpt = match.playerScores.firstWhereOrNull(
              (s) => s.playerId == p2.id,
            );
            if (p1ScoreOpt == null || p2ScoreOpt == null)
              return const SizedBox.shrink();

            return MatchPreviewCard(
              match: match,
              bottomWidget: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${p1ScoreOpt.placement}. Platz',
                      style: TextStyle(
                        fontWeight: p1ScoreOpt.placement < p2ScoreOpt.placement
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: p1ScoreOpt.placement < p2ScoreOpt.placement
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'VS',
                      style: TextStyle(
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${p2ScoreOpt.placement}. Platz',
                      style: TextStyle(
                        fontWeight: p2ScoreOpt.placement < p1ScoreOpt.placement
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: p2ScoreOpt.placement < p1ScoreOpt.placement
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildStatRow(
    String label,
    String val1,
    String val2,
    ThemeData theme, {
    bool isShared = false,
    bool invertGoodness = false,
  }) {
    Color color1 = theme.colorScheme.onSurface;
    Color color2 = theme.colorScheme.onSurface;
    FontWeight fw1 = FontWeight.normal;
    FontWeight fw2 = FontWeight.normal;

    if (!isShared) {
      double v1 = double.tryParse(val1) ?? 0;
      double v2 = double.tryParse(val2) ?? 0;

      bool v1Better = invertGoodness ? v1 < v2 : v1 > v2;
      bool v2Better = invertGoodness ? v2 < v1 : v2 > v1;

      if (v1Better) {
        color1 = theme.colorScheme.primary;
        fw1 = FontWeight.bold;
      } else if (v2Better) {
        color2 = theme.colorScheme.primary;
        fw2 = FontWeight.bold;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              val1,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: color1,
                fontWeight: fw1,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              val2,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: color2,
                fontWeight: fw2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
