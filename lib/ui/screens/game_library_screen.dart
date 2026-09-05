import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/game.dart';
import '../../l10n/l10n_extension.dart';
import '../../providers/providers.dart';
import '../../utils/game_image_helper.dart';
import '../../utils/game_sorting_helper.dart';
import '../widgets/full_screen_image_viewer.dart';
import 'game_details_screen.dart';

class GameLibraryScreen extends ConsumerStatefulWidget {
  const GameLibraryScreen({super.key});

  @override
  ConsumerState<GameLibraryScreen> createState() => _GameLibraryScreenState();
}

class _GameLibraryScreenState extends ConsumerState<GameLibraryScreen> {
  GameSortOption _sortOption = GameSortOption.nameAsc;
  static const _sortOptionPrefKey = 'game_library_sort_option';

  @override
  void initState() {
    super.initState();
    _loadSavedSortOption();
  }

  Future<void> _loadSavedSortOption() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_sortOptionPrefKey);
      if (savedKey != null && mounted) {
        setState(() {
          _sortOption = GameSortOption.fromKey(savedKey);
        });
      }
    } catch (e) {
      debugPrint('Error loading saved sort option: $e');
    }
  }

  Future<void> _onSortOptionSelected(GameSortOption option) async {
    setState(() {
      _sortOption = option;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sortOptionPrefKey, option.name);
    } catch (e) {
      debugPrint('Error saving sort option: $e');
    }
  }

  void _showSortBottomSheet(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                l10n.sortGamesBy,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: GameSortOption.values.map((option) {
                  final isSelected = option == _sortOption;
                  return ListTile(
                    leading: Icon(
                      option.icon,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      option.getLocalizedLabel(context),
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? theme.colorScheme.primary : null,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      _onSortOptionSelected(option);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final matchRecordsAsync = ref.watch(matchRecordsProvider);
    final gamesAsync = ref.watch(gamesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.libraryTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: l10n.sortTooltip,
            onPressed: () => _showSortBottomSheet(context),
          ),
        ],
      ),
      body: matchRecordsAsync.when(
        data: (records) {
          // Extrahiere alle Spiele mit ihren Match-Counts
          final Map<int, Game> gamesMap = {};

          if (gamesAsync.value != null) {
            for (var g in gamesAsync.value!) {
              gamesMap[g.id] = g;
            }
          }

          for (var record in records) {
            final game = record.game.value;
            if (game != null) {
              gamesMap[game.id] = game;
            }
          }

          final statsMap = GameSortingHelper.calculateStats(
            gamesMap.values,
            records,
          );

          // Nur Spiele anzeigen, die mindestens 1 Partie haben
          final filteredGames = gamesMap.values
              .where((g) => (statsMap[g.id]?.matchesCount ?? 0) > 0)
              .toList();

          final sortedGames = GameSortingHelper.sortGames(
            games: filteredGames,
            sortOption: _sortOption,
            stats: statsMap,
          );

          if (sortedGames.isEmpty) {
            return Center(
              child: Text(
                l10n.noGamesInLibrary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          // Bilder vorab in einem schnellen Durchlauf auflösen
          final gameImages = GameImageHelper.resolveGameImages(
            sortedGames,
            records,
          );

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: sortedGames.length,
            itemBuilder: (context, index) {
              final game = sortedGames[index];
              final gameStats = statsMap[game.id] ?? const GameSortStats();
              final matchesCount = gameStats.matchesCount;
              final imagePath = gameImages[game.id];
              final lastPlayed = gameStats.lastPlayed;
              final lastPlayedText = lastPlayed != null
                  ? l10n.lastPlayedPrefix(DateFormat('dd.MM.yyyy').format(lastPlayed))
                  : '';

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
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
                        FullScreenImageViewer.show(context, File(imagePath));
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
                  subtitle: Text(
                    '${l10n.gameSubtitle(matchesCount)}$lastPlayedText',
                  ),
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
            Center(child: Text(l10n.errorLoadingLibrary)),
      ),
    );
  }
}
