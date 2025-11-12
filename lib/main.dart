import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/screens/allMusic.dart';
import 'package:muik/screens/mainScreen.dart';
import 'package:muik/screens/standby_screen.dart';

void main() {
	runApp(
    ProviderScope(
      child: MaterialApp(theme: ThemeData(), home: StandbyScreen()),
    ),
  );
}



