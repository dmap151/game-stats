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
import '../widgets/player_entry_card.dart';

class _PlayerEntryForm {
  int? playerId;
  String? playerName;
  int placement = 1;
  int? score;
}

class MatchEntryScreen extends ConsumerStatefulWidget {
  final MatchRecord? existingMatch;

  const MatchEntryScreen({super.key, this.existingMatch});

  @override
  ConsumerState<MatchEntryScreen> createState() => _MatchEntryScreenState();
}

class _MatchEntryScreenState extends ConsumerState<MatchEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gameNameController = TextEditingController();
  DateTime _date = DateTime.now();
  List<File> _selectedImages = [];

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
          _selectedImages.add(file);
        }
      }
      for (var path in match.imagePaths) {
        final file = File(path);
        if (file.existsSync()) {
          _selectedImages.add(file);
        }
      }
      for (var ps in match.playerScores) {
        _playerEntries.add(
          _PlayerEntryForm()
            ..playerId = ps.playerId
            ..playerName = ps.playerName
            ..placement = ps.placement
            ..score = ps.score,
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
    if (source == ImageSource.gallery) {
      final pickedFiles = await picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles.map((x) => File(x.path)));
        });
      }
    } else {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });
      }
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

  void _addPlayerEntry() {
    setState(() {
      _playerEntries.add(
        _PlayerEntryForm()..placement = _playerEntries.length + 1,
      );
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
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
      final savedImage = await image.copy('${directory.path}/$fileName');
      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  void _saveMatch(List<Player> availablePlayers) async {
    if (_formKey.currentState!.validate()) {
      if (_playerEntries.any((p) => (p.playerName == null || p.playerName!.trim().isEmpty))) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bitte für jeden Eintrag einen Spielernamen eingeben.'),
          ),
        );
        return;
      }

      List<String> finalImagePaths = [];
      for (var img in _selectedImages) {
        bool isExisting = false;
        if (widget.existingMatch != null) {
          if (widget.existingMatch!.imagePath == img.path) isExisting = true;
          if (widget.existingMatch!.imagePaths.contains(img.path))
            isExisting = true;
        }
        if (isExisting) {
          finalImagePaths.add(img.path);
        } else {
          final savedPath = await _saveImageLocally(img);
          if (savedPath != null) finalImagePaths.add(savedPath);
        }
      }

      final db = ref.read(databaseProvider);
      final gameName = _gameNameController.text.trim();

      var game = await db.getGameByName(gameName);
      if (game == null) {
        game = Game()..name = gameName;
        await db.saveGame(game);
      }

      final scores = <PlayerScore>[];
      for (var e in _playerEntries) {
        final pName = e.playerName!.trim();
        var player = await db.getPlayerByName(pName);
        if (player == null) {
          player = Player()..name = pName;
          final id = await db.savePlayer(player);
          player.id = id;
        }
        scores.add(
          PlayerScore()
            ..playerId = player.id
            ..playerName = player.name
            ..placement = e.placement
            ..score = e.score
        );
      }

      final match = widget.existingMatch ?? MatchRecord();
      match.game.value = game;
      match.date = _date;
      match.numberOfPlayers = _playerEntries.length;
      match.imagePath = finalImagePaths.isNotEmpty
          ? finalImagePaths.first
          : null;
      match.imagePaths = finalImagePaths.length > 1
          ? finalImagePaths.skip(1).toList()
          : [];
      match.playerScores = scores;

      await db.saveMatchRecord(match);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingMatch == null
                  ? 'Ergebnis gespeichert!'
                  : 'Änderungen gespeichert!',
            ),
          ),
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
            _selectedImages.clear();
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
    final matchRecordsAsync = ref.watch(matchRecordsProvider);
    
    final existingGameNames = matchRecordsAsync.value
            ?.map((r) => r.game.value?.name)
            .whereType<String>()
            .toSet()
            .toList() ??
        [];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.existingMatch == null
                ? 'Ergebnis eintragen'
                : 'Partie bearbeiten',
          ),
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
                Autocomplete<String>(
                  initialValue: TextEditingValue(text: _gameNameController.text),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return existingGameNames;
                    }
                    return existingGameNames.where((String option) {
                      return option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    _gameNameController.text = selection;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Spielname',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.casino_outlined),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Bitte Spielnamen eingeben'
                          : null,
                      onSaved: (val) => _gameNameController.text = val?.trim() ?? '',
                      onChanged: (val) => _gameNameController.text = val,
                      onFieldSubmitted: (val) => onFieldSubmitted(),
                    );
                  },
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
                          Text(
                            'Erinnerungsfoto (optional)',
                            style: theme.textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _showImageSourceDialog,
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text('Bild hinzufügen'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_selectedImages.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedImages.map((img) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: () {
                              FullScreenImageViewer.show(
                                context,
                                img,
                                'match_preview_${img.path}',
                              );
                            },
                            child: Hero(
                              tag: 'match_preview_${img.path}',
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    img,
                                    fit: BoxFit.cover,
                                    cacheWidth: 200,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -10,
                            right: -10,
                            child: IconButton(
                              onPressed: () =>
                                  setState(() => _selectedImages.remove(img)),
                              icon: const Icon(Icons.cancel),
                              color: theme.colorScheme.error,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 32),

                Text('Mitspieler', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 16),

                ..._playerEntries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final playerForm = entry.value;

                  return PlayerEntryCard(
                    playerName: playerForm.playerName ?? '',
                    placement: playerForm.placement,
                    score: playerForm.score,
                    players: players,
                    showRemoveButton: _playerEntries.length > 1,
                    onRemove: () => _removePlayerEntry(index),
                    onPlayerNameChanged: (val) => playerForm.playerName = val,
                    onPlacementChanged: (val) => playerForm.placement = val,
                    onScoreChanged: (val) => playerForm.score = val,
                  );
                }),

                TextButton.icon(
                  onPressed: _addPlayerEntry,
                  icon: const Icon(Icons.add),
                  label: const Text('Weiteren Spieler hinzufügen'),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: widget.existingMatch == null
                      ? 'Speichern'
                      : 'Änderungen speichern',
                  icon: Icons.save_outlined,
                  onPressed: () => _saveMatch(players),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Fehler beim Laden der Spieler')),
      ),
      ),
    );
  }
}
