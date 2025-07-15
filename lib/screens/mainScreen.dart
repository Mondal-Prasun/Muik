import 'package:flutter/material.dart';
import 'package:muik/android_channel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() {
    return _MainScreen();
  }
}

class _MainScreen extends State<MainScreen> {
  void loadDirectory() async {
    final dir = await AndroidChannel().pickDirectory();
    print("Directory uri: $dir");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Main Screen")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: loadDirectory, child: Text("Load DIR")),
          ],
        ),
      ),
    );
  }
}
