import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';
import 'package:muik/channels/flutter_channel.dart';
import 'package:muik/provider/content_provider.dart';
import 'package:muik/provider/loaded_data_provider.dart';
import 'package:muik/screens/play_music.dart';

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
  final flutterChannel = FlutterChannel();

  bool isMusicPlaying = false;
  bool isLoaded = false;

  final ScrollController scrollController = ScrollController();
  double listTileHeight = 60;

  int musicLimit = 30;
  int musicLimitOffset = 0;

  String cleanFileName(String input) {
    final regex = RegExp(
      r'^\d+\.\s*|(\.flac|\.mp3|\.wav|\.ogg|\.aac|\.m4a|\.alac|\.opus)$',
      caseSensitive: false,
    );
    return input.replaceAll(regex, '').trim();
  }

  void playMusic(BuildContext context, MusicInfo music) async {
    // print("MusicUri: ${music.uri}");
    if (music.uri != "") {
      ref.read(currentMusicProvider.notifier).setCurrnetMusic(music);
      await androidChannel.playSingleMusic(music.uri);
    }
  }

  void playListMusic() async {
    if (allMusic != []) {
      List<Map<String, String>> items = [];
      for (final a in allMusic) {
        items.add({"uri": a.uri, "name": a.name});
      }
      await androidChannel.playListMusic(items);
    }
  }

  void shuffleMusic() async {
    if (allMusic != []) {
      List<Map<String, String>> items = [];
      for (final a in allMusic) {
        items.add({"uri": a.uri, "name": a.name});
      }
      await androidChannel.shuffleMusic(items);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    scrollController.addListener(() {
      print(scrollController.offset);
    });

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          shuffleMusic();
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => PlayMusic()));
        },
        child: Icon(
          Icons.shuffle_rounded,
          size: 25,
          fontWeight: FontWeight.w900,
        ),
      ),
      body: FutureBuilder(
        future: ref
            .read(loadedDataProvider.notifier)
            .getLimitedMusic(musicLimit, musicLimitOffset),
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

            allMusic = [...allMusic, ...data];

            return ListView.builder(
              controller: scrollController,
              itemCount: allMusic.length,
              itemBuilder: (context, index) {
                return SizedBox(
                    height: listTileHeight,
                    child: ListTile(
                      leading: Text("$index|"),
                      title: Text(allMusic[index].name),
                      onTap: () {
                        playMusic(
                          context,
                          MusicInfo(
                            name: allMusic[index].name,
                            uri: allMusic[index].uri,
                          ),
                        );

                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => PlayMusic()),
                        );
                      },
                    ));
              },
            );
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
