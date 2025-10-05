import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';

class _MusicCacheProvider extends Notifier<List<MusicInfo>> {
  @override
  List<MusicInfo> build() => [];

  void setCache(List<MusicInfo> list) async {
    state = list;
  }

  // void rmCache(String cDir) async {
  //   if (_currentDir != cDir) {
  //     state = [];
  //   }
  // }
}

final musicCacheProvider =
    NotifierProvider<_MusicCacheProvider, List<MusicInfo>>(
      _MusicCacheProvider.new,
    );
