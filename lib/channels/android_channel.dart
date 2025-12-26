import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:muik/provider/content_provider.dart';

class AndroidChannel {
  final _androidBackendChannel = MethodChannel("Android_Channel_Music");

  Future<List<MusicInfo>> pickMusicDirectory() async {
    final List<MusicInfo> musicList = [];
    try {
      final ml = await _androidBackendChannel.invokeMethod(
        "pickPreferredDirectory",
      );

      for (final e in ml) {
        musicList.add(MusicInfo(
          name: e["title"] as String,
          uri: e["uri"] as String,
        )
          ..artist = e["artist"] as String
          ..duration = "${e["duration"]}");
      }

      return musicList;
    } on PlatformException catch (e) {
      log(e.message!);
      return <MusicInfo>[];
    }
  }

  Future<int> getMusicCount() async {
    try {
      final int count = await _androidBackendChannel.invokeMethod(
        "getMusicCount",
      );
      return count;
    } on PlatformException catch (e) {
      log(e.message!);
      return 0;
    }
  }

  Future<void> setSharePef({required String key, required String value}) async {
    try {
      await _androidBackendChannel.invokeMethod("setSharePref", {
        key: value,
      });
    } on PlatformException catch (e) {
      log(e.message!);
      rethrow;
    }
  }

  Future<String?> getSharePef({required String key}) async {
    try {
      final res =
          await _androidBackendChannel.invokeMethod("getSharePref", key);
      return res as String?;
    } on PlatformException catch (e) {
      log(e.message!);
      rethrow;
    }
  }

  Future<Uint8List> getMusicArt(String audioUri) async {
    try {
      final artByteArray =
          await _androidBackendChannel.invokeMethod("getAudioArt", audioUri);

      if (artByteArray == null) {
        return Uint8List.fromList([]);
      }
      return artByteArray as Uint8List;
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

  Future<bool> nextMusic() async {
    try {
      final bool isChanged =
          await _androidBackendChannel.invokeMethod("nextMusic") as bool;
      return isChanged;
    } on PlatformException catch (e) {
      log(e.message!);
      return false;
    }
  }

  Future<bool> prevMusic() async {
    try {
      final bool isChanged =
          await _androidBackendChannel.invokeMethod("prevMusic") as bool;
      return isChanged;
    } on PlatformException catch (e) {
      log(e.message!);
      return false;
    }
  }

  Future<List<MusicInfo>> nextMediaItemsInfo(int maxCount) async {
    try {
      final List<MusicInfo> nextMusicListst = [];
      final nMl = await _androidBackendChannel.invokeMethod(
          "getNextMediaItemData", maxCount);
      for (final m in nMl) {
        nextMusicListst.add(MusicInfo(
          name: m["name"] as String,
          uri: m["uri"] as String,
        )
          ..title = m["name"] as String
          ..artist = m["artist"] as String
          ..duration = m["duration"] as String
          ..art = m["artWork"] ?? Uint8List.fromList([]));
      }

      return nextMusicListst;
    } on PlatformException catch (e) {
      log(e.message!);
      return [];
    }
  }
}
