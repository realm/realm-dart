import 'package:realm_common/realm_common.dart';

//part 'required_argument.g.dart';

@RealmModel()
class _Person {
  @PrimaryKey()
  late String name;
}
