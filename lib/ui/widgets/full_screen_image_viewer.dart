import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImageViewer extends StatelessWidget {
  final File imageFile;
  final String heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.imageFile,
    required this.heroTag,
  });

  static void show(BuildContext context, File imageFile, String heroTag) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          imageFile: imageFile,
          heroTag: heroTag,
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
          child: Hero(
            tag: heroTag,
            child: Image.file(imageFile),
          ),
        ),
      ),
    );
  }
}
