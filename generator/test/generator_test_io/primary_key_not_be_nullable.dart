import 'package:realm_common/realm_common.dart';

//part 'primary_key_not_be_nullable.g.dart';

@RealmModel()
class _Bad {
  @PrimaryKey()
  int? nullableKeyNotAllowed;
}
