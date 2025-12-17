import 'package:flutter/material.dart';
import 'package:muik/channels/android_channel.dart';
import 'package:muik/consts/constants.dart';
import 'package:muik/screens/mainScreen.dart';
import 'package:muik/screens/standby_screen.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final _androidChannel = AndroidChannel();

  void _chechLoadedMusic(BuildContext ctx) async {
    final String? value =
        await _androidChannel.getSharePef(key: SharePrefKeys.REFRESH_TIME.name);

    if (value != null) {
      Navigator.of(ctx).pushReplacement(
        MaterialPageRoute(
          builder: (_) => StandbyScreen(),
        ),
      );
    } else {
      Navigator.of(ctx).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _chechLoadedMusic(context);
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
