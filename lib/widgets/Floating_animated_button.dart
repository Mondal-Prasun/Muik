import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:muik/channels/android_channel.dart';
import 'package:muik/provider/content_provider.dart';
import 'package:muik/screens/play_music.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';

class FloatingAnimatedButton extends ConsumerStatefulWidget {
  const FloatingAnimatedButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FloatingAnimatedButtonState();
}

class _FloatingAnimatedButtonState extends ConsumerState<FloatingAnimatedButton>
    with TickerProviderStateMixin {
  Widget toggleIcon = SizedBox(
      height: 40,
      width: 35,
      child: RiveAnimatedIcon(
        riveIcon: RiveIcon.menuDots,
        strokeWidth: 6,
        loopAnimation: true,
        height: 30,
        width: 30,
        enableAbsorbPointer: true,
        color: Colors.white70,
      ));
  bool isTapped = false;
  double minPos = 70;

  late AnimationController controller;
  late Animation<double> animation;

  final androidChannel = AndroidChannel();

  Widget customFloatingButton(
      {required Widget child,
      required void Function() onpressed,
      required double? bottom}) {
    return Positioned(
      bottom: bottom,
      child: LiquidGlassLayer(
        settings:
            LiquidGlassSettings(thickness: 30, blur: 50, lightIntensity: 1),
        child: LiquidGlass(
          // glassContainsChild: true,
          shape: LiquidRoundedRectangle(
            borderRadius: 15,
          ),
          child: TextButton(
            onPressed: onpressed,
            child: child,
          ),
        ),
      ),
    );
  }

  void changeButtonPosition() {
    // setState(() {
    isTapped = !isTapped;

    if (isTapped) {
      controller.forward();
    } else {
      controller.reverse();
    }
    // });
  }

  void playAllMusic(BuildContext ctx) async {
    final musicList = ref.read(allMusicProvider);
    final List<Map<String, String>> musicMapList = [];

    ref.read(currentPlayingListProvider.notifier).setList(musicList);

    for (final e in musicList) {
      musicMapList.add(e.toMap());
    }
    await androidChannel.playListMusic(musicMapList);
  }

  void shuffleAllMusic(BuildContext ctx) async {
    final shuffleMusicList = ref.read(allMusicProvider.notifier).shuffleMusic();
    final List<Map<String, String>> musicMapList = [];

    ref.read(currentPlayingListProvider.notifier).setList(shuffleMusicList);

    for (final e in shuffleMusicList) {
      musicMapList.add(e.toMap());
    }
    await androidChannel.playListMusic(musicMapList);
  }

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.bounceIn))
        .animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (_, child) {
          return Container(
            margin: EdgeInsets.only(bottom: 100),
            // color: Colors.red,
            height: 200,
            width: 60,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                customFloatingButton(
                    onpressed: () {
                      shuffleAllMusic(context);
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => PlayMusic()));
                    },
                    child: SizedBox(
                      height: 40,
                      width: 35,
                      child: Icon(
                        Icons.shuffle_rounded,
                        size: 25,
                        color: Colors.white70,
                      ),
                    ),
                    bottom: minPos * 2 * animation.value),
                customFloatingButton(
                  onpressed: () {
                    playAllMusic(context);
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => PlayMusic()));
                  },
                  child: SizedBox(
                      height: 40,
                      width: 35,
                      child: Icon(
                        Icons.list_rounded,
                        size: 25,
                        color: Colors.white70,
                      )),
                  bottom: !isTapped ? null : minPos * animation.value,
                ),
                customFloatingButton(
                  onpressed: changeButtonPosition,
                  child: toggleIcon,
                  bottom: null,
                ),
              ],
            ),
          );
        });
  }
}
