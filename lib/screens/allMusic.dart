import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/android_channel.dart';
import 'package:muik/provider/content_provider.dart';
import 'package:muik/provider/musicCache_Provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  MusicInfo musicInfo = MusicInfo(name: "", uri: "");

  List<MusicInfo> allMusic = [];

  final androidChannel = AndroidChannel();

  bool isMusicPlaying = false;

  bool isLoaded = false;

  void playMusic(MusicInfo music) async {
    // print("MusicUri: ${music.uri}");
    if (music.uri != "") {
      await androidChannel.playMusic(music.uri);
      setState(() {
        musicInfo = music;
        isMusicPlaying = true;
      });
    }
  }

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

  Future<bool> working(String test) async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final String subDirUri = ref.read(subDirUriProvider);
    allMusic = ref.watch(musicCacheProvider);
    return Scaffold(
      appBar: AppBar(
        elevation: 20,
        title: Text("Now Playing: ${musicInfo.name}"),
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pauseOrResumeMusic,

        child: Icon(isMusicPlaying ? Icons.pause : Icons.play_arrow),
      ),
      body:
          allMusic.isEmpty
              ? FutureBuilder(
                future: androidChannel.loadMusicFromStorage(subDirUri),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: LinearProgressIndicator(color: Colors.green),
                    );
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
                          MusicInfo(name: audio["name"], uri: audio["uri"]),
                        );
                      }
                    }
                    if (allMusic.isNotEmpty) {
                      ref.read(musicCacheProvider.notifier).setCache(allMusic);
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
              )
              : ListView.builder(
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
              ),
    );
  }
}
