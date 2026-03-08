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
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
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

  late AnimationController _bgColorAnimController;
  late Animation<double> _bgColorAnim;

  bool _isSearchAvaliable = false;

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
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
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
                textColor: Colors.white,
                tileColor: sIndex == null
                    ? null
                    : index == sIndex
                        ? Colors.orangeAccent
                        : Colors.white,
                leading: RiveAnimatedIcon(
                  riveIcon: RiveIcon.sound,
                  strokeWidth: 6,
                  height: 20,
                  width: 20,
                  loopAnimation: true,
                  enableAbsorbPointer: true,
                  color: Colors.white,
                ),
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
                          child: Row(spacing: 10, children: [
                            RiveAnimatedIcon(
                              riveIcon: RiveIcon.add,
                              loopAnimation: true,
                              strokeWidth: 6,
                              enableAbsorbPointer: true,
                            ),
                            Text(PopButton.next.name)
                          ]),
                        ),
                        PopupMenuItem(
                          onTap: () async {
                            loadDb.insertFavoriteMusicInfo(allMusic[index]);
                          },
                          value: PopButton.favorite,
                          child: Row(spacing: 10, children: [
                            RiveAnimatedIcon(
                              riveIcon: RiveIcon.star,
                              strokeWidth: 6,
                              loopAnimation: true,
                              enableAbsorbPointer: true,
                            ),
                            Text(PopButton.favorite.name)
                          ]),
                        )
                      ];
                    } else {
                      return <PopupMenuItem<PopButton>>[
                        PopupMenuItem(
                          onTap: () async {
                            onAddNext(allFavoriteMusic[index]);
                          },
                          value: PopButton.next,
                          child: Row(spacing: 10, children: [
                            RiveAnimatedIcon(
                              riveIcon: RiveIcon.add,
                              strokeWidth: 6,
                              loopAnimation: true,
                              enableAbsorbPointer: true,
                            ),
                            Text(PopButton.next.name)
                          ]),
                        ),
                        PopupMenuItem(
                          onTap: () async {
                            await loadDb
                                .deleteFromFavorite(allFavoriteMusic[index]);
                            setState(() {});
                          },
                          child: Row(spacing: 10, children: [
                            RiveAnimatedIcon(
                              riveIcon: RiveIcon.dislike,
                              strokeWidth: 6,
                              loopAnimation: true,
                              enableAbsorbPointer: true,
                            ),
                            Text("delete")
                          ]),
                        )
                      ];
                    }
                  },
                ),
              ));
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _bgColorAnimController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));

    _bgColorAnim = Tween(begin: 0.0, end: 1.0).animate(_bgColorAnimController);
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
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title:
            Visibility(visible: _isSearchAvaliable, child: CustomSearchBar()),
        actions: [
          RiveAnimatedIcon(
            color: Colors.white,
            riveIcon: RiveIcon.search,
            loopAnimation: true,
            height: 35,
            width: 35,
            strokeWidth: 6,
            onTap: () {
              setState(() {
                _isSearchAvaliable = !_isSearchAvaliable;
              });
            },
          ),
          SizedBox(
            width: 30,
          )
        ],
      ),
      floatingActionButton:
          _bottomNavCurrentIndex == 0 ? FloatingAnimatedButton() : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _bottomNavCurrentIndex,
        onTap: (index) {
          setState(() {
            _bottomNavCurrentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: RiveAnimatedIcon(
                color: Colors.white,
                riveIcon: RiveIcon.home2,
                strokeWidth: 6,
                height: 30,
                width: 30,
                loopAnimation: true,
                enableAbsorbPointer: true,
              ),
              label: "Home"),
          BottomNavigationBarItem(
              icon: RiveAnimatedIcon(
                color: Colors.white,
                riveIcon: RiveIcon.star,
                strokeWidth: 6,
                loopAnimation: true,
                height: 30,
                width: 30,
                enableAbsorbPointer: true,
              ),
              label: "Favorite"),
        ],
      ),
      body: _bottomNavCurrentIndex == 0
          ? allMusic.isEmpty
              ? FutureBuilder(
                  future: loadDb.getLimitedMusic(musicLimit, musicLimitOffset),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Skeletonizer(
                        enabled: true,
                        child: ListView(
                          children: [
                            ...List.generate(12, (index) {
                              return ListTile(
                                title: Text("Music name"),
                              );
                            })
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Cannot load music ${snapshot.error}",
                          style: TextStyle(color: Colors.white),
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
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                )
              : musicListUi(searcheredIndex)
          : FutureBuilder(
              future: loadDb.getAllFavoriteMusic(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Skeletonizer(
                    enabled: true,
                    child: ListView(
                      children: [
                        ...List.generate(12, (i) {
                          return ListTile(
                            title: Text("Some Music"),
                          );
                        })
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Cannot load Favorite music ${snapshot.error}",
                      style: TextStyle(color: Colors.yellow),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;

                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "Try adding some favorite music",
                        style: TextStyle(color: Colors.yellow),
                      ),
                    );
                  }

                  allFavoriteMusic = data;

                  return musicListUi(null);
                }

                return Center(
                  child: Text(
                    "Try adding some favorite music",
                    style: TextStyle(color: Colors.yellow),
                  ),
                );
              },
            ),
    );
  }
}
