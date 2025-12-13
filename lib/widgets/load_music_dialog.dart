import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';
import 'package:muik/consts/constants.dart';
import 'package:muik/provider/content_provider.dart';
import 'package:muik/provider/loaded_data_provider.dart';
import 'package:muik/screens/standby_screen.dart';

class LoadMusicDialog extends ConsumerStatefulWidget {
  const LoadMusicDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LoadMusicDialogState();
}

class _LoadMusicDialogState extends ConsumerState<LoadMusicDialog> {
  bool _loadStarted = false;
  final _androidChannel = AndroidChannel();
  int _count = 0;
  String _loadedMusicName = "Starting...";
  int _loadedCount = 0;

  Widget content = CircularProgressIndicator();

  void saveAllMusic(BuildContext ctx) async {
    setState(() {
      _loadStarted = true;
    });
    final allDirs = ref.read(subDirUriProvider);

    for (final e in allDirs) {
      final c = await _androidChannel.getMusicCount(e.subDirUri);
      setState(() {
        _count += c;
      });
    }

    for (final e in allDirs) {
      final mMeta = await _androidChannel.loadMusicFromStorage(e.subDirUri);

      for (final s in mMeta!) {
        if (s["name"].toString().contains(RegExp(
              r'^\d+\.\s*|(\.flac|\.mp3|\.wav|\.ogg|\.aac|\.m4a|\.alac|\.opus)$',
              caseSensitive: false,
            ))) {
          ref
              .read(loadedDataProvider.notifier)
              .insertMusicInfo(s["name"] as String, s["uri"] as String);
          setState(() {
            _loadedMusicName = s["name"] as String;
            _loadedCount++;
          });
        } else {
          setState(() {
            _loadedCount++;
          });
        }
      }
    }
    print("$_loadedMusicName | $_loadedCount");

    _androidChannel.setSharePef(
        key: SharePrefKeys.REFRESH_TIME.name,
        value: TimeOfDay.now().format(ctx));

    Navigator.of(ctx).pushReplacement(
      MaterialPageRoute(
        builder: (_) => StandbyScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadStarted) {
      saveAllMusic(context);
    }
    return SizedBox(
        height: 150,
        child: Dialog(
          child: Center(
            child: _loadStarted
                ? SizedBox(
                    height: 300,
                    width: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 15,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                                width: 100,
                                child: Text(
                                  _loadedMusicName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                )),
                            Spacer(),
                            Text(
                              "$_loadedCount/$_count",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        LinearProgressIndicator(
                          value: _loadedCount == 0
                              ? 0.0
                              : (_loadedCount.toDouble() / _count.toDouble()),
                        )
                      ],
                    ),
                  )
                : CircularProgressIndicator(),
          ),
        ));
  }
}
