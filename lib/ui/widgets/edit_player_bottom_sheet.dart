import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditPlayerBottomSheet extends StatefulWidget {
  final String initialName;
  final String? initialImagePath;
  final Function(String name, File? imageFile) onSave;

  const EditPlayerBottomSheet({
    super.key,
    required this.initialName,
    this.initialImagePath,
    required this.onSave,
  });

  @override
  State<EditPlayerBottomSheet> createState() => _EditPlayerBottomSheetState();
}

class _EditPlayerBottomSheetState extends State<EditPlayerBottomSheet> {
  late TextEditingController _nameController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    if (widget.initialImagePath != null) {
      final file = File(widget.initialImagePath!);
      if (file.existsSync()) {
        _selectedImage = file;
      }
    }
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
            const Text('Profil bearbeiten', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
              child: const Text('Änderungen speichern'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
