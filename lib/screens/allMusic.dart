import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';
import 'package:muik/channels/flutter_channel.dart';
import 'package:muik/main.dart';
import 'package:muik/provider/content_provider.dart';
import 'package:muik/screens/play_music.dart';
import 'package:muik/widgets/custom_search.dart';

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
  bool firstLoad = true;
  bool loadingMusic = false;

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

  Widget musicListUi(int? sIndex) {
    return ListView.builder(
      controller: scrollController,
      itemCount: allMusic.length,
      itemBuilder: (context, index) {
        return SizedBox(
            height: listTileHeight,
            child: ListTile(
              tileColor: sIndex == null
                  ? null
                  : index == sIndex
                      ? Colors.orangeAccent
                      : Colors.white,
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

  @override
  Widget build(BuildContext context) {
    allMusic = ref.read(allMusicProvider);
    final searchedMusic = ref.watch(searchedMusicProvider);

    final searcheredIndex = allMusic.indexOf(searchedMusic);

    if (searcheredIndex > 0) {
      scrollController.animateTo(
        (listTileHeight * searcheredIndex),
        duration: Duration(milliseconds: 200),
        curve: Curves.bounceInOut,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: CustomSearchBar(),
      ),
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
      body: allMusic.isEmpty
          ? FutureBuilder(
              future: loadDb.getLimitedMusic(musicLimit, musicLimitOffset),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LinearProgressIndicator(color: Colors.green),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Cannot load music ${snapshot.error}",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;

                  allMusic = data;
                  Future(() {
                    ref.read(allMusicProvider.notifier).setAll(data);
                  });

                  return musicListUi(null);
                }

                return Center(
                  child: Text(
                    "Cannot load music",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              },
            )
          : musicListUi(searcheredIndex),
    );
  }
}
