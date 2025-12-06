import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'flutter_apns_method_channel.dart';

abstract class FlutterApnsPlatform extends PlatformInterface {
  /// Constructs a FlutterApnsPlatform.
  FlutterApnsPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterApnsPlatform _instance = MethodChannelFlutterApns();

  /// The default instance of [FlutterApnsPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterApns].
  static FlutterApnsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterApnsPlatform] when
  /// they register themselves.
  static set instance(FlutterApnsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> register() async {
    throw UnimplementedError('register() has not been implemented.');
  }

  Future<void> unregister() async {
    throw UnimplementedError('unregister() has not been implemented.');
  }

  Future<bool> requestPermissions() async {
    throw UnimplementedError('requestPermission() has not been implemented.');
  }

  Stream get onMessage => throw UnimplementedError('onMessage has not been implemented.');
}
