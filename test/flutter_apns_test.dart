import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_apns/flutter_apns.dart';
import 'package:flutter_apns/flutter_apns_platform_interface.dart';
import 'package:flutter_apns/flutter_apns_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterApnsPlatform
    with MockPlatformInterfaceMixin
    implements FlutterApnsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> register() {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<bool> requestPermissions() {
    // TODO: implement requestPermissions
    throw UnimplementedError();
  }

  @override
  Future<void> unregister() {
    // TODO: implement unregister
    throw UnimplementedError();
  }

  @override
  // TODO: implement onMessage
  Stream get onMessage => throw UnimplementedError();
}

void main() {
  final FlutterApnsPlatform initialPlatform = FlutterApnsPlatform.instance;

  test('$MethodChannelFlutterApns is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterApns>());
  });

  test('getPlatformVersion', () async {
    FlutterApns flutterApnsPlugin = FlutterApns.instance;
    MockFlutterApnsPlatform fakePlatform = MockFlutterApnsPlatform();
    FlutterApnsPlatform.instance = fakePlatform;

    expect(await flutterApnsPlugin.getPlatformVersion(), '42');
  });
}
