import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:muik/channels/android_channel.dart';

import 'package:muik/provider/content_provider.dart';
import 'package:muik/widgets/music_art_card.dart';
import 'package:muik/widgets/music_duration_indicator.dart';
import 'package:muik/widgets/next_music_data.dart';
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
    final MusicInfo currentMusic = ref.watch(currentMusicProvider);
    final Size size = MediaQuery.of(context).size;

    void modalSheet(BuildContext ctx) async {
      await showModalBottomSheet(
          context: ctx,
          builder: (_) {
            return NextMusicData();
          });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          title: Text(
            "All Music",
            style: TextStyle(color: Colors.white70),
          ),
          centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            MusicArtCard(),
            Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 3,
              children: [
                SizedBox(
                    width: 200,
                    child: Center(
                        child: Text(
                      currentMusic.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white70),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ))),
                Text(
                  currentMusic.artist ?? "UnKnown",
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
            Spacer(),
            MusicDurationIndicator(size: size),
            Spacer(),
            PlayPauseWidget(size: size, playMusicContext: context),
            Spacer(),
            LiquidGlassLayer(
              child: LiquidGlass(
                shape: LiquidRoundedRectangle(borderRadius: 15),
                child: SizedBox(
                  height: 40,
                  width: 100,
                  child: TextButton(
                    onPressed: () {
                      modalSheet(context);
                    },
                    child: Text(
                      "Up Next",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
