import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'realm_flutter_method_channel.dart';

abstract class RealmFlutterPlatform extends PlatformInterface {
  /// Constructs a RealmFlutterPlatform.
  RealmFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static RealmFlutterPlatform _instance = MethodChannelRealmFlutter();

  /// The default instance of [RealmFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelRealmFlutter].
  static RealmFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RealmFlutterPlatform] when
  /// they register themselves.
  static set instance(RealmFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
