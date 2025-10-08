import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicDurationIndicator extends ConsumerStatefulWidget {
  const MusicDurationIndicator({super.key, required this.size});
  final Size size;

  @override
  ConsumerState<MusicDurationIndicator> createState() {
    return _MusicDuarationIndicator();
  }
}

class _MusicDuarationIndicator extends ConsumerState<MusicDurationIndicator> {
  final rand = Random();
  List<double> randHeightList = [];
  List<Widget> indiCators = [];
  int indicatorCount = 0;
  int refreshCounter = 0;

  void startTimer() {
    Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        if (t.tick < indicatorCount) {
          indiCators[t.tick] = _IndicatorLines(
            height: randHeightList[t.tick],
            width: 2.0,
            color: Colors.black,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    refreshCounter++;
    if (refreshCounter < 2) {
      startTimer();
    }
    final double height = widget.size.height / 10;
    final double width = widget.size.width - 50;
    final double indicatorWidth = 2;
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
          child: Row(children: [Text("0:00"), Spacer(), Text("0:00")]),
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

  void startAnimation() {
    Timer(Duration(milliseconds: Random().nextInt(5000)), () {
      Timer.periodic(d, (t) {
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
