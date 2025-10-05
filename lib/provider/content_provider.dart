import 'package:flutter_riverpod/flutter_riverpod.dart';

class _SubDirUriNotifier extends Notifier<String> {
  @override
  String build() => "";

  void setSubDirUri(String subDirUri) {
    if (subDirUri.isEmpty) {
      return;
    }
    state = subDirUri;
  }
}

final subDirUriProvider = NotifierProvider<_SubDirUriNotifier, String>(
  _SubDirUriNotifier.new
);
