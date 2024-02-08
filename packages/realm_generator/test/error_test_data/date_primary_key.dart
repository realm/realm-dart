import 'package:realm_common/realm_common.dart';

//part 'double_primary_key.g.dart';

@RealmModel()
class _Bad {
  @PrimaryKey()
  late DateTime id;
}
