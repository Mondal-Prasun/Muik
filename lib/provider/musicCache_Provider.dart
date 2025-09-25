import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';

class _MusicCacheProvider extends StateNotifier<List<MusicInfo>> {
  _MusicCacheProvider() : super([]);

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
    StateNotifierProvider<_MusicCacheProvider, List<MusicInfo>>(
      (ref) => _MusicCacheProvider(),
    );
