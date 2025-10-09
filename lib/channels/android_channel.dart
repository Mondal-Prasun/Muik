import 'dart:developer';
import 'package:flutter/services.dart';

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

  Future<Uint8List> getMusicArt(String audioUri) async {
    try {
      final artByteArray =
          await _androidBackendChannel.invokeMethod("getAudioArt", audioUri)
              as Uint8List;
      //print("art: $artByteArray");
      return artByteArray;
    } on PlatformException catch (e) {
      log(e.message!);
      return Uint8List.fromList([]);
    }
  }

  Future<void> playSingleMusic(String musicUri) async {
    try {
      await _androidBackendChannel.invokeMethod("startSingleMusic", musicUri);
    } on PlatformException catch (e) {
      log(e.message!);
    }
  }

  Future<void> playListMusic(List<Map<String, String>> listMusic) async {
    try {
      await _androidBackendChannel.invokeMethod("startMusicList", listMusic);
    } on PlatformException catch (e) {
      log(e.message!);
    }
  }

  Future<void> shuffleMusic(List<Map<String, String>> listMusic) async {
    try {
      await _androidBackendChannel.invokeMethod("shuffleMusic", listMusic);
    } on PlatformException catch (e) {
      log(e.message!);
    }
  }

  Future<void> toggleShuffle() async {
    try {
      await _androidBackendChannel.invokeMethod("toggleShuffleMode");
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

  Future<dynamic> getMusicDetails() async {
    try {
      final details = await _androidBackendChannel.invokeMethod(
        "getAudioDetails",
      );
      return details;
    } on PlatformException catch (e) {
      log(e.message!);
      return {};
    }
  }
}
