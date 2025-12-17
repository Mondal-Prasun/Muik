import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:muik/provider/content_provider.dart';

class CustomSearchBar extends ConsumerStatefulWidget {
  const CustomSearchBar({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CustomSearchBarState();
}

class _CustomSearchBarState extends ConsumerState<CustomSearchBar> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: SearchBar(
        onTap: () {
          setState(() {
            isTapped = !isTapped;
          });
        },
        onChanged: (value) {
          final audio = ref.read(allMusicProvider.notifier).searchAudio(value);
          ref.read(searchedMusicProvider.notifier).setAudio(audio.first);
        },
      ),
    );
  }
}
