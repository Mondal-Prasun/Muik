import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';
import 'package:muik/provider/content_provider.dart';

class NextMusicData extends ConsumerStatefulWidget {
  const NextMusicData({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NextMusicDataState();
}

class _NextMusicDataState extends ConsumerState<NextMusicData> {
  final androidChannel = AndroidChannel();

  @override
  Widget build(BuildContext context) {
    final currentMusicList = ref.read(currentPlayingListProvider);
    final currentPlaying = ref.read(currentMusicProvider);

    return ListView.builder(
      itemCount: currentMusicList.length,
      itemBuilder: (ctx, index) {
        //TODO:Change this thing
        // print(
        // "${currentMusicList[index].name} | ${currentPlaying.title}............................................................");
        return Dismissible(
          key: Key(currentMusicList[index].name),
          onDismissed: (direction) async {
            print(
                "removed index: ${index}................................................");
            await androidChannel.removeMusicFromList(index);
            final ml = currentMusicList;
            ml.removeAt(index);

            ref.read(currentPlayingListProvider.notifier).setList(ml);
          },
          background: Container(
            color: Colors.deepOrange,
          ),
          child: ListTile(
            tileColor: currentMusicList[index].name == currentPlaying.title
                ? Colors.cyan
                : Colors.white,
            leading: Text("${index + 1}|"),
            title: Text(currentMusicList[index].name),
          ),
        );
      },
    );
  }
}
