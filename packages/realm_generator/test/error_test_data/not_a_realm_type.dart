import 'package:realm_common/realm_common.dart';

//part 'not_a_realm_type.realm.dart';

class NonRealm {}

@RealmModel()
class _Bad {
  late NonRealm notARealmType;
}
