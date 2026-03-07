import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';
import 'package:muik/channels/flutter_channel.dart';
import 'package:muik/main.dart';
import 'package:muik/provider/content_provider.dart';
import 'package:muik/screens/play_music.dart';
import 'package:muik/widgets/Floating_animated_button.dart';
import 'package:muik/widgets/custom_search.dart';

enum PopButton {
  next,
  favorite,
}

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
  List<MusicInfo> allFavoriteMusic = [];

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

  int _bottomNavCurrentIndex = 0;

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
      ref.read(currentPlayingListProvider.notifier).setList([music]);
      await androidChannel.playListMusic([music.toMap()]);
    }
  }

  void onAddNext(MusicInfo musicInfo) async {
    final li = ref.read(currentPlayingListProvider);
    if (li.isEmpty) {
      ref.read(currentPlayingListProvider.notifier).setList([musicInfo]);

      androidChannel.playListMusic([musicInfo.toMap()]);
      return;
    }

    final cMusic = ref.read(currentMusicProvider);

    int cIndex = 0;

    for (final (i, e) in li.indexed) {
      if (e.uuid == cMusic.uuid) {
        cIndex = i;
        break;
      }
    }

    final addList = [...li];
    addList.insert(cIndex + 1, musicInfo);

    ref.read(currentPlayingListProvider.notifier).setList(addList);

    await androidChannel.addNextMusicInList(musicInfo);
  }

  Widget musicListUi(int? sIndex) {
    return ListView.builder(
      controller: scrollController,
      itemCount: _bottomNavCurrentIndex == 0
          ? allMusic.length + 1
          : allFavoriteMusic.length + 1,
      itemBuilder: (context, index) {
        if (_bottomNavCurrentIndex == 0) {
          if (index + 1 == allMusic.length + 1) {
            return SizedBox(
              height: 300,
            );
          }
        } else {
          if (index + 1 == allFavoriteMusic.length + 1) {
            return SizedBox(
              height: 300,
            );
          }
        }
        return SizedBox(
            height: listTileHeight,
            child: ListTile(
              tileColor: sIndex == null
                  ? null
                  : index == sIndex
                      ? Colors.orangeAccent
                      : Colors.white,
              leading: Text("$index|"),
              title: _bottomNavCurrentIndex == 0
                  ? Text(allMusic[index].name)
                  : Text(allFavoriteMusic[index].name),
              onTap: () {
                playMusic(
                  context,
                  _bottomNavCurrentIndex == 0
                      ? allMusic[index]
                      : allFavoriteMusic[index],
                );

                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PlayMusic()),
                );
              },
              trailing: PopupMenuButton<PopButton>(
                itemBuilder: (_) {
                  if (_bottomNavCurrentIndex == 0) {
                    return <PopupMenuItem<PopButton>>[
                      PopupMenuItem(
                        onTap: () async {
                          onAddNext(allMusic[index]);
                        },
                        value: PopButton.next,
                        child: Text(PopButton.next.name),
                      ),
                      PopupMenuItem(
                        onTap: () async {
                          loadDb.insertFavoriteMusicInfo(allMusic[index]);
                        },
                        value: PopButton.favorite,
                        child: Text(PopButton.favorite.name),
                      )
                    ];
                  } else {
                    return <PopupMenuItem<PopButton>>[
                      PopupMenuItem(
                        onTap: () async {
                          onAddNext(allFavoriteMusic[index]);
                        },
                        value: PopButton.next,
                        child: Text(PopButton.next.name),
                      ),
                      PopupMenuItem(
                        onTap: () async {
                          await loadDb
                              .deleteFromFavorite(allFavoriteMusic[index]);
                          setState(() {});
                        },
                        child: Text("delete"),
                      )
                    ];
                  }
                },
              ),
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
      floatingActionButton:
          _bottomNavCurrentIndex == 0 ? FloatingAnimatedButton() : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavCurrentIndex,
        onTap: (index) {
          setState(() {
            _bottomNavCurrentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.list_outlined,
              ),
              label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outlined), label: "Favorite"),
        ],
      ),
      body: _bottomNavCurrentIndex == 0
          ? allMusic.isEmpty
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
              : musicListUi(searcheredIndex)
          : FutureBuilder(
              future: loadDb.getAllFavoriteMusic(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LinearProgressIndicator(color: Colors.green),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Cannot load Favorite music ${snapshot.error}",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;

                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "Try adding some favorite music",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  allFavoriteMusic = data;

                  return musicListUi(null);
                }

                return Center(
                  child: Text(
                    "Try adding some favorite music",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
    );
  }
}
