import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muik/provider/loaded_data_provider.dart';

import 'package:muik/screens/splash_screen.dart';

late final LoadMusicDb loadDb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  loadDb = await LoadMusicDb.create();
  runApp(
    ProviderScope(
      child: MaterialApp(
          theme: ThemeData(
            textTheme: GoogleFonts.averageSansTextTheme(),
            colorScheme: ColorScheme.fromSeed(
                seedColor: Color.fromRGBO(45, 50, 56, 1),
                primary: Color.fromRGBO(45, 50, 56, 1)),
          ),
          home: SplashScreen()),
    ),
  );
}
