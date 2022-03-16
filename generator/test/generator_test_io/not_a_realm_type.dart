import 'package:realm_common/realm_common.dart';

class NonRealm {}

@RealmModel()
class _Bad {
  late NonRealm notARealmType;
}
