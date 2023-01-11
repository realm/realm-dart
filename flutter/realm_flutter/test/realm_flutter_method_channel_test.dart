import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:realm_flutter/realm_flutter_method_channel.dart';

void main() {
  MethodChannelRealmFlutter platform = MethodChannelRealmFlutter();
  const MethodChannel channel = MethodChannel('realm_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
