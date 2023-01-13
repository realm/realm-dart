import 'package:realm_common/realm_common.dart';

@RealmModel()
@MapTo('Bad')
class _Foo {
  @PrimaryKey()
  late RealmValue bad;
}
