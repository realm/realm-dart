import 'package:realm_common/realm_common.dart';

//part 'invalid_extend.g.dart';

class Base {}

@RealmModel()
class _Bad extends Base {
  @PrimaryKey()
  late int id;
}
