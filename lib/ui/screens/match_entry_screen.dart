import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../providers/providers.dart';
import '../../data/models/match_record.dart';
import '../../data/models/game.dart';
import '../../data/models/player.dart';
import '../widgets/primary_button.dart';
import '../widgets/full_screen_image_viewer.dart';

class _PlayerEntryForm {
  int? playerId;
  String? playerName;
  int placement = 1;
  int score = 0;
}

class MatchEntryScreen extends ConsumerStatefulWidget {
  final MatchRecord? existingMatch;

  const MatchEntryScreen({
    super.key,
    this.existingMatch,
  });

  @override
  ConsumerState<MatchEntryScreen> createState() => _MatchEntryScreenState();
}

class _MatchEntryScreenState extends ConsumerState<MatchEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gameNameController = TextEditingController();
  DateTime _date = DateTime.now();
  File? _selectedImage;

  final List<_PlayerEntryForm> _playerEntries = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingMatch != null) {
      final match = widget.existingMatch!;
      _gameNameController.text = match.game.value?.name ?? '';
      _date = match.date;
      if (match.imagePath != null) {
        final file = File(match.imagePath!);
        if (file.existsSync()) {
          _selectedImage = file;
        }
      }
      for (var ps in match.playerScores) {
        _playerEntries.add(_PlayerEntryForm()
          ..playerId = ps.playerId
          ..playerName = ps.playerName
          ..placement = ps.placement
          ..score = ps.score
        );
      }
    } else {
      _playerEntries.add(_PlayerEntryForm());
    }
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    super.dispose();
  }

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

  void _addPlayerEntry() {
    setState(() {
      _playerEntries.add(_PlayerEntryForm()..placement = _playerEntries.length + 1);
    });
  }

  void _removePlayerEntry(int index) {
    setState(() {
      _playerEntries.removeAt(index);
    });
  }

  Future<String?> _saveImageLocally(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
      final savedImage = await image.copy('${directory.path}/$fileName');
      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  void _saveMatch(List<Player> availablePlayers) async {
    if (_formKey.currentState!.validate()) {
      if (_playerEntries.any((p) => p.playerId == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte für jeden Eintrag einen Spieler auswählen.')),
        );
        return;
      }

      String? finalImagePath = widget.existingMatch?.imagePath;
      if (_selectedImage != null && _selectedImage!.path != finalImagePath) {
        finalImagePath = await _saveImageLocally(_selectedImage!);
      }

      final db = ref.read(databaseProvider);
      final gameName = _gameNameController.text.trim();
      
      var game = await db.getGameByName(gameName);
      if (game == null) {
        game = Game()..name = gameName;
        await db.saveGame(game);
      }

      final scores = _playerEntries.map((e) {
        final player = availablePlayers.firstWhere((p) => p.id == e.playerId);
        return PlayerScore()
          ..playerId = player.id
          ..playerName = player.name
          ..placement = e.placement
          ..score = e.score;
      }).toList();

      final match = widget.existingMatch ?? MatchRecord();
      match.game.value = game;
      match.date = _date;
      match.numberOfPlayers = _playerEntries.length;
      match.imagePath = finalImagePath;
      match.playerScores = scores;

      await db.saveMatchRecord(match);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.existingMatch == null ? 'Ergebnis gespeichert!' : 'Änderungen gespeichert!')),
        );
        
        if (widget.existingMatch != null) {
          // If we are editing, pop back to the details screen
          Navigator.pop(context);
        } else {
          // If we are creating a new one from the bottom nav, just clear form
          _gameNameController.clear();
          setState(() {
            _playerEntries.clear();
            _playerEntries.add(_PlayerEntryForm());
            _selectedImage = null;
            _date = DateTime.now();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playersAsync = ref.watch(playersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingMatch == null ? 'Ergebnis eintragen' : 'Partie bearbeiten'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: playersAsync.when(
        data: (players) {
          if (players.isEmpty) {
            return const Center(
              child: Text('Bitte lege zuerst Spieler im "Spieler"-Tab an.'),
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TextFormField(
                  controller: _gameNameController,
                  decoration: const InputDecoration(
                    labelText: 'Spielname',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.casino_outlined),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Bitte Spielnamen eingeben' : null,
                ),
                const SizedBox(height: 24),

                // Date Picker (Optional UI Enhancement, but let's add a simple display for now)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text('Datum der Partie'),
                  subtitle: Text('${_date.day}.${_date.month}.${_date.year}'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _date = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Image Picker Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Erinnerungsfoto (optional)', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _showImageSourceDialog,
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text('Bild hinzufügen'),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedImage != null)
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_selectedImage != null) {
                                FullScreenImageViewer.show(context, _selectedImage!, 'match_preview');
                              }
                            },
                            child: Hero(
                              tag: 'match_preview',
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: theme.colorScheme.outlineVariant),
                                  image: DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -10,
                            right: -10,
                            child: IconButton(
                              onPressed: () => setState(() => _selectedImage = null),
                              icon: const Icon(Icons.cancel),
                              color: theme.colorScheme.error,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                
                Text('Mitspieler', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 16),
                
                ..._playerEntries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final playerForm = entry.value;

                  // Ensure the pre-selected playerId actually exists in the current players list
                  // If a player was deleted, we might need to handle this gracefully
                  final isValidId = players.any((p) => p.id == playerForm.playerId);
                  if (!isValidId && playerForm.playerId != null) {
                    playerForm.playerId = null;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: playerForm.playerId,
                                  decoration: const InputDecoration(
                                    labelText: 'Spieler auswählen',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: players.map((p) => DropdownMenuItem(
                                    value: p.id,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundImage: p.imagePath != null ? FileImage(File(p.imagePath!)) : null,
                                          child: p.imagePath == null ? Text(p.name.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 10)) : null,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(p.name),
                                      ],
                                    ),
                                  )).toList(),
                                  onChanged: (val) => setState(() => playerForm.playerId = val),
                                ),
                              ),
                              if (_playerEntries.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: theme.colorScheme.error,
                                  onPressed: () => _removePlayerEntry(index),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: playerForm.placement.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Platz',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.emoji_events_outlined),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) => playerForm.placement = int.tryParse(val) ?? 1,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  initialValue: playerForm.score.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Punkte',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.scoreboard_outlined),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) => playerForm.score = int.tryParse(val) ?? 0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                
                TextButton.icon(
                  onPressed: _addPlayerEntry,
                  icon: const Icon(Icons.add),
                  label: const Text('Weiteren Spieler hinzufügen'),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: widget.existingMatch == null ? 'Speichern' : 'Änderungen speichern',
                  icon: Icons.save_outlined,
                  onPressed: () => _saveMatch(players),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Fehler beim Laden der Spieler')),
      ),
    );
  }
}
