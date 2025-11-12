import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/flutter_channel.dart';
import 'package:muik/provider/content_provider.dart';

class MusicDurationIndicator extends ConsumerStatefulWidget {
  const MusicDurationIndicator({super.key, required this.size});
  final Size size;

  @override
  ConsumerState<MusicDurationIndicator> createState() {
    return _MusicDuarationIndicator();
  }
}

class _MusicDuarationIndicator extends ConsumerState<MusicDurationIndicator> {
  MusicInfo cUi = MusicInfo(uri: "", name: "");
  final rand = Random();
  List<double> randHeightList = [];
  List<Widget> indiCators = [];
  int indicatorCount = 0;

  final double indicatorWidth = 2;
  Timer? t;
  double audioDuration = 0;
  final flutterChannel = FlutterChannel();

  int updateDuMin = 0;
  int updateDuSec = 00;

  int indCount = 0;
  double updatedOffset = 0;

  double prevDu = 0;

  dynamic getCurrentPos(dynamic pos) {
    double posOffset = audioDuration / indicatorCount;
    // print("...............flutter audio pos: $pos");
    final double cDu = double.parse(pos.toString());

    final int duInMinute = ((cDu / 1000) / 60).floor().toInt();
    final int duInSeconds = ((cDu % (60 * 1000)) / 1000).toInt();
    setState(() {
      updateDuMin = duInMinute;
      updateDuSec = duInSeconds;

      int neededIndCount = (cDu / posOffset).floor();

      if (cDu < prevDu) {
        print("yep its small ................................");
        for (int i = 0; i <= neededIndCount; i++) {
	indCount = i;
          indiCators[indCount] = _IndicatorLines(
            height: randHeightList[indCount],
            width: indicatorWidth,
            color: Colors.black,
          );

          updatedOffset = posOffset * indCount;
        }
        for (int i = neededIndCount + 1; i <= indicatorCount; i++) {
          indiCators[indCount] = _IndicatorLines(
            height: randHeightList[indCount],
            width: indicatorWidth,
            color: Colors.white,
          );
        }
      }

      if (neededIndCount > indCount) {
        for (int i = 0; i <= neededIndCount; i++) {
          indiCators[indCount] = _IndicatorLines(
            height: randHeightList[indCount],
            width: indicatorWidth,
            color: Colors.black,
          );

          indCount = i;
          updatedOffset = posOffset * indCount;
        }
      } else {
        if (cDu > updatedOffset) {
          // print("going here");
          indiCators[indCount] = _IndicatorLines(
            height: randHeightList[indCount],
            width: indicatorWidth,
            color: Colors.black,
          );

          indCount = indCount + 1;
          updatedOffset = posOffset * indCount;
        }
      }
      prevDu = cDu;
    });
  }

  @override
  void initState() {
    flutterChannel.initListnersDu({"GetCurrentDuPos": getCurrentPos});
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MusicInfo currentMusic = ref.watch(currentMusicProvider);
    if (currentMusic.duration != null) {
      audioDuration = double.parse(currentMusic.duration!);
    }

    final double height = widget.size.height / 10;
    final double width = widget.size.width - 50;
    indicatorCount = ((width - 190) / indicatorWidth).toInt();

    if (randHeightList.isEmpty) {
      for (int i = 0; i < indicatorCount; i++) {
        final randHeight =
            (5 + rand.nextInt(height.floor().toInt())).toDouble();
        randHeightList.add(randHeight);
      }
    }

    if (indiCators.isEmpty) {
      for (int i = 0; i < indicatorCount; i++) {
        indiCators.add(
          _IndicatorLines(
            height: randHeightList[i],
            width: indicatorWidth,
            color: Colors.white,
          ),
        );
      }
    }

    final int duInMinute = ((audioDuration / 1000) / 60).floor().toInt();
    final int duInSeconds = ((audioDuration % (60 * 1000)) / 1000).toInt();

    return Column(
      children: [
        Container(
          height: height,
          width: width,
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Row(children: [...indiCators]),
        ),
        SizedBox(
          width: width,
          child: Row(
            children: [
              Text("$updateDuMin:$updateDuSec"),
              Spacer(),
              Text("$duInMinute:$duInSeconds"),
            ],
          ),
        ),
      ],
    );
  }
}

class _IndicatorLines extends StatefulWidget {
  const _IndicatorLines({
    required this.height,
    required this.width,
    required this.color,
  });

  final double height;
  final double width;
  final Color color;

  @override
  State<_IndicatorLines> createState() {
    return _IndicatorState();
  }
}

class _IndicatorState extends State<_IndicatorLines>
    with SingleTickerProviderStateMixin {
  final Duration d = Duration(milliseconds: 2000);
  bool doing = false;
  Timer? t1;
  Timer? t2;

  void startAnimation() {
    t2 = Timer(Duration(milliseconds: Random().nextInt(5000)), () {
      t1 = Timer.periodic(d, (t) {
        setState(() {
          doing = !doing;
        });
      });
    });
  }

  @override
  void initState() {
    startAnimation();
    super.initState();
  }

  @override
  void dispose() {
    t1!.cancel();
    t2!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: d,
      curve: Curves.bounceInOut,
      height: doing ? 10 : widget.height,
      width: widget.width,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 1),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(5),
        border: BoxBorder.all(width: 0.5),
      ),
    );
  }
}
