
import 'realm_flutter_platform_interface.dart';

class RealmFlutter {
  Future<String?> getPlatformVersion() {
    return RealmFlutterPlatform.instance.getPlatformVersion();
  }
}
