import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'realm_flutter_platform_interface.dart';

/// An implementation of [RealmFlutterPlatform] that uses method channels.
class MethodChannelRealmFlutter extends RealmFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('realm_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
