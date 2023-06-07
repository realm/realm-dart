import 'dart:typed_data';

import 'package:realm_common/realm_common.dart';

part 'all_types.realm.dart';

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
  late List<int> list;
  late Set<int> set;
  late Map<String, int> map;

  @Indexed()
  String? anOptionalString;

  @Backlink(#bar)
  late Iterable<_Foo> foos;

  late RealmValue any;
  late List<RealmValue> manyAny;

  late Decimal128 decimal;
}

@RealmModel()
class _PrimitiveTypes {
  late String stringProp;
  late bool boolProp;
  late DateTime dateProp;
  late double doubleProp;
  late ObjectId objectIdProp;
}
