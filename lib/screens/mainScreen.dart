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
  List<Subdirectory> subDirs = [];
  final CarouselController cCon = CarouselController(initialItem: 0);

  final androidChannel = AndroidChannel();

  void loadDirectory() async {
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

  bool showMusic = false;

  @override
  Widget build(BuildContext context) {
    //final size = MediaQuery.of(context).size;

    if (subDirs.isEmpty && !showMusic) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: loadDirectory,
              child: Icon(Icons.add),
            ),
          ],
        ),
      );
    } else if (!showMusic) {
      content = LoadMusicDialog();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (canPop, res) {
        if (canPop == false) {
          setState(() {
            showMusic = false;
          });
        }
      },
      child: Scaffold(
        body: Center(child: content),
      ),
    );
  }
}

class _CustomSearchBar extends ConsumerStatefulWidget {
  const _CustomSearchBar();
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CustomSearchBarState();
}

class _CustomSearchBarState extends ConsumerState<_CustomSearchBar> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          setState(() {
            isTapped = !isTapped;
          });
        },
        child: AnimatedContainer(
          width: isTapped == false ? 40 : 300,
          duration: Duration(milliseconds: 1000),
          child: SearchBar(
            onTap: () {
              setState(() {
                isTapped = !isTapped;
              });
            },
            onChanged: (value) {
              final audio =
                  ref.read(allMusicProvider.notifier).searchAudio(value);
              ref.read(searchedMusicProvider.notifier).setAudio(audio.first);
            },
          ),
        ));
  }
}
