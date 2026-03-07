import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/provider/content_provider.dart';

class MusicArtCard extends ConsumerStatefulWidget {
  const MusicArtCard({super.key});

  @override
  ConsumerState<MusicArtCard> createState() {
    return _MusicArtCardState();
  }
}

class _MusicArtCardState extends ConsumerState<MusicArtCard> {
  @override
  Widget build(BuildContext context) {
    final cMusic = ref.watch(currentMusicProvider);
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
          // child: FutureBuilder(
          //     future: cMusic.art,
          //     builder: (_, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return Image.asset("assets/placeholder.jpg");
          //       }
          //       if (snapshot.hasData) {
          //         print("it hass its art...................................");
          //         if (snapshot.data!.isEmpty) {
          //           return Image.asset("assets/placeholder.jpg");
          //         }
          //         return Image.memory(snapshot.data!);
          //       }
          //       return Image.asset("assets/placeholder.jpg");
          //     }),
          child: cMusic.art.isNotEmpty
              ? Image.memory(cMusic.art)
              : Image.asset("assets/placeholder.jpg"),
        ),
      ),
    );
  }
}
