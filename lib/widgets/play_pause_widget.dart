import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';
import 'package:muik/channels/flutter_channel.dart';
import 'package:muik/provider/content_provider.dart';
import 'package:muik/screens/play_music.dart';

class PlayPauseWidget extends ConsumerStatefulWidget {
  const PlayPauseWidget({super.key, required this.size, required this.playMusicContext});
  final Size size;
  final BuildContext playMusicContext;
  @override
  ConsumerState<PlayPauseWidget> createState() {
    return _PlayPauseState();
  }
}

class _PlayPauseState extends ConsumerState<PlayPauseWidget> {
  double boxHeight = 0;
  double boxWidth = 0;
  bool isMusicPlaying = true;

  final androidChannel = AndroidChannel();

  void pauseOrResumeMusic() async {
    final isPlaying = await androidChannel.isMusicPlaying();

    if (isPlaying) {
      setState(() {
        isMusicPlaying = false;
      });
      await androidChannel.pauseMusic();
    } else {
      setState(() {
        isMusicPlaying = true;
      });
      await androidChannel.resumeMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    boxHeight = widget.size.height / 8;
    boxWidth = widget.size.width - 50;

    isMusicPlaying = ref.watch(isLandMusicPlayingProvider);

    return Container(
      height: boxHeight,
      width: boxWidth,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 15,
        children: [
          Container(
            height: boxHeight / 2,
            width: boxWidth / 6,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.fork_left_rounded),
            ),
          ),
          Container(
            height: boxHeight / 1.5,
            width: boxWidth / 4,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              onPressed: () {
                pauseOrResumeMusic();
              },
              icon: Icon(
                isMusicPlaying
                    ? Icons.pause_outlined
                    : Icons.play_arrow_outlined,
              ),
              iconSize: 60,
              color: Colors.white,
            ),
          ),

          Container(
            height: boxHeight / 2,
            width: boxWidth / 6,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              onPressed: () async {
                final isChanged = await androidChannel.nextMusic();
		if(isChanged){
		  Navigator.of(widget.playMusicContext).pushReplacement(MaterialPageRoute(builder: (_)=> PlayMusic())); 
		}
              },
              icon: Icon(Icons.fork_right_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
