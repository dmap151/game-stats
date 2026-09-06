import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../l10n/l10n_extension.dart';
import '../../providers/providers.dart';
import '../../data/models/match_record.dart';
import '../../data/models/game.dart';
import '../../data/models/player.dart';
import '../../services/location_service.dart';
import '../widgets/primary_button.dart';
import '../widgets/full_screen_image_viewer.dart';
import '../widgets/player_entry_card.dart';
import '../widgets/location_picker_dialog.dart';

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
  final List<File> _selectedImages = [];
  bool _useLocation = true;
  double? _latitude;
  double? _longitude;

  final List<_PlayerEntryForm> _playerEntries = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingMatch != null) {
      final match = widget.existingMatch!;
      _gameNameController.text = match.game.value?.name ?? '';
      _date = match.date;
      _latitude = match.latitude;
      _longitude = match.longitude;
      _useLocation = match.latitude != null && match.longitude != null;
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

  Future<void> _openLocationPicker() async {
    final result = await LocationPickerDialog.show(
      context: context,
      initialLatitude: _latitude,
      initialLongitude: _longitude,
    );

    if (result != null) {
      setState(() {
        if (result.isDeleted) {
          _latitude = null;
          _longitude = null;
          _useLocation = false;
        } else {
          _latitude = result.latitude;
          _longitude = result.longitude;
          if (result.latitude != null && result.longitude != null) {
            _useLocation = true;
          }
        }
      });
    }
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
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.chooseFromGallery),
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

  void _saveMatch() async {
    final l10n = context.l10n;
    if (_formKey.currentState!.validate()) {
      if (_playerEntries.any((p) => (p.playerName == null || p.playerName!.trim().isEmpty))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorEnterPlayerName),
          ),
        );
        return;
      }

      final List<String> finalImagePaths = [];
      for (var img in _selectedImages) {
        bool isExisting = false;
        if (widget.existingMatch != null) {
          if (widget.existingMatch!.imagePath == img.path) isExisting = true;
          if (widget.existingMatch!.imagePaths.contains(img.path)) {
            isExisting = true;
          }
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

      // Location handling:
      if (!_useLocation) {
        match.latitude = null;
        match.longitude = null;
      } else if (widget.existingMatch != null) {
        // When editing: do NOT re-fetch GPS! Strictly preserve user's edited or existing location
        match.latitude = _latitude;
        match.longitude = _longitude;
      } else {
        // When creating a new match:
        if (_latitude != null && _longitude != null) {
          match.latitude = _latitude;
          match.longitude = _longitude;
        } else {
          // Automatically and silently get GPS location when saving a new match
          final position = await LocationService.getCurrentLocation();
          if (position != null) {
            match.latitude = position.latitude;
            match.longitude = position.longitude;
          }
        }
      }

      await db.saveMatchRecord(match);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingMatch == null
                  ? l10n.matchSavedSuccess
                  : l10n.matchUpdatedSuccess,
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
            _useLocation = true;
            _latitude = null;
            _longitude = null;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                ? l10n.newMatchTitle
                : l10n.editMatchTitle,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Center(
                child: PrimaryButton(
                  label: widget.existingMatch == null
                      ? l10n.save
                      : l10n.saveChanges,
                  icon: Icons.save_outlined,
                  isCompact: true,
                  onPressed: (playersAsync.value?.isNotEmpty ?? false)
                      ? _saveMatch
                      : null,
                ),
              ),
            ),
          ],
        ),
      body: playersAsync.when(
        data: (players) {
          if (players.isEmpty) {
            return Center(
              child: Text(l10n.pleaseAddPlayersFirst),
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
                      decoration: InputDecoration(
                        labelText: l10n.gameNameLabel,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.casino_outlined),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? l10n.gameNameValidator
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
                  title: Text(l10n.matchDate),
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

                // Location Section with Toggle Switch
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: Icon(
                          _useLocation ? Icons.location_on : Icons.location_off_outlined,
                          color: _useLocation
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          l10n.useLocation,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          _useLocation
                              ? (widget.existingMatch == null && _latitude == null
                                  ? l10n.locationAutoDetectedOnSave
                                  : l10n.locationOptional)
                              : l10n.locationDisabledSubtitle,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: _useLocation,
                        onChanged: (bool val) {
                          setState(() {
                            _useLocation = val;
                            if (!val) {
                              _latitude = null;
                              _longitude = null;
                            }
                          });
                        },
                      ),
                      if (_useLocation && (_latitude != null && _longitude != null || widget.existingMatch != null)) ...[
                        const Divider(height: 1),
                        ListTile(
                          dense: true,
                          leading: Icon(
                            _latitude != null && _longitude != null
                                ? Icons.place
                                : Icons.place_outlined,
                            color: _latitude != null && _longitude != null
                                ? theme.colorScheme.primary
                                : null,
                            size: 22,
                          ),
                          title: _latitude != null && _longitude != null
                              ? FutureBuilder<String>(
                                  future: LocationService.getAddress(_latitude!, _longitude!),
                                  builder: (context, snapshot) {
                                    final addressText = snapshot.data ??
                                        '${_latitude!.toStringAsFixed(4)}°, ${_longitude!.toStringAsFixed(4)}°';
                                    return Text(
                                      addressText,
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  },
                                )
                              : Text(
                                  l10n.noLocation,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                          subtitle: _latitude != null && _longitude != null
                              ? Text(
                                  '${_latitude!.toStringAsFixed(4)}°, ${_longitude!.toStringAsFixed(4)}°',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_latitude != null && _longitude != null) ...[
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: l10n.editLocation,
                                  onPressed: _openLocationPicker,
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                                  tooltip: l10n.deleteLocation,
                                  onPressed: () {
                                    setState(() {
                                      _latitude = null;
                                      _longitude = null;
                                    });
                                  },
                                ),
                              ] else ...[
                                IconButton(
                                  icon: const Icon(Icons.add_location_alt_outlined),
                                  tooltip: l10n.addLocation,
                                  onPressed: _openLocationPicker,
                                ),
                              ],
                            ],
                          ),
                          onTap: _openLocationPicker,
                        ),
                      ] else if (_useLocation && widget.existingMatch == null && _latitude == null) ...[
                        const Divider(height: 1),
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.edit_location_outlined, size: 22),
                          title: Text(
                            l10n.searchAddressOrCity,
                            style: theme.textTheme.bodyMedium,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _openLocationPicker,
                        ),
                      ],
                    ],
                  ),
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
                            l10n.memoryPhoto,
                            style: theme.textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _showImageSourceDialog,
                            icon: const Icon(Icons.add_a_photo),
                            label: Text(l10n.addImage),
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
                              );
                            },
                            child: CircleAvatar(
                              radius: 36,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              child: ClipOval(
                                child: Image.file(
                                  img,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  cacheWidth: 150,
                                  gaplessPlayback: true,
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

                Text(l10n.coPlayers, style: theme.textTheme.headlineMedium),
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
                  label: Text(l10n.addAnotherPlayer),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: widget.existingMatch == null
                      ? l10n.save
                      : l10n.saveChanges,
                  icon: Icons.save_outlined,
                  onPressed: _saveMatch,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            Center(child: Text(l10n.errorLoadingPlayers)),
      ),
      ),
    );
  }
}
