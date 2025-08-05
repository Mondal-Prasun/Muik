import 'package:flutter/services.dart';

class FlutterChannel {
  final flChannel = MethodChannel("Flutter_Channel_Music");

  //enter map of [methods] and its name as [string]
  void initPlatFromListners(Map<String, Function(dynamic)> namedMethods) {
    flChannel.setMethodCallHandler((call) async {
      print("kt methods: ${call.method}");
      for (final m in namedMethods.entries) {
        if (call.method == m.key) {
          m.value(call.arguments);
        }
      }
    });
  }
}
