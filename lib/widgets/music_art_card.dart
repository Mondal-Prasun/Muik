import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';
import 'package:muik/provider/content_provider.dart';

class MusicArtCard extends ConsumerStatefulWidget {
  const MusicArtCard({super.key});

  @override
  ConsumerState<MusicArtCard> createState() {
    return _MusicArtCardState();
  }
}

class _MusicArtCardState extends ConsumerState<MusicArtCard> {
  final androidChannel = AndroidChannel();

  MusicInfo currentUi = MusicInfo(uri: "", name: "");

  Uint8List audioArt = Uint8List.fromList([]);

  void loadThumbnail(String uri) async {
    try {
      final art = await androidChannel.getMusicArt(uri);
      setState(() {
        audioArt = art;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    audioArt = Uint8List.fromList([]);
    final cUri = ref.read(currentMusicProvider);
    loadThumbnail(cUri.uri);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cUri = ref.read(currentMusicProvider);

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
          child: FutureBuilder(
              future: androidChannel.getMusicArt(cUri.uri),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Image.asset("assets/placeholder.jpg");
                }
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return Image.asset("assets/placeholder.jpg");
                  }
                  return Image.memory(snapshot.data!);
                }
                return Image.asset("assets/placeholder.jpg");
              }),
        ),
      ),
    );
  }
}
