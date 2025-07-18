import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/android_channel.dart';
import 'package:muik/provider/content_provider.dart';

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

  final andoridChannel = AndroidChannel();

  bool isMusicPlaying = false;

  bool isLoaded = false;

  void playMusic(MusicInfo music) async {
    // print("MusicUri: ${music.uri}");
    if (music.uri != "") {
      await andoridChannel.playMusic(music.uri);
      setState(() {
        musicInfo = music;
        isMusicPlaying = true;
      });
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
    final String subDirUri = ref.read(subDirUriProvider);

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
      body: FutureBuilder(
        future: andoridChannel.loadMusicFromStorage(subDirUri),
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
                allMusic.add(MusicInfo(name: audio["name"], uri: audio["uri"]));
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
