import 'package:realm_common/realm_common.dart';

//part 'bool_not_for_primary_key.g.dart';

@RealmModel()
@MapTo('Bad')
class _Foo {
  @PrimaryKey()
  late bool bad;
}
