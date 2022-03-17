import 'package:realm_common/realm_common.dart';

//part 'bool_not_for_indexed_field.g.dart';

@RealmModel()
@MapTo('Bad')
class _Foo {
  @Indexed()
  late bool bad;
}
