import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/screens/mainScreen.dart';

void main() {
  runApp(ProviderScope(child: const MaterialApp(home: MainScreen())));
}
