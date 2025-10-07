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

class _MusicDuarationIndicator extends ConsumerState<MusicDurationIndicator>{
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: widget.size.height/ 4,width: widget.size.width - 50,);
  }
}
