import 'dart:typed_data';

import 'package:realm_common/realm_common.dart';

part 'binary_type.realm.dart';

@RealmModel()
class _Foo {
  late Uint8List requiredBinaryProp;
  late Uint8List? nullableBinaryProp;
}
