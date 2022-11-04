import 'dart:typed_data';

import 'package:realm_common/realm_common.dart';

@RealmModel()
@MapTo('MyFoo')
class _Foo {
  @Indexed()
  int x = 0;
  late _Bar? bar;
}

@RealmModel()
class _Bar {
  @PrimaryKey()
  late String name;
  @Indexed()
  late bool aBool, another; // both are indexed!
  var data = Uint8List(16);
  // late RealmAny any; // not supported yet
  @MapTo('tidspunkt')
  @Indexed()
  var timestamp = DateTime.now();
  var aDouble = 0.0;
  // late Decimal128 decimal; // not supported yet
  _Foo? foo;
  @Indexed()
  late ObjectId objectId;
  @Indexed()
  late Uuid uuid;
  @Ignored()
  var theMeaningOfEverything = 42;
  var list = [0]; // list of ints with default value
  // late Set<int> set; // not supported yet
  // late map = <String, int>{}; // not supported yet

  @Indexed()
  String? anOptionalString;

  @Backlink(#bar)
  late Iterable<_Foo> foos;
}

@RealmModel()
class _PrimitiveTypes {
  late String stringProp;
  late bool boolProp;
  late DateTime dateProp;
  late double doubleProp;
  late ObjectId objectIdProp;
}
