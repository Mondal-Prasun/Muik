import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:muik/android_channel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  MusicInfo musicInfo = MusicInfo(
    id: "",
    name: "",
    duration: 0,
    uri: "",
    absolutePath: "",
  );

  List<MusicInfo> allMusic = [];

  final andoridChannel = AndroidChannel();

  bool isMusicPlaying = false;

  bool isLoaded = false;

  void playMusic(MusicInfo music) async {
    setState(() {
      musicInfo = music;
      isMusicPlaying = true;
    });

    if (musicInfo.uri != "") {
      await andoridChannel.playMusic(musicInfo.uri);
    }
  }

  void pauseOrResumeMusic() async {
    final isPlaying = await andoridChannel.isMusicPlaying();
    if (isPlaying) {
      setState(() {
        isMusicPlaying = false;
      });
      await andoridChannel.pauseMusic();
    } else {
      setState(() {
        isMusicPlaying = true;
      });
      await andoridChannel.resumeMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Now Playing: ${musicInfo.name}"),
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pauseOrResumeMusic,
        child: Icon(isMusicPlaying ? Icons.pause : Icons.play_arrow),
      ),
      body: FutureBuilder(
        future: andoridChannel.loadMusicFromStorage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LinearProgressIndicator(color: Colors.green));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Cannot load music",
                style: TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;

            if (allMusic.length < data.length) {
              for (final audio in data) {
                allMusic.add(
                  MusicInfo(
                    id: audio["id"],
                    name: audio["name"],
                    duration: audio["duration"],
                    uri: audio["uri"],
                    absolutePath: audio["absolutePath"],
                  ),
                );
              }
            }
            if (allMusic.isNotEmpty) {
              return ListView.builder(
                itemCount: allMusic.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => playMusic(allMusic[index]),
                    child: ListTile(
                      leading: Text("$index|"),
                      title: Text(allMusic[index].name),
                    ),
                  );
                },
              );
            }
          }

          return Center(
            child: Text(
              "Cannot load music",
              style: TextStyle(color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}
