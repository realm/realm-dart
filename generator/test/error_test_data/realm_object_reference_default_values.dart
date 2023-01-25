import 'dart:typed_data';

import 'package:realm_common/realm_common.dart';

@RealmModel()
class _Person {
  int x = 0;
  late _Person? parent = Person();
}
