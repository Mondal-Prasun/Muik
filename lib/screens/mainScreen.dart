import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/android_channel.dart';
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

  void loadDirectory() async {
    final dirs = await AndroidChannel().pickDirectory();
    // print(dirs);
    if (dirs != null) {
      setState(() {
        subDirs = dirs;
      });
    }
  }

  Widget content = Placeholder();

  void loadAllMusic(BuildContext ctx, String subUri) {
    ref.read(subDirUriProvider.notifier).setSubDirUri(subUri);
    Navigator.push(ctx, MaterialPageRoute(builder: (ctx) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (subDirs.isEmpty) {
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
    } else {
      final List withoutDotFile = [];

      for (final d in subDirs) {
        if (!d["name"].toString().startsWith(".")) {
          withoutDotFile.add(d);
        }
      }

      final dirTile = List.generate(withoutDotFile.length, (index) {
        return ListTile(
          tileColor: Colors.yellow,
          title: Text("${withoutDotFile[index]["name"]}"),
          onTap: () {
            loadAllMusic(context, withoutDotFile[index]["uri"]);
          },
        );
      });

      content = Column(children: [...dirTile]);
    }

    return Scaffold(appBar: AppBar(title: Text("Main Screen")), body: content);
  }
}
