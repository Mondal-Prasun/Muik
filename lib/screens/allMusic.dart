import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';
import 'package:muik/channels/flutter_channel.dart';
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
  final flutterChannel = FlutterChannel();

  bool isMusicPlaying = false;

  bool isLoaded = false;

  String cleanFileName(String input) {
    final regex = RegExp(
      r'^\d+\.\s*|(\.flac|\.mp3|\.wav|\.ogg|\.aac|\.m4a|\.alac|\.opus)$',
      caseSensitive: false,
    );
    return input.replaceAll(regex, '').trim();
  }

  void playMusic(MusicInfo music) async {
    // print("MusicUri: ${music.uri}");
    if (music.uri != "") {
      setState(() {
        musicInfo = music;
        isMusicPlaying = true;
      });
      await androidChannel.playSingleMusic(music.uri);
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

  Future<bool> working(String test) async {
    return true;
  }

  dynamic printIt(dynamic isIt) {
    print("Its working: $isIt");
  }

  dynamic mediaChanged(dynamic meta) {
    print("changed music : ${meta["name"]} | ${meta["art"]}");
  }

  @override
  void initState() {
    super.initState();
    flutterChannel.initPlatFromListners({
      "IsKtMusicPlaying": printIt,
      "MediaChanged": mediaChanged,
    });
  }

  @override
  Widget build(BuildContext context) {
    final String subDirUri = ref.read(subDirUriProvider);

    return Scaffold(
      appBar: AppBar(elevation: 30),
      floatingActionButton: FloatingActionButton(
        onPressed: shuffleMusic,

        child: Icon(isMusicPlaying ? Icons.pause : Icons.play_arrow),
      ),

      body: FutureBuilder(
        future: androidChannel.loadMusicFromStorage(subDirUri),
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
            //print(data);
            if (allMusic.length < data.length) {
              for (final audio in data) {
                if (audio["name"].toString().contains(
                  RegExp(r'(\.jpg|\.png|\.jpeg|\.txt)'),
                )) {
                  continue;
                }
                final mName = cleanFileName(audio["name"]);
                allMusic.add(MusicInfo(name: mName, uri: audio["uri"]));
              }
            }

            return ListView.builder(
              itemCount: allMusic.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text("$index|"),
                  title: Text(allMusic[index].name),
                  onTap: () {
                    playMusic(
                      MusicInfo(
                        name: allMusic[index].name,
                        uri: allMusic[index].uri,
                      ),
                    );
                  },
                );
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
