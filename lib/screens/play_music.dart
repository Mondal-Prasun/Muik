import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';
import 'package:muik/provider/content_provider.dart';
import 'package:muik/widgets/music_art_card.dart';
import 'package:muik/widgets/music_duration_indicator.dart';
import 'package:muik/widgets/play_pause_widget.dart';

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
      appBar: AppBar(title: Text(subDir.name), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            FutureBuilder(
              future: androidChannel.getMusicArt(currentMusic.uri),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasData) {
                  //print(snapshot.data);
                  MusicArtCard(size: size, audioArt: snapshot.data!);
                }
                return MusicArtCard(size: size, audioArt: snapshot.data!);
              },
            ),
            Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 3,
              children: [
                Text(
                  "Song name",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text("artist name", style: TextStyle(fontSize: 11)),
              ],
            ),
            Spacer(),
            MusicDurationIndicator(size: size),
            Spacer(),
            PlayPauseWidget(size: size),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
