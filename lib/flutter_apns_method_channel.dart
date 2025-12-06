import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flutter_apns_platform_interface.dart';

/// An implementation of [FlutterApnsPlatform] that uses method channels.
class MethodChannelFlutterApns extends FlutterApnsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_apns');

  @visibleForTesting
  final eventChannel = const EventChannel('flutter_apns/events');

  Future<String?>? _registerProgress;

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  void _clearRegisterProgress()=>
      Future.delayed(const Duration(microseconds: 1), ()=> _registerProgress = null);

  Future<String?> _register() async {
    try {
      return await methodChannel.invokeMethod("register")
          .whenComplete(_clearRegisterProgress);
    } on PlatformException catch (e) {
      _clearRegisterProgress();
      throw PlatformException(message: e.message, code: e.code);
    }
  }

  @override
  Future<String?> register() async {
    if (_registerProgress == null) {
      return _registerProgress = _register();
    }

    return _registerProgress;
  }

  @override
  Future<void> unregister() async {
    try {
      await methodChannel.invokeMethod("unregister");
    } on PlatformException catch (e) {
      throw PlatformException(message: e.message, code: e.code);
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final result =await methodChannel.invokeMethod("requestPermissions");
      if (result is bool) return result;
      return false;
    } on PlatformException catch (e) {
      throw PlatformException(message: e.message, code: e.code);
    }
  }

  @override
  Stream get onMessage => eventChannel.receiveBroadcastStream();
}
