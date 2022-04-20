import 'dart:typed_data';

import 'package:realm_common/realm_common.dart';

@RealmModel()
@MapTo('another type')
class _Original {
  @MapTo('remapped primitive')
  int primitiveProperty = 0;

  @MapTo('remapped object')
  late _Original? objectProperty;

  @MapTo('remapped list')
  late List<_Original> listProperty;
}
