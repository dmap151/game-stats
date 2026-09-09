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

  Future<void> _setAsMyProfile() async {
    final db = ref.read(databaseProvider);
    await db.setMyPlayer(_currentPlayer.id);
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _currentPlayer.linkedUserId = user.id;
      await db.savePlayer(_currentPlayer);
    }
    setState(() {
      _currentPlayer.isMe = true;
    });
    ref.invalidate(playersProvider);
    ref.invalidate(myPlayerProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_currentPlayer.name} ist jetzt als "ICH" festgelegt.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _unlinkFriend() async {
    final db = ref.read(databaseProvider);
    await db.unlinkPlayer(_currentPlayer.id);
    setState(() {
      _currentPlayer.linkedUserId = null;
      _currentPlayer.friendCode = null;
    });
    ref.invalidate(playersProvider);
    ref.invalidate(friendsListProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Freund-Verknüpfung aufgehoben.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLinkWithFriendSheet() async {
    final friendsAsync = ref.read(friendsListProvider);
    final friends = friendsAsync.value ?? [];

    if (friends.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Noch keine Freunde in der Freundesliste. Füge im Account-Bereich Freunde hinzu.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Mit Freund verknüpfen',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Wähle einen Freund aus, um ${_currentPlayer.name} mit dessen Online-Konto zu verknüpfen.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const Divider(height: 24),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    final isCurrent = _currentPlayer.linkedUserId == friend.id;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        child: Text(
                          friend.displayName.isNotEmpty ? friend.displayName[0].toUpperCase() : 'F',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                      title: Text(friend.displayName),
                      subtitle: Text(friend.friendCode),
                      trailing: isCurrent ? Icon(Icons.check_circle, color: theme.colorScheme.primary) : null,
                      onTap: () async {
                        final db = ref.read(databaseProvider);
                        await db.linkPlayerToFriend(_currentPlayer.id, friend.id, friend.friendCode);
                        setState(() {
                          _currentPlayer.linkedUserId = friend.id;
                          _currentPlayer.friendCode = friend.friendCode;
                        });
                        ref.invalidate(playersProvider);
                        ref.invalidate(friendsListProvider);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        if (_currentPlayer.isMe)
                          Chip(
                            avatar: Icon(Icons.person_pin, size: 18, color: theme.colorScheme.onPrimaryContainer),
                            label: const Text('ICH'),
                            backgroundColor: theme.colorScheme.primaryContainer,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          )
                        else
                          ActionChip(
                            avatar: const Icon(Icons.person_pin_outlined, size: 18),
                            label: const Text('Als "ICH" festlegen'),
                            onPressed: _setAsMyProfile,
                          ),
                        if (_currentPlayer.linkedUserId != null)
                          Chip(
                            avatar: Icon(Icons.link_rounded, size: 18, color: theme.colorScheme.onSecondaryContainer),
                            label: Text(_currentPlayer.friendCode ?? 'Freund verknüpft'),
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            labelStyle: TextStyle(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: _unlinkFriend,
                          )
                        else if (!_currentPlayer.isMe)
                          ActionChip(
                            avatar: const Icon(Icons.link_rounded, size: 18),
                            label: const Text('Mit Freund verknüpfen'),
                            onPressed: _showLinkWithFriendSheet,
                          ),
                      ],
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

