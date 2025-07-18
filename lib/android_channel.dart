import 'dart:developer';

import 'package:flutter/services.dart';

class MusicInfo {
  MusicInfo({required this.name, required this.uri});
  final String name;
  final String uri;
}

class AndroidChannel {
  final _androidBackendChannel = MethodChannel("Android_Channel_Music");

  Future<List<dynamic>?> pickDirectory() async {
    try {
      final dirUris = await _androidBackendChannel.invokeMethod(
        "pickPreferredDirectory",
      );

      return dirUris;
    } on PlatformException catch (e) {
      log(e.message!);
      return null;
    }
  }

  Future<List<dynamic>?> loadMusicFromStorage(String subDirUriString) async {
    try {
      final allContent = await _androidBackendChannel.invokeMethod(
        "loadMusicFromStorage",
        subDirUriString,
      );
      return allContent;
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
