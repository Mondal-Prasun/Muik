import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';

import 'package:muik/provider/content_provider.dart';

import 'package:muik/widgets/load_music_dialog.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});
  @override
  ConsumerState<MainScreen> createState() {
    return _MainScreen();
  }
}

class _MainScreen extends ConsumerState<MainScreen> {
  List<MusicInfo> musicList = [];

  final androidChannel = AndroidChannel();

  void loadDirectory(BuildContext ctx) async {
    musicList = await androidChannel.pickMusicDirectory();
    setState(() {});
  }

  Widget content = SizedBox();

  @override
  Widget build(BuildContext context) {
    if (musicList.isEmpty) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: () {
                loadDirectory(context);
              },
              child: Icon(Icons.add),
            ),
          ],
        ),
      );
    } else {
      content = LoadMusicDialog(
        musicList: musicList,
      );
    }

    return Scaffold(
      body: Center(child: content),
    );
  }
}
