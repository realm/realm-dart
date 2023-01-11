import 'package:flutter_test/flutter_test.dart';
import 'package:realm_flutter/realm_flutter.dart';
import 'package:realm_flutter/realm_flutter_platform_interface.dart';
import 'package:realm_flutter/realm_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRealmFlutterPlatform
    with MockPlatformInterfaceMixin
    implements RealmFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final RealmFlutterPlatform initialPlatform = RealmFlutterPlatform.instance;

  test('$MethodChannelRealmFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRealmFlutter>());
  });

  test('getPlatformVersion', () async {
    RealmFlutter realmFlutterPlugin = RealmFlutter();
    MockRealmFlutterPlatform fakePlatform = MockRealmFlutterPlatform();
    RealmFlutterPlatform.instance = fakePlatform;

    expect(await realmFlutterPlugin.getPlatformVersion(), '42');
  });
}
