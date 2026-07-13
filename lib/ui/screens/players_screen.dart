import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../data/models/player.dart';
import '../../providers/providers.dart';
import '../widgets/full_screen_image_viewer.dart';
import 'player_details_screen.dart';

class PlayersScreen extends ConsumerStatefulWidget {
  const PlayersScreen({super.key});

  @override
  ConsumerState<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends ConsumerState<PlayersScreen> {

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

  void _showAddPlayerDialog() {
    showModalBottomSheet(
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spieler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Space for FAB
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      if (player.imagePath != null) {
                        FullScreenImageViewer.show(context, File(player.imagePath!), 'player_list_${player.id}');
                      }
                    },
                    child: Hero(
                      tag: 'player_list_${player.id}',
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
                                ),
                              )
                            : Text(player.name.substring(0, 1).toUpperCase()),
                      ),
                    ),
                  ),
                  title: Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerDetailsScreen(player: player),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Fehler beim Laden der Spieler')),
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
  final Function(String name, File? imageFile) onSave;

  const _AddPlayerBottomSheet({required this.onSave});

  @override
  State<_AddPlayerBottomSheet> createState() => _AddPlayerBottomSheetState();
}

class _AddPlayerBottomSheetState extends State<_AddPlayerBottomSheet> {
  final _nameController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
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
    return Padding(
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
          const Text('Neuer Spieler', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  child: _selectedImage != null 
                      ? ClipOval(
                          child: Image.file(
                            _selectedImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            cacheWidth: 200,
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
    );
  }
}
