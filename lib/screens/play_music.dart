import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';
import 'package:muik/channels/flutter_channel.dart';
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
  final flutterChannel = FlutterChannel();
  bool gotMeta = false;

  // late final MusicInfo currnetMusic;

  dynamic mediaChanged(dynamic meta) {
    print(
      "changed music : ${meta["name"]} | ${meta["artist"]} | ${meta["duration"]}",
    );
    final info = ref.read(currentMusicProvider);
    ref
        .read(currentMusicProvider.notifier)
        .setCurrnetMusic(
          MusicInfo(name: info.name, uri: info.uri)
            ..title = meta["name"] as String
            ..artist = meta["artist"]
            ..duration = meta["duration"],
        );
    if (!gotMeta) {
      setState(() {});
      gotMeta = true;
    }
  }

  @override
  void initState() {
    flutterChannel.initListnersMeta({"MediaChanged": mediaChanged});
    super.initState();
  }

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
                  currentMusic.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(currentMusic.artist, style: TextStyle(fontSize: 11)),
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
