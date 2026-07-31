import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

import '../../data/models/player.dart';
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
    showModalBottomSheet(
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil erfolgreich aktualisiert!')),
              );
            }
          }
        },
      ),
    );
  }

  void _deletePlayer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Spieler löschen?'),
        content: const Text('Möchtest du diesen Spieler wirklich löschen? Historische Partien bleiben erhalten, aber der Spieler wird aus der Auswahlliste entfernt.'),
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
      await db.deletePlayer(_currentPlayer.id);
      if (mounted) {
        Navigator.pop(context); // Go back to player list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchRecordsAsync = ref.watch(matchRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spieler-Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _editProfile();
              if (value == 'delete') _deletePlayer();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Profil bearbeiten'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Spieler löschen', style: TextStyle(color: Colors.red)),
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
                          FullScreenImageViewer.show(context, File(_currentPlayer.imagePath!), 'player_detail_${_currentPlayer.id}');
                        }
                      },
                      child: Hero(
                        tag: 'player_detail_${_currentPlayer.id}',
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
                                  ),
                                )
                              : Text(_currentPlayer.name.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 48)),
                        ),
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
              Text('Statistiken', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatColumn(context, label: 'Partien', value: playerMatches.length.toString()),
                  _StatColumn(context, label: 'Siege', value: wins.toString()),
                  _StatColumn(context, label: 'Win Rate', value: '${winRate.toStringAsFixed(1)}%'),
                ],
              ),
              const SizedBox(height: 32),
              Text('Historie', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              if (playerMatches.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('Noch keine Partien gespielt.'),
                  ),
                ),
              ...playerMatches.map((match) {
                final score = match.playerScores.firstWhere((s) => s.playerId == _currentPlayer.id);
                final gameName = match.game.value?.name ?? 'Unbekanntes Spiel';
                
                return Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
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
                    subtitle: Text('${DateFormat('dd.MM.yyyy').format(match.date)} • ${score.score} Punkte'),
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
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Fehler beim Laden der Statistiken.')),
      ),
    );
  }

  Widget _StatColumn(BuildContext context, {required String label, required String value}) {
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

