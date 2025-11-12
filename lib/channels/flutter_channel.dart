import 'package:flutter/services.dart';

class FlutterChannel {
  final _flChannelPlay = MethodChannel("Flutter_Channel_Music/Play");
  final _flChannelMeta = MethodChannel("Flutter_Channel_Music/Meta");
  final _flChannelDu = MethodChannel("Flutter_Channel_Music/Du");

  //enter map of [methods] and its name as [string]
  void initListnersPlay(Map<String, Function(dynamic)> namedMethods) {
    _flChannelPlay.setMethodCallHandler((call) async {
      if (namedMethods[call.method] == null) {
        throw "method does not exsist in native side";
      }
      namedMethods[call.method]!(call.arguments);
    });
  }

  void initListnersMeta(Map<String, Function(dynamic)> namedMethods) {
    _flChannelMeta.setMethodCallHandler((call) async {

      if (namedMethods[call.method] == null) {
        throw "method does not exsist in native side";
      }
      namedMethods[call.method]!(call.arguments);
    });
  }

  void initListnersDu(Map<String, Function(dynamic)> namedMethods) {
    _flChannelDu.setMethodCallHandler((call) async {

      if (namedMethods[call.method] == null) {
        throw "method does not exsist in native side";
      }
      namedMethods[call.method]!(call.arguments);
    });
  }
}
