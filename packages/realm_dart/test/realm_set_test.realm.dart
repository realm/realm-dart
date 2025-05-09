// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_set_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Car extends _Car with RealmEntity, RealmObjectBase, RealmObject {
  Car(
    String make, {
    String? color,
    int? year,
  }) {
    RealmObjectBase.set(this, 'make', make);
    RealmObjectBase.set(this, 'color', color);
    RealmObjectBase.set(this, 'year', year);
  }

  Car._();

  @override
  String get make => RealmObjectBase.get<String>(this, 'make') as String;
  @override
  set make(String value) => RealmObjectBase.set(this, 'make', value);

  @override
  String? get color => RealmObjectBase.get<String>(this, 'color') as String?;
  @override
  set color(String? value) => RealmObjectBase.set(this, 'color', value);

  @override
  int? get year => RealmObjectBase.get<int>(this, 'year') as int?;
  @override
  set year(int? value) => RealmObjectBase.set(this, 'year', value);

  @override
  Stream<RealmObjectChanges<Car>> get changes =>
      RealmObjectBase.getChanges<Car>(this);

  @override
  Stream<RealmObjectChanges<Car>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Car>(this, keyPaths);

  @override
  Car freeze() => RealmObjectBase.freezeObject<Car>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'make': make.toEJson(),
      'color': color.toEJson(),
      'year': year.toEJson(),
    };
  }

  static EJsonValue _toEJson(Car value) => value.toEJson();
  static Car _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'make': EJsonValue make,
      } =>
        Car(
          fromEJson(make),
          color: fromEJson(ejson['color']),
          year: fromEJson(ejson['year']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Car._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Car, 'Car', [
      SchemaProperty('make', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('color', RealmPropertyType.string, optional: true),
      SchemaProperty('year', RealmPropertyType.int, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class TestRealmSets extends _TestRealmSets
    with RealmEntity, RealmObjectBase, RealmObject {
  TestRealmSets(
    int key, {
    Set<bool> boolSet = const {},
    Set<int> intSet = const {},
    Set<String> stringSet = const {},
    Set<double> doubleSet = const {},
    Set<DateTime> dateTimeSet = const {},
    Set<ObjectId> objectIdSet = const {},
    Set<Uuid> uuidSet = const {},
    Set<RealmValue> mixedSet = const {},
    Set<Car> objectsSet = const {},
    Set<Uint8List> binarySet = const {},
    Set<bool?> nullableBoolSet = const {},
    Set<int?> nullableIntSet = const {},
    Set<String?> nullableStringSet = const {},
    Set<double?> nullableDoubleSet = const {},
    Set<DateTime?> nullableDateTimeSet = const {},
    Set<ObjectId?> nullableObjectIdSet = const {},
    Set<Uuid?> nullableUuidSet = const {},
    Set<Uint8List?> nullableBinarySet = const {},
  }) {
    RealmObjectBase.set(this, 'key', key);
    RealmObjectBase.set<RealmSet<bool>>(
        this, 'boolSet', RealmSet<bool>(boolSet));
    RealmObjectBase.set<RealmSet<int>>(this, 'intSet', RealmSet<int>(intSet));
    RealmObjectBase.set<RealmSet<String>>(
        this, 'stringSet', RealmSet<String>(stringSet));
    RealmObjectBase.set<RealmSet<double>>(
        this, 'doubleSet', RealmSet<double>(doubleSet));
    RealmObjectBase.set<RealmSet<DateTime>>(
        this, 'dateTimeSet', RealmSet<DateTime>(dateTimeSet));
    RealmObjectBase.set<RealmSet<ObjectId>>(
        this, 'objectIdSet', RealmSet<ObjectId>(objectIdSet));
    RealmObjectBase.set<RealmSet<Uuid>>(
        this, 'uuidSet', RealmSet<Uuid>(uuidSet));
    RealmObjectBase.set<RealmSet<RealmValue>>(
        this, 'mixedSet', RealmSet<RealmValue>(mixedSet));
    RealmObjectBase.set<RealmSet<Car>>(
        this, 'objectsSet', RealmSet<Car>(objectsSet));
    RealmObjectBase.set<RealmSet<Uint8List>>(
        this, 'binarySet', RealmSet<Uint8List>(binarySet));
    RealmObjectBase.set<RealmSet<bool?>>(
        this, 'nullableBoolSet', RealmSet<bool?>(nullableBoolSet));
    RealmObjectBase.set<RealmSet<int?>>(
        this, 'nullableIntSet', RealmSet<int?>(nullableIntSet));
    RealmObjectBase.set<RealmSet<String?>>(
        this, 'nullableStringSet', RealmSet<String?>(nullableStringSet));
    RealmObjectBase.set<RealmSet<double?>>(
        this, 'nullableDoubleSet', RealmSet<double?>(nullableDoubleSet));
    RealmObjectBase.set<RealmSet<DateTime?>>(
        this, 'nullableDateTimeSet', RealmSet<DateTime?>(nullableDateTimeSet));
    RealmObjectBase.set<RealmSet<ObjectId?>>(
        this, 'nullableObjectIdSet', RealmSet<ObjectId?>(nullableObjectIdSet));
    RealmObjectBase.set<RealmSet<Uuid?>>(
        this, 'nullableUuidSet', RealmSet<Uuid?>(nullableUuidSet));
    RealmObjectBase.set<RealmSet<Uint8List?>>(
        this, 'nullableBinarySet', RealmSet<Uint8List?>(nullableBinarySet));
  }

  TestRealmSets._();

  @override
  int get key => RealmObjectBase.get<int>(this, 'key') as int;
  @override
  set key(int value) => RealmObjectBase.set(this, 'key', value);

  @override
  RealmSet<bool> get boolSet =>
      RealmObjectBase.get<bool>(this, 'boolSet') as RealmSet<bool>;
  @override
  set boolSet(covariant RealmSet<bool> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<int> get intSet =>
      RealmObjectBase.get<int>(this, 'intSet') as RealmSet<int>;
  @override
  set intSet(covariant RealmSet<int> value) => throw RealmUnsupportedSetError();

  @override
  RealmSet<String> get stringSet =>
      RealmObjectBase.get<String>(this, 'stringSet') as RealmSet<String>;
  @override
  set stringSet(covariant RealmSet<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<double> get doubleSet =>
      RealmObjectBase.get<double>(this, 'doubleSet') as RealmSet<double>;
  @override
  set doubleSet(covariant RealmSet<double> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<DateTime> get dateTimeSet =>
      RealmObjectBase.get<DateTime>(this, 'dateTimeSet') as RealmSet<DateTime>;
  @override
  set dateTimeSet(covariant RealmSet<DateTime> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<ObjectId> get objectIdSet =>
      RealmObjectBase.get<ObjectId>(this, 'objectIdSet') as RealmSet<ObjectId>;
  @override
  set objectIdSet(covariant RealmSet<ObjectId> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<Uuid> get uuidSet =>
      RealmObjectBase.get<Uuid>(this, 'uuidSet') as RealmSet<Uuid>;
  @override
  set uuidSet(covariant RealmSet<Uuid> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<RealmValue> get mixedSet =>
      RealmObjectBase.get<RealmValue>(this, 'mixedSet') as RealmSet<RealmValue>;
  @override
  set mixedSet(covariant RealmSet<RealmValue> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<Car> get objectsSet =>
      RealmObjectBase.get<Car>(this, 'objectsSet') as RealmSet<Car>;
  @override
  set objectsSet(covariant RealmSet<Car> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<Uint8List> get binarySet =>
      RealmObjectBase.get<Uint8List>(this, 'binarySet') as RealmSet<Uint8List>;
  @override
  set binarySet(covariant RealmSet<Uint8List> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<bool?> get nullableBoolSet =>
      RealmObjectBase.get<bool?>(this, 'nullableBoolSet') as RealmSet<bool?>;
  @override
  set nullableBoolSet(covariant RealmSet<bool?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<int?> get nullableIntSet =>
      RealmObjectBase.get<int?>(this, 'nullableIntSet') as RealmSet<int?>;
  @override
  set nullableIntSet(covariant RealmSet<int?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<String?> get nullableStringSet =>
      RealmObjectBase.get<String?>(this, 'nullableStringSet')
          as RealmSet<String?>;
  @override
  set nullableStringSet(covariant RealmSet<String?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<double?> get nullableDoubleSet =>
      RealmObjectBase.get<double?>(this, 'nullableDoubleSet')
          as RealmSet<double?>;
  @override
  set nullableDoubleSet(covariant RealmSet<double?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<DateTime?> get nullableDateTimeSet =>
      RealmObjectBase.get<DateTime?>(this, 'nullableDateTimeSet')
          as RealmSet<DateTime?>;
  @override
  set nullableDateTimeSet(covariant RealmSet<DateTime?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<ObjectId?> get nullableObjectIdSet =>
      RealmObjectBase.get<ObjectId?>(this, 'nullableObjectIdSet')
          as RealmSet<ObjectId?>;
  @override
  set nullableObjectIdSet(covariant RealmSet<ObjectId?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<Uuid?> get nullableUuidSet =>
      RealmObjectBase.get<Uuid?>(this, 'nullableUuidSet') as RealmSet<Uuid?>;
  @override
  set nullableUuidSet(covariant RealmSet<Uuid?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<Uint8List?> get nullableBinarySet =>
      RealmObjectBase.get<Uint8List?>(this, 'nullableBinarySet')
          as RealmSet<Uint8List?>;
  @override
  set nullableBinarySet(covariant RealmSet<Uint8List?> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<TestRealmSets>> get changes =>
      RealmObjectBase.getChanges<TestRealmSets>(this);

  @override
  Stream<RealmObjectChanges<TestRealmSets>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<TestRealmSets>(this, keyPaths);

  @override
  TestRealmSets freeze() => RealmObjectBase.freezeObject<TestRealmSets>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'key': key.toEJson(),
      'boolSet': boolSet.toEJson(),
      'intSet': intSet.toEJson(),
      'stringSet': stringSet.toEJson(),
      'doubleSet': doubleSet.toEJson(),
      'dateTimeSet': dateTimeSet.toEJson(),
      'objectIdSet': objectIdSet.toEJson(),
      'uuidSet': uuidSet.toEJson(),
      'mixedSet': mixedSet.toEJson(),
      'objectsSet': objectsSet.toEJson(),
      'binarySet': binarySet.toEJson(),
      'nullableBoolSet': nullableBoolSet.toEJson(),
      'nullableIntSet': nullableIntSet.toEJson(),
      'nullableStringSet': nullableStringSet.toEJson(),
      'nullableDoubleSet': nullableDoubleSet.toEJson(),
      'nullableDateTimeSet': nullableDateTimeSet.toEJson(),
      'nullableObjectIdSet': nullableObjectIdSet.toEJson(),
      'nullableUuidSet': nullableUuidSet.toEJson(),
      'nullableBinarySet': nullableBinarySet.toEJson(),
    };
  }

  static EJsonValue _toEJson(TestRealmSets value) => value.toEJson();
  static TestRealmSets _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'key': EJsonValue key,
      } =>
        TestRealmSets(
          fromEJson(key),
          boolSet: fromEJson(ejson['boolSet']),
          intSet: fromEJson(ejson['intSet']),
          stringSet: fromEJson(ejson['stringSet']),
          doubleSet: fromEJson(ejson['doubleSet']),
          dateTimeSet: fromEJson(ejson['dateTimeSet']),
          objectIdSet: fromEJson(ejson['objectIdSet']),
          uuidSet: fromEJson(ejson['uuidSet']),
          mixedSet: fromEJson(ejson['mixedSet']),
          objectsSet: fromEJson(ejson['objectsSet']),
          binarySet: fromEJson(ejson['binarySet']),
          nullableBoolSet: fromEJson(ejson['nullableBoolSet']),
          nullableIntSet: fromEJson(ejson['nullableIntSet']),
          nullableStringSet: fromEJson(ejson['nullableStringSet']),
          nullableDoubleSet: fromEJson(ejson['nullableDoubleSet']),
          nullableDateTimeSet: fromEJson(ejson['nullableDateTimeSet']),
          nullableObjectIdSet: fromEJson(ejson['nullableObjectIdSet']),
          nullableUuidSet: fromEJson(ejson['nullableUuidSet']),
          nullableBinarySet: fromEJson(ejson['nullableBinarySet']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(TestRealmSets._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, TestRealmSets, 'TestRealmSets', [
      SchemaProperty('key', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('boolSet', RealmPropertyType.bool,
          collectionType: RealmCollectionType.set),
      SchemaProperty('intSet', RealmPropertyType.int,
          collectionType: RealmCollectionType.set),
      SchemaProperty('stringSet', RealmPropertyType.string,
          collectionType: RealmCollectionType.set),
      SchemaProperty('doubleSet', RealmPropertyType.double,
          collectionType: RealmCollectionType.set),
      SchemaProperty('dateTimeSet', RealmPropertyType.timestamp,
          collectionType: RealmCollectionType.set),
      SchemaProperty('objectIdSet', RealmPropertyType.objectid,
          collectionType: RealmCollectionType.set),
      SchemaProperty('uuidSet', RealmPropertyType.uuid,
          collectionType: RealmCollectionType.set),
      SchemaProperty('mixedSet', RealmPropertyType.mixed,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('objectsSet', RealmPropertyType.object,
          linkTarget: 'Car', collectionType: RealmCollectionType.set),
      SchemaProperty('binarySet', RealmPropertyType.binary,
          collectionType: RealmCollectionType.set),
      SchemaProperty('nullableBoolSet', RealmPropertyType.bool,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableIntSet', RealmPropertyType.int,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableStringSet', RealmPropertyType.string,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableDoubleSet', RealmPropertyType.double,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableDateTimeSet', RealmPropertyType.timestamp,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableObjectIdSet', RealmPropertyType.objectid,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableUuidSet', RealmPropertyType.uuid,
          optional: true, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableBinarySet', RealmPropertyType.binary,
          optional: true, collectionType: RealmCollectionType.set),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
