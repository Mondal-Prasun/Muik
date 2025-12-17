import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Subdirectory {
  Subdirectory({required this.name, required this.subDirUri});
  final String name;
  final String subDirUri;
}

class _SubDirUriNotifier extends Notifier<List<Subdirectory>> {
  @override
  List<Subdirectory> build() => [];

  void setSubDirUri(List<Subdirectory> subDirs) {
    state = subDirs;
  }
}

final subDirUriProvider =
    NotifierProvider<_SubDirUriNotifier, List<Subdirectory>>(
  _SubDirUriNotifier.new,
);

class MusicInfo {
  MusicInfo({required this.name, required this.uri})
      : uuid = null,
        title = null,
        artist = null,
        duration = null,
        art = null;
  String? uuid;
  final String name;
  final String uri;
  String? title;
  String? artist;
  String? duration;
  Uint8List? art;
}

class _CurrentMusicNotifier extends Notifier<MusicInfo> {
  @override
  MusicInfo build() => MusicInfo(uri: "", name: "");

  void setCurrnetMusic(MusicInfo music) {
    state = music;
  }

  void setCurrntMusicArt(Uint8List artByte) {
    state.art = artByte;
  }
}

final currentMusicProvider = NotifierProvider<_CurrentMusicNotifier, MusicInfo>(
  _CurrentMusicNotifier.new,
);

class _IslandMusicPlayingNotifer extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool isPLaying) {
    state = isPLaying;
  }
}

final isLandMusicPlayingProvider =
    NotifierProvider<_IslandMusicPlayingNotifer, bool>(
  _IslandMusicPlayingNotifer.new,
);

class _AllMusicListNotifier extends Notifier<List<MusicInfo>> {
  @override
  List<MusicInfo> build() => [];

  void setAll(List<MusicInfo> audioList) {
    state = audioList;
  }

  List<MusicInfo> searchAudio(String value) {
    if (state.isNotEmpty) {
      return [
        ...state.where((info) => info.name.toLowerCase().contains(value))
      ];
    } else {
      return [
        MusicInfo(uri: "", name: ""),
      ];
    }
  }

  void reset() {
    state = [];
  }
}

final allMusicProvider =
    NotifierProvider<_AllMusicListNotifier, List<MusicInfo>>(
        _AllMusicListNotifier.new);

class _SearchedAudioNotifier extends Notifier<MusicInfo> {
  @override
  MusicInfo build() => MusicInfo(uri: "", name: "");
  void setAudio(MusicInfo audio) {
    state = audio;
  }
}

final searchedMusicProvider =
    NotifierProvider<_SearchedAudioNotifier, MusicInfo>(
        _SearchedAudioNotifier.new);
