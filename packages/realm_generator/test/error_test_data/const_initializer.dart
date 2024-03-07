import 'dart:math';

import 'package:realm_common/realm_common.dart';

part 'const_initializer.realm.dart';

@RealmModel()
class _Bad {
  var id = Random().nextInt(1000);
}
