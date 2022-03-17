import 'package:realm_common/realm_common.dart';

//part 'bool_not_allowed_as_primary_key.g.dart';

@RealmModel()
@MapTo('Bad')
class _Foo {
  @PrimaryKey()
  late bool bad;
}
