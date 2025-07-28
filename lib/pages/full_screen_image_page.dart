// full_screen_image_page.dart

import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final String filePath;
  final String? heroTag; // Opsiyonel: Hero animasyonu için

  const FullScreenImagePage({
    super.key,
    required this.filePath,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image.file(
      File(filePath),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
            SizedBox(height: 8),
            Text("Image not loaded", style: TextStyle(color: Colors.redAccent)),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: heroTag != null
            ? Hero(
                tag: heroTag!,
                child: imageWidget,
              )
            : imageWidget,
      ),
    );
  }
}
