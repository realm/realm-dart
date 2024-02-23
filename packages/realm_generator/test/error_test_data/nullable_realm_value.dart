import 'package:realm_common/realm_common.dart';

part 'nullable_realm_value.realm.dart';

@RealmModel()
class _Bad {
  RealmValue? wrong;
}
