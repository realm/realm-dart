import 'dart:typed_data';

import 'package:realm_common/realm_common.dart';

@RealmModel()
@MapTo('Fooo')
class _Foo {
  int x = 0;
}

@RealmModel()
class _Bar {
  @PrimaryKey()
  late String id;
  late bool aBool, another;
  var data = Uint8List(16);
  // late RealmAny any; // not supported yet
  @MapTo('tidspunkt')
  var timestamp = DateTime.now();
  var aDouble = 0.0;
  // late Decimal128 decimal; // not supported yet
  _Foo? foo;
  // late ObjectId id;
  // late Uuid uuid; // not supported yet
  @Ignored()
  var theMeaningOfEverything = 42;
  var list = [0]; // list of ints with default value
  // late Set<int> set; // not supported yet
  // late map = <String, int>{}; // not supported yet

  @Indexed()
  String? anOptionalString;

  late ObjectId objectId;
}

@RealmModel()
class _PrimitiveTypes {
  late String stringProp;
  late bool boolProp;
  late DateTime dateProp;
  late double doubleProp;
  late ObjectId objectIdProp;
}
