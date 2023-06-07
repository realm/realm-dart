import 'package:realm_common/realm_common.dart';

//part 'nullable_list.realm.dart';

@RealmModel()
class _Bad {
  RealmValue? wrong;
}
