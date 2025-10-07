import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  MusicInfo({required this.name, required this.uri});
  final String name;
  final String uri;
}

class _CurrentMusicNotifier extends Notifier<MusicInfo> {
 @override
   MusicInfo build() => MusicInfo(uri: "", name: "");

   void setCurrnetMusic(MusicInfo music){
     state = music;	
    }

}

final currentMusicProvider = NotifierProvider<_CurrentMusicNotifier, MusicInfo>(_CurrentMusicNotifier.new);
