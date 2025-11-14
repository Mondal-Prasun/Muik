import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class Subdirectory {
  Subdirectory({required this.name, required this.subDirUri});
  final String name;
  final String subDirUri;
}

class _SubDirUriNotifier extends Notifier<Subdirectory> {
  @override
  Subdirectory build() => Subdirectory(name: "", subDirUri: "");

  void setSubDirUri(Subdirectory sub) {
    state = sub;
  }
}

final subDirUriProvider = NotifierProvider<_SubDirUriNotifier, Subdirectory>(
  _SubDirUriNotifier.new,
);

class MusicInfo {
  MusicInfo({required this.name, required this.uri})
      : uuid = Uuid().v4(),
        title = null,
        artist = null,
        duration = null,
        art = null;
  String uuid;
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

class _AllMusicListNotifier extends Notifier<Map<String, List<MusicInfo>>> {
  @override
  Map<String, List<MusicInfo>> build() => {
        "": [],
      };

  void setAll(List<MusicInfo> audioList, String subDirUri) {
    state = {
      subDirUri: audioList,
    };
  }

  List<MusicInfo> searchAudio(String value) {
    if (state.values.first.isNotEmpty) {
      return [...state.values.first.where((info) => info.name.toLowerCase().contains(value))];
    } else {
      return [
        MusicInfo(uri:"", name:""),
      ];
    }
  }

  void reset() {
    state = {};
  }
}

final allMusicProvider =
    NotifierProvider<_AllMusicListNotifier, Map<String, List<MusicInfo>>>(
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
