import 'dart:developer';

import 'package:flutter/services.dart';

class MusicInfo {
  MusicInfo({
    required this.id,
    required this.name,
    required this.duration,
    required this.uri,
    required this.absolutePath,
  }) : thumbnail = Uint8List(0);
  final String id;
  final String name;
  final int duration;
  final String uri;
  final String absolutePath;
  Uint8List thumbnail;
}

class AndroidChannel {
  final _androidBackendChannel = MethodChannel("Android_Channel_Music");

  Future<dynamic> pickDirectory() async {
    try {
      final dirUri = await _androidBackendChannel.invokeMethod(
        "pickPreferredDirectory",
      );

      return dirUri;
    } on PlatformException catch (e) {
      log(e.message!);
      return null;
    }
  }

  Future<List<dynamic>?> loadMusicFromStorage<T>() async {
    try {
      final allData = await _androidBackendChannel.invokeMethod(
        "loadMusicFromStorage",
      );
      return allData;
    } on PlatformException catch (e) {
      log(e.message!);
      return null;
    }
  }

  Future<void> playMusic(String musicUri) async {
    try {
      await _androidBackendChannel.invokeMethod("startMusic", musicUri);
    } on PlatformException catch (e) {
      log(e.message!);
    }
  }

  Future<bool> isMusicPlaying() async {
    try {
      final isPlaing = await _androidBackendChannel.invokeMethod(
        "isMusicPlaying",
      );
      return isPlaing;
    } on PlatformException catch (e) {
      log(e.message!);
      return false;
    }
  }

  Future<void> pauseMusic() async {
    try {
      await _androidBackendChannel.invokeMethod("pauseMusic");
    } on PlatformException catch (e) {
      log(e.message!);
    }
  }

  Future<void> resumeMusic() async {
    try {
      await _androidBackendChannel.invokeMethod("resumeMusic");
    } on PlatformException catch (e) {
      log(e.message!);
    }
  }

  Future<bool> stopMusic() async {
    try {
      await _androidBackendChannel.invokeMethod("stopMusic");
      return true;
    } on PlatformException catch (e) {
      log(e.message!);
      return false;
    }
  }
}
