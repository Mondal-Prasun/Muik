import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';
import 'package:muik/provider/content_provider.dart';

class PlayMusic extends ConsumerStatefulWidget {
  const PlayMusic({super.key});

  @override
  ConsumerState<PlayMusic> createState() {
    return _PlayMusicState();
  }
}

class _PlayMusicState extends ConsumerState<PlayMusic> {
  final androidChannel = AndroidChannel();

  @override
  Widget build(BuildContext context) {
    final Subdirectory subDir = ref.read(subDirUriProvider);
    final MusicInfo currentMusic = ref.read(currentMusicProvider);
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: Text(subDir.name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: androidChannel.getMusicArt(currentMusic.uri),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasData) {
                  //print(snapshot.data);
                  _MusicArtCard(size: size, audioArt: snapshot.data!);
                }
                return _MusicArtCard(size: size, audioArt: snapshot.data!);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MusicArtCard extends StatelessWidget {
  const _MusicArtCard({required this.size, required this.audioArt});
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
