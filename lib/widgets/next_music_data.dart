import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';
import 'package:muik/provider/content_provider.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';

class NextMusicData extends ConsumerStatefulWidget {
  const NextMusicData({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NextMusicDataState();
}

class _NextMusicDataState extends ConsumerState<NextMusicData> {
  final androidChannel = AndroidChannel();

  @override
  Widget build(BuildContext context) {
    final currentMusicList = ref.watch(currentPlayingListProvider);
    final currentPlaying = ref.watch(currentMusicProvider);

    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        itemCount: currentMusicList.length,
        itemBuilder: (ctx, index) {
          return Dismissible(
            key: Key(currentMusicList[index].name),
            onDismissed: (direction) async {
              final ml = [...currentMusicList];
              ml.removeAt(index);

              ref.read(currentPlayingListProvider.notifier).setList(ml);
              setState(() {});

              await androidChannel.removeMusicFromList(index);
            },
            background: Container(
              color: Colors.deepOrange,
            ),
            child: ListTile(
              tileColor: currentMusicList[index].name == currentPlaying.name
                  ? Colors.white
                  // : Theme.of(context).colorScheme.primary,
                  : Colors.red,
              leading: RiveAnimatedIcon(
                riveIcon: RiveIcon.sound,
                strokeWidth: 6,
                loopAnimation: true,
                enableAbsorbPointer: true,
              ),
              title: Text(
                currentMusicList[index].name,
                style: TextStyle(
                    color: currentMusicList[index].name == currentPlaying.name
                        ? Colors.yellow
                        : Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}
