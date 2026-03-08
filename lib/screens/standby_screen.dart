import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';
import 'package:muik/channels/flutter_channel.dart';
import 'package:muik/provider/content_provider.dart';
import 'package:muik/screens/allMusic.dart';
import 'package:muik/screens/play_music.dart';
import 'package:muik/widgets/current_audio_island.dart';

class StandbyScreen extends ConsumerStatefulWidget {
  const StandbyScreen({super.key});

  @override
  ConsumerState<StandbyScreen> createState() {
    return _StandByScreenState();
  }
}

class _StandByScreenState extends ConsumerState<StandbyScreen> {
  bool isMusicPlaying = false;
  bool isShowing = false;

  final flutterChannel = FlutterChannel();

  dynamic mediaPausedOrResumeNotification(dynamic isPlay) {
    setState(() {
      isShowing = true;
      isMusicPlaying = isPlay as bool;
      ref.read(isLandMusicPlayingProvider.notifier).set(isMusicPlaying);
    });
  }

  dynamic mediaChanged(dynamic currentChangedIndex) async {
    final int i = currentChangedIndex as int;

    final cMusic =
        ref.read(currentPlayingListProvider.notifier).getIndexedMusic(i);

    final artWork = await AndroidChannel().getMusicArt();

    ref.read(currentMusicProvider.notifier).setCurrnetMusic(
          MusicInfo(name: cMusic.name, uri: cMusic.uri)
            ..uuid = cMusic.uuid
            ..artist = cMusic.artist
            ..duration = cMusic.duration
            ..art = artWork,
        );
  }

  @override
  void initState() {
    flutterChannel.initListnersPlay({
      "IsKtMusicPlaying": mediaPausedOrResumeNotification,
    });
    flutterChannel.initListnersMeta({"MediaChanged": mediaChanged});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentMusic = ref.watch(currentMusicProvider);

    return Stack(
      children: [
        HomeScreen(),
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Visibility(
            visible: isShowing,
            child: GestureDetector(
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => PlayMusic()));
              },
              child: CurrentAudioIsland(
                title: currentMusic.name,
                artist: currentMusic.artist ?? "UNKnown",
                isPlaying: isMusicPlaying,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
