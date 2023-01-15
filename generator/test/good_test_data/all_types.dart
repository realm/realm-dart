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

  late RealmValue any;
  late List<RealmValue> manyAny;
}

@RealmModel()
class _PrimitiveTypes {
  late String stringProp;
  late bool boolProp;
  late DateTime dateProp;
  late double doubleProp;
  late ObjectId objectIdProp;
}

@RealmModel()
class _RealmSets {
  @PrimaryKey()
  late int key;

  late Set<bool> boolSet;
  Set<bool> boolSetDefaultValues1 = { true, false };
  var boolSetDefaultValues2 = <bool>{ false, true };
  late Set<bool?> nullableBoolSet;

  late Set<int> intSet;
  Set<int> intSetDefaultValues1 = { 0, 1, 2 };
  var intSetDefaultValues2 = <int>{ 1, 2, 3 };
  late Set<int?> nullableintSet;

  late Set<String> stringSet;
  Set<String> stringSetDefaultValues1 = { "Tesla", "Audi" };
  var stringSetDefaultValues2 = <String>{ "VW", "Mercedes" };
  late Set<String?> nullablestringSet;

  late Set<double> doubleSet;
  Set<double> doubleSetDefaultValues1 = { 0.1, 0.2, 0.3 };
  var doubleSetDefaultValues2 = <double>{ 0.4, 0.5, 0.6 };
  late Set<double?> nullabledoubleSet;

  late Set<DateTime> dateTimeSet;
  Set<DateTime> dateTimeSetDefaultValues1 = { DateTime.utc(2023), DateTime.utc(2024) };
  var dateTimeSetDefaultValues2 = <DateTime>{ DateTime.utc(2025), DateTime.utc(2026) };
  late Set<DateTime?> nullabledateTimeSet;

  late Set<ObjectId> objectIdSet;
  Set<ObjectId> objectIdSetDefaultValues1 = { ObjectId.fromBytes([1]), ObjectId.fromBytes([2]) };
  var objectIdSetDefaultValues2 = <ObjectId>{ ObjectId.fromBytes([3]), ObjectId.fromBytes([4]) };
  late Set<ObjectId?> nullableobjectIdSet;

  late Set<Uuid> uuidSet;
  Set<Uuid> uuidSetDefaultValues1 = { Uuid.fromString("1"), Uuid.fromString("2") };
  var uuidSetDefaultValues2 = <Uuid>{ Uuid.fromString("3"), Uuid.fromString("4") };
  late Set<Uuid?> nullableuuidSet;

  late Set<RealmValue> realmValueSet;
  Set<RealmValue> realmValueSetDefaultValues1 = { RealmValue.from(null), RealmValue.from("2") };
  var realmValueSetDefaultValues2 = <RealmValue>{ RealmValue.from(3), RealmValue.from(true) };
  // late Set<RealmValue?> nullablerealmValueSet;
}
