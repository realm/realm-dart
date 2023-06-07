import 'package:realm_common/realm_common.dart';

//part 'mapto.realm.dart';

@RealmModel()
@MapTo('another type')
class $Original {
  @MapTo('remapped primitive')
  int primitiveProperty = 0;

  @MapTo('remapped object')
  late $Original? objectProperty;

  @MapTo('remapped list')
  late List<$Original> listProperty;
}
