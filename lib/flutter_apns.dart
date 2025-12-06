import 'flutter_apns_platform_interface.dart';

final _apns = FlutterApnsPlatform.instance;

class FlutterApns {
  FlutterApns._();
  static final instance = FlutterApns._();

  Future<String?> getPlatformVersion() {
    return _apns.getPlatformVersion();
  }

  Future<bool> requestPermissions() => _apns.requestPermissions();

  Future<String?> register() => _apns.register();

  Future<void> unregister() => _apns.unregister();

  Stream get onMessage => _apns.onMessage;
}
