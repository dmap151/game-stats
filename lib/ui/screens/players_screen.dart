import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/player.dart';
import '../../providers/providers.dart';
import '../../utils/player_sorting_helper.dart';
import '../widgets/full_screen_image_viewer.dart';
import 'player_details_screen.dart';
import 'compare_players_screen.dart';

class PlayersScreen extends ConsumerStatefulWidget {
  const PlayersScreen({super.key});

  @override
  ConsumerState<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends ConsumerState<PlayersScreen> {
  PlayerSortOption _sortOption = PlayerSortOption.nameAsc;
  static const _sortOptionPrefKey = 'player_sort_option';

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
          _sortOption = PlayerSortOption.fromKey(savedKey);
        });
      }
    } catch (e) {
      debugPrint('Error loading saved sort option: $e');
    }
  }

  Future<void> _onSortOptionSelected(PlayerSortOption option) async {
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
                'Spieler sortieren nach',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: PlayerSortOption.values.map((option) {
                  final isSelected = option == _sortOption;
                  return ListTile(
                    leading: Icon(
                      option.icon,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      option.label,
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

  Future<String?> _saveImageLocally(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'player_${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
      final savedImage = await image.copy('${directory.path}/$fileName');
      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  void _showAddPlayerDialog() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddPlayerBottomSheet(
        onSave: (name, imageFile) async {
          String? imagePath;
          if (imageFile != null) {
            imagePath = await _saveImageLocally(imageFile);
          }
          final db = ref.read(databaseProvider);
          final player = Player()
            ..name = name
            ..imagePath = imagePath;
          await db.savePlayer(player);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(playersProvider);
    final matchRecordsAsync = ref.watch(matchRecordsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spieler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sortieren',
            onPressed: () => _showSortBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.query_stats),
            tooltip: 'Spieler vergleichen',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const ComparePlayersScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: playersAsync.when(
        data: (players) {
          if (players.isEmpty) {
            return Center(
              child: Text(
                'Noch keine Spieler angelegt.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          final matchRecords = matchRecordsAsync.value ?? const [];
          final statsMap = PlayerSortingHelper.calculateStats(
            players,
            matchRecords,
          );
          final sortedPlayers = PlayerSortingHelper.sortPlayers(
            players: players,
            sortOption: _sortOption,
            stats: statsMap,
          );

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Space for FAB
            itemCount: sortedPlayers.length,
            itemBuilder: (context, index) {
              final player = sortedPlayers[index];
              final playerStats =
                  statsMap[player.id] ?? const PlayerSortStats();
              final subtitleText = playerStats.matches == 0
                  ? 'Noch keine Partien'
                  : '${playerStats.matches} ${playerStats.matches == 1 ? 'Partie' : 'Partien'} • ${playerStats.wins} ${playerStats.wins == 1 ? 'Sieg' : 'Siege'} (${playerStats.winRate.toStringAsFixed(0)}%)';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      if (player.imagePath != null) {
                        FullScreenImageViewer.show(
                          context,
                          File(player.imagePath!),
                        );
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: player.imagePath != null
                          ? ClipOval(
                              child: Image.file(
                                File(player.imagePath!),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                cacheWidth: 100,
                                gaplessPlayback: true,
                              ),
                            )
                          : Text(
                              player.name.isNotEmpty
                                  ? player.name.substring(0, 1).toUpperCase()
                                  : '?',
                            ),
                    ),
                  ),
                  title: Text(
                    player.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    subtitleText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            PlayerDetailsScreen(player: player),
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
            const Center(child: Text('Fehler beim Laden der Spieler')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPlayerDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Spieler anlegen'),
      ),
    );
  }
}

class _AddPlayerBottomSheet extends StatefulWidget {
  final void Function(String name, File? imageFile) onSave;

  const _AddPlayerBottomSheet({required this.onSave});

  @override
  State<_AddPlayerBottomSheet> createState() => _AddPlayerBottomSheetState();
}

class _AddPlayerBottomSheetState extends State<_AddPlayerBottomSheet> {
  final _nameController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Foto aufnehmen'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Aus Galerie wählen'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Neuen Spieler anlegen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: _selectedImage != null
                        ? ClipOval(
                            child: Image.file(
                              _selectedImage!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              cacheWidth: 200,
                              gaplessPlayback: true,
                            ),
                          )
                        : const Icon(Icons.person, size: 50),
                  ),
                  Positioned(
                    bottom: 0,
                    right: -10,
                    child: IconButton.filled(
                      onPressed: _showImageSourceDialog,
                      icon: const Icon(Icons.camera_alt, size: 20),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                final name = _nameController.text.trim();
                if (name.isNotEmpty) {
                  widget.onSave(name, _selectedImage);
                  Navigator.pop(context);
                }
              },
              child: const Text('Speichern'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
