import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImageViewer extends StatelessWidget {
  final File imageFile;

  const FullScreenImageViewer({
    super.key,
    required this.imageFile,
  });

  static void show(BuildContext context, File imageFile, [String? _]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => FullScreenImageViewer(
          imageFile: imageFile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4,
          child: Image.file(imageFile),
        ),
      ),
    );
  }
}
