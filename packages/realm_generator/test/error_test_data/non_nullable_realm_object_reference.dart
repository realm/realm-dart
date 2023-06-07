import 'package:realm_common/realm_common.dart';

//part 'non_nullable_realm_object_reference.realm.dart';

@RealmModel()
class _Other {}

@RealmModel()
class _Bad {
  @PrimaryKey()
  late int id;

  late _Other wrong;
}
