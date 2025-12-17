import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';
import 'package:muik/consts/constants.dart';
import 'package:muik/provider/content_provider.dart';
import 'package:muik/screens/standby_screen.dart';
import 'package:muik/widgets/load_music_dialog.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});
  @override
  ConsumerState<MainScreen> createState() {
    return _MainScreen();
  }
}

class _MainScreen extends ConsumerState<MainScreen> {
  List<Subdirectory> subDirs = [];
  final CarouselController cCon = CarouselController(initialItem: 0);

  final androidChannel = AndroidChannel();

  void loadDirectory(BuildContext ctx) async {
    final dirs = await androidChannel.pickDirectory();
    // print(dirs);
    if (dirs != null) {
      ref.read(subDirUriProvider.notifier).setSubDirUri(dirs);
      setState(() {
        subDirs = dirs;
      });
    }
  }

  Widget content = SizedBox();

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    //final size = MediaQuery.of(context).size;

    if (subDirs.isEmpty) {
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
      content = LoadMusicDialog();
    }

    return Scaffold(
      body: Center(child: content),
    );
  }
}
