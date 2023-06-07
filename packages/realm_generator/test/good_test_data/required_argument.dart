import 'package:realm_common/realm_common.dart';

//part 'required_argument.realm.dart';

@RealmModel()
class _Person {
  @PrimaryKey()
  late String name;
}
