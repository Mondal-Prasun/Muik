import 'dart:typed_data';

import 'package:flutter/material.dart';

class MusicArtCard extends StatelessWidget {
  const MusicArtCard({super.key, required this.size, required this.audioArt});
  final Size size;
  final Uint8List audioArt;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 300,
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(audioArt, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
