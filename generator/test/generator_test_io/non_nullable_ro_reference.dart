import 'package:realm_common/realm_common.dart';

//part 'non_nullable_ro_reference.g.dart';

@RealmModel()
class _Other {}

@RealmModel()
class _Bad {
  @PrimaryKey()
  late int id;

  late _Other wrong;
}
