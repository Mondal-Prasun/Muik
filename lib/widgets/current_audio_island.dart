import 'package:flutter/material.dart';
import 'package:muik/channels/android_channel.dart';

class CurrentAudioIsland extends StatelessWidget {
  const CurrentAudioIsland({
    super.key,
    required this.title,
    required this.artist,
    required this.isPlaying,
  });
  final String title;
  final String artist;
  final bool isPlaying;

  TextStyle islandTextStyle(double fontSize) {
    return TextStyle(
      overflow: TextOverflow.ellipsis,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      decoration: TextDecoration.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final androidChannel = AndroidChannel();

    void playPauseAudio() async {
      if (await androidChannel.isMusicPlaying()) {
        await androidChannel.pauseMusic();
      } else {
        await androidChannel.resumeMusic();
      }
    }

    double islandHeight = size.height / 12;
    double islandWidth = size.width / 1.5;

    return Row(
      children: [
        Spacer(),
        Container(
          height: islandHeight,
          width: islandWidth,
          decoration: BoxDecoration(
            color: Colors.cyan,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                child: IconButton(
                  onPressed: playPauseAudio,
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_outlined
                        : Icons.play_arrow_outlined,
                  ),
                ),
              ),
              SizedBox(
                height: islandHeight,
                width: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: islandTextStyle(14)),
                    Text(artist, style: islandTextStyle(12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Spacer(),
      ],
    );
  }
}
