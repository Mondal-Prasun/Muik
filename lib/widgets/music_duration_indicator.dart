import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muik/channels/android_channel.dart';
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

  double sliderValue = 0.0;

  dynamic getCurrentPos(dynamic pos) {
    final double cDu = double.parse(pos.toString());

    final int duInMinute = ((cDu / 1000) / 60).floor().toInt();
    final int duInSeconds = ((cDu % (60 * 1000)) / 1000).toInt();

    setState(() {
      sliderValue = cDu;
      updateDuSec = duInSeconds;
      updateDuMin = duInMinute;
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

    final double height = widget.size.height / 13;
    final double width = widget.size.width - 50;
    indicatorCount = ((width - 190) / indicatorWidth).toInt();

    if (randHeightList.isEmpty) {
      for (int i = 0; i < indicatorCount; i++) {
        final randHeight =
            (2 + rand.nextInt(height.floor().toInt())).toDouble();
        randHeightList.add(randHeight);
      }
    }

    if (indiCators.isEmpty) {
      int r = Random().nextInt(255);
      int g = Random().nextInt(255);
      int b = Random().nextInt(255);
      for (int i = 0; i < indicatorCount; i++) {
        indiCators.add(
          _IndicatorLines(
            height: randHeightList[i],
            width: indicatorWidth,
            color: Color.fromRGBO(r, g, b, 1),
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
        SliderTheme(
            data: SliderThemeData(
              trackHeight: 1.5,
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.grey,
              thumbShape: SliderComponentShape.noThumb,
            ),
            child: Slider(
              value: sliderValue,
              min: 0.0,
              max: audioDuration,
              onChanged: (value) async {
                await AndroidChannel().seekTo(value.round());
              },
            )),
        SizedBox(
          width: width,
          child: Row(
            children: [
              Text(
                "$updateDuMin:$updateDuSec",
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                "$duInMinute:$duInSeconds",
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold),
              ),
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
    t1?.cancel();
    t2?.cancel();
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
        color: Colors.grey,
        borderRadius: BorderRadius.circular(5),
        border: BoxBorder.all(width: 0.5),
      ),
    );
  }
}
