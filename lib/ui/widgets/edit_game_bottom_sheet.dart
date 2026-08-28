import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/game.dart';
import '../../data/models/match_record.dart';
import '../../utils/game_image_helper.dart';

class EditGameBottomSheet extends StatefulWidget {
  final Game game;
  final List<MatchRecord> allMatches;
  final void Function(File? newImage, bool removeCustomImage) onSave;

  const EditGameBottomSheet({
    super.key,
    required this.game,
    required this.allMatches,
    required this.onSave,
  });

  @override
  State<EditGameBottomSheet> createState() => _EditGameBottomSheetState();
}

class _EditGameBottomSheetState extends State<EditGameBottomSheet> {
  File? _selectedNewImage;
  bool _removedCustomImage = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1000,
      maxHeight: 1000,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedNewImage = File(pickedFile.path);
        _removedCustomImage = false;
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
    final theme = Theme.of(context);
    final fallbackMatchImage = GameImageHelper.getFallbackMatchImage(
      widget.game,
      widget.allMatches,
    );

    // Determine current display image
    String? currentImagePath;
    bool isCustom = false;
    bool isFallback = false;

    if (_selectedNewImage != null) {
      currentImagePath = _selectedNewImage!.path;
      isCustom = true;
    } else if (!_removedCustomImage &&
        widget.game.imagePath != null &&
        widget.game.imagePath!.isNotEmpty &&
        File(widget.game.imagePath!).existsSync()) {
      currentImagePath = widget.game.imagePath;
      isCustom = true;
    } else if (fallbackMatchImage != null) {
      currentImagePath = fallbackMatchImage;
      isFallback = true;
    }

    return SafeArea(
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
            Text(
              'Spielbild bearbeiten',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.game.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: currentImagePath != null
                        ? ClipOval(
                            child: Image.file(
                              File(currentImagePath),
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                              cacheWidth: 220,
                              gaplessPlayback: true,
                            ),
                          )
                        : Icon(
                            Icons.casino,
                            size: 50,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                  ),
                  Positioned(
                    bottom: -6,
                    right: -6,
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
            const SizedBox(height: 12),
            Center(
              child: Chip(
                avatar: Icon(
                  isCustom
                      ? Icons.person
                      : (isFallback ? Icons.auto_awesome : Icons.image_not_supported_outlined),
                  size: 16,
                  color: isCustom
                      ? theme.colorScheme.primary
                      : (isFallback ? theme.colorScheme.tertiary : theme.colorScheme.outline),
                ),
                label: Text(
                  isCustom
                      ? 'Eigenes hochgeladenes Bild'
                      : (isFallback
                          ? 'Automatisch aus Partie'
                          : 'Kein Bild vorhanden'),
                  style: theme.textTheme.labelMedium,
                ),
                backgroundColor: isCustom
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                    : (isFallback
                        ? theme.colorScheme.tertiaryContainer.withValues(alpha: 0.4)
                        : theme.colorScheme.surfaceContainerHighest),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Aus Galerie'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                  ),
                ),
              ],
            ),
            if (isCustom) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedNewImage = null;
                    _removedCustomImage = true;
                  });
                },
                icon: Icon(Icons.refresh, color: theme.colorScheme.error),
                label: Text(
                  'Eigenes Bild entfernen (Partie-Bild nutzen)',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                widget.onSave(_selectedNewImage, _removedCustomImage);
                Navigator.pop(context);
              },
              child: const Text('Speichern'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
