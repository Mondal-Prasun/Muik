import 'package:flutter_riverpod/flutter_riverpod.dart';

class _SubDirUriNotifier extends StateNotifier<String> {
  _SubDirUriNotifier() : super("");

  void setSubDirUri(String subDirUri) {
    if (subDirUri.isEmpty) {
      return;
    }
    state = subDirUri;
  }
}

final subDirUriProvider = StateNotifierProvider<_SubDirUriNotifier, String>(
  (ref) => _SubDirUriNotifier(),
);
