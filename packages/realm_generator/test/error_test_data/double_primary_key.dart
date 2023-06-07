import 'package:realm_common/realm_common.dart';

//part 'double_primary_key.realm.dart';

@RealmModel()
class _Bad {
  @PrimaryKey()
  late int first;

  @PrimaryKey()
  late String second;

  late String another;

  @PrimaryKey()
  late String third;
}
