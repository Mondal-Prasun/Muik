import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/provider/loaded_data_provider.dart';

import 'package:muik/screens/splash_screen.dart';

late final LoadMusicDb loadDb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  loadDb = await LoadMusicDb.create();
  runApp(
    ProviderScope(
      child: MaterialApp(theme: ThemeData(), home: SplashScreen()),
    ),
  );
}
