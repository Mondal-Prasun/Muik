import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/flutter_channel.dart';
import 'package:muik/provider/content_provider.dart';
import 'package:muik/screens/mainScreen.dart';
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

  final flutterChannel = FlutterChannel();

  dynamic mediaPausedOrResumeNotification(dynamic isPlay) {
    setState(() {
      isMusicPlaying = isPlay as bool;
      ref.read(isLandMusicPlayingProvider.notifier).set(isMusicPlaying);
    });
  }

  dynamic mediaChanged(dynamic meta) {
    print(
      "changed music : ${meta["name"]} | ${meta["artist"]} | ${meta["duration"]}",
    );
    final info = ref.read(currentMusicProvider);
    ref
        .read(currentMusicProvider.notifier)
        .setCurrnetMusic(
          MusicInfo(name: info.name, uri: info.uri)
	    //..uuid = info.uuid
            ..title = meta["name"] as String
            ..artist = meta["artist"]
            ..duration = meta["duration"],
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
        MainScreen(),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => PlayMusic()));
            },
            child: CurrentAudioIsland(
              title: currentMusic.title ?? "Unkown",
              artist: currentMusic.artist ?? "UNKnown",
              isPlaying: isMusicPlaying,
            ),
          ),
        ),
      ],
    );
  }
}
