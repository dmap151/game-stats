import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

import '../../data/models/player.dart';
import '../../l10n/l10n_extension.dart';
import '../../providers/providers.dart';
import '../widgets/full_screen_image_viewer.dart';
import '../widgets/edit_player_bottom_sheet.dart';
import 'game_details_screen.dart';

class PlayerDetailsScreen extends ConsumerStatefulWidget {
  final Player player;

  const PlayerDetailsScreen({
    super.key,
    required this.player,
  });

  @override
  ConsumerState<PlayerDetailsScreen> createState() => _PlayerDetailsScreenState();
}

class _PlayerDetailsScreenState extends ConsumerState<PlayerDetailsScreen> {
  late Player _currentPlayer;

  @override
  void initState() {
    super.initState();
    _currentPlayer = widget.player;
  }

  Future<String?> _saveImageLocally(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'player_${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
      final savedImage = await image.copy('${directory.path}/$fileName');
      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  void _editProfile() async {
    final l10n = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditPlayerBottomSheet(
        initialName: _currentPlayer.name,
        initialImagePath: _currentPlayer.imagePath,
        onSave: (name, imageFile) async {
          String? newImagePath = _currentPlayer.imagePath;
          if (imageFile != null && imageFile.path != newImagePath) {
            newImagePath = await _saveImageLocally(imageFile);
          }

          if (name != _currentPlayer.name || newImagePath != _currentPlayer.imagePath) {
            final db = ref.read(databaseProvider);
            await db.updatePlayerProfile(_currentPlayer, name, newImagePath);
            setState(() {
              _currentPlayer.name = name;
              _currentPlayer.imagePath = newImagePath;
            });
            if (mounted) {
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(content: Text(l10n.profileUpdatedSuccess)),
              );
            }
          }
        },
      ),
    );
  }

  void _deletePlayer() async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePlayerDialogTitle),
        content: Text(l10n.deletePlayerDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final db = ref.read(databaseProvider);
      await db.deletePlayer(_currentPlayer.id);
      if (mounted) {
        Navigator.pop(context); // Go back to player list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final matchRecordsAsync = ref.watch(matchRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPlayer.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _editProfile();
              if (value == 'delete') _deletePlayer();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(l10n.editProfileTooltip),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(l10n.deletePlayerTooltip, style: const TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: matchRecordsAsync.when(
        data: (records) {
          final playerMatches = records.where((r) {
            return r.playerScores.any((score) => score.playerId == _currentPlayer.id);
          }).toList();

          int wins = 0;
          for (var match in playerMatches) {
            final score = match.playerScores.firstWhere((s) => s.playerId == _currentPlayer.id);
            if (score.placement == 1) wins++;
          }
          
          final winRate = playerMatches.isEmpty ? 0.0 : (wins / playerMatches.length) * 100;
          playerMatches.sort((a, b) => b.date.compareTo(a.date));

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_currentPlayer.imagePath != null) {
                          FullScreenImageViewer.show(context, File(_currentPlayer.imagePath!));
                        }
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: _currentPlayer.imagePath != null 
                            ? ClipOval(
                                child: Image.file(
                                  File(_currentPlayer.imagePath!),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  cacheWidth: 250,
                                  gaplessPlayback: true,
                                ),
                              )
                            : Text(_currentPlayer.name.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 48)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentPlayer.name,
                      style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(l10n.globalStatistics, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(context, label: l10n.matchesCount, value: playerMatches.length.toString()),
                  _buildStatColumn(context, label: l10n.winsCount, value: wins.toString()),
                  _buildStatColumn(context, label: l10n.winRateLabel, value: '${winRate.toStringAsFixed(1)}%'),
                ],
              ),
              const SizedBox(height: 32),
              Text(l10n.matchHistory, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              if (playerMatches.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(l10n.noGamesPlayedYet),
                  ),
                ),
              ...playerMatches.map((match) {
                final score = match.playerScores.firstWhere((s) => s.playerId == _currentPlayer.id);
                final gameName = match.game.value?.name ?? '';
                final scoreText = score.score != null ? ' • ${score.score} ${l10n.score}' : '';
                
                return Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: score.placement == 1 
                          ? Colors.amber 
                          : theme.colorScheme.outlineVariant,
                      child: Text(
                        '#${score.placement}',
                        style: TextStyle(
                          color: score.placement == 1 ? Colors.black87 : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(gameName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${DateFormat('dd.MM.yyyy').format(match.date)}$scoreText'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      if (match.game.value != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => GameDetailsScreen(game: match.game.value!),
                          ),
                        );
                      }
                    },
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.errorLoadingMatches)),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, {required String label, required String value}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

