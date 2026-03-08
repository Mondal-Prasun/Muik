import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';

import 'package:muik/provider/content_provider.dart';

import 'package:muik/widgets/load_music_dialog.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';

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
            Dialog(
              child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Column(
                      spacing: 20,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Choose Music Folder",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight(1000)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            loadDirectory(context);
                          },
                          icon: RiveAnimatedIcon(
                            riveIcon: RiveIcon.device,
                            strokeWidth: 6,
                            loopAnimation: true,
                            enableAbsorbPointer: true,
                          ),
                          label: Text(
                            "choose",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  )),
            )
          ],
        ),
      );
    } else {
      content = LoadMusicDialog(
        musicList: musicList,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(child: content),
    );
  }
}
