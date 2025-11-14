import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';
import 'package:muik/provider/content_provider.dart';
import 'package:muik/screens/allMusic.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});
  @override
  ConsumerState<MainScreen> createState() {
    return _MainScreen();
  }
}

class _MainScreen extends ConsumerState<MainScreen> {
  List subDirs = [];
  final CarouselController cCon = CarouselController(initialItem: 0);

  void loadDirectory() async {
    final dirs = await AndroidChannel().pickDirectory();
    // print(dirs);
    if (dirs != null) {
      setState(() {
        subDirs = dirs;
        gotFolders = true;
      });
    }
  }

  Widget content = Placeholder();

  int currentIndex = 0;

  bool gotFolders = false;

  bool showMusic = false;

  void loadAllMusic(BuildContext ctx, Subdirectory sub) {
    ref.read(subDirUriProvider.notifier).setSubDirUri(sub);
    setState(() {
      showMusic = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
      final List withoutDotFile = [];
      final rand = Random();

      for (final d in subDirs) {
        if (!d["name"].toString().startsWith(".")) {
          withoutDotFile.add(d);
        }
      }

      final dirTile = List.generate(withoutDotFile.length, (index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Color.fromARGB(
              255,
              rand.nextInt(255),
              rand.nextInt(255),
              rand.nextInt(255),
            ),
          ),
          padding: EdgeInsetsDirectional.all(25),
          child: Text(
            "${withoutDotFile[index]["name"]}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            softWrap: true,
          ),
        );
      });

      content = Column(
        spacing: 0,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: size.height / 2 - 100,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationZ(270 * 3.14 / 180),
                  child: Text(
                    "All Folders",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: CarouselView.weighted(
                    elevation: 5,
                    padding: EdgeInsets.only(right: 10),
                    controller: cCon,
                    shape: Border.all(style: BorderStyle.none),
                    itemSnapping: true,
                    flexWeights: [1, 3, 1],
                    onTap: (index) {
                      loadAllMusic(
                        context,
                        Subdirectory(
                          name: withoutDotFile[index]["name"],
                          subDirUri: withoutDotFile[index]["uri"],
                        ),
                      );
                    },
                    children: dirTile,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: size.height / 2 - 20,
            width: size.width,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Positioned(
                  left: -20,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationZ(-90 * 3.14 / 180),
                    child: Text(
                      "Recent Tracks",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 20,
                  child: Container(
                    width: size.width - 100,
                    height: size.height / 2.5,
                    color: Colors.red,
                    child: ListView(
                      children: [
                        ...List.generate(20, (i) {
                          return Container(
                            height: 20,
                            width: 40,
                            color: Colors.cyan,
                            child: Text("$i"),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      content = HomeScreen();
    }

    List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        icon: Icon(
          currentIndex == 0
              ? Icons.music_note_rounded
              : Icons.music_note_outlined,
        ),
        label: "Music",
      ),
      BottomNavigationBarItem(
        icon: Icon(
          currentIndex == 1
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
        ),
        label: "Favorite",
      ),
    ];

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
        appBar: AppBar(title: _CustomSearchBar()),
        bottomNavigationBar: Visibility(
          visible: gotFolders,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (value) {
              setState(() {
                currentIndex = value;
              });
            },
            items: [...items],
          ),
        ),
        body: content,
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
	   onTap: (){
	     setState(() {
	     	isTapped = !isTapped;
	    });				
	   },
            onChanged: (value) {
              final audio = ref.read(allMusicProvider.notifier).searchAudio(value);
		ref.read(searchedMusicProvider.notifier).setAudio(audio.first);
            },
          ),
        ));
  }
}
