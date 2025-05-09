// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_map_test.dart';

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

class EmbeddedValue extends _EmbeddedValue
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  EmbeddedValue(
    int intValue,
  ) {
    RealmObjectBase.set(this, 'intValue', intValue);
  }

  EmbeddedValue._();

  @override
  int get intValue => RealmObjectBase.get<int>(this, 'intValue') as int;
  @override
  set intValue(int value) => RealmObjectBase.set(this, 'intValue', value);

  @override
  Stream<RealmObjectChanges<EmbeddedValue>> get changes =>
      RealmObjectBase.getChanges<EmbeddedValue>(this);

  @override
  Stream<RealmObjectChanges<EmbeddedValue>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<EmbeddedValue>(this, keyPaths);

  @override
  EmbeddedValue freeze() => RealmObjectBase.freezeObject<EmbeddedValue>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'intValue': intValue.toEJson(),
    };
  }

  static EJsonValue _toEJson(EmbeddedValue value) => value.toEJson();
  static EmbeddedValue _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'intValue': EJsonValue intValue,
      } =>
        EmbeddedValue(
          fromEJson(intValue),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(EmbeddedValue._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.embeddedObject, EmbeddedValue, 'EmbeddedValue', [
      SchemaProperty('intValue', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class TestRealmMaps extends _TestRealmMaps
    with RealmEntity, RealmObjectBase, RealmObject {
  TestRealmMaps(
    int key, {
    Map<String, bool> boolMap = const {},
    Map<String, int> intMap = const {},
    Map<String, String> stringMap = const {},
    Map<String, double> doubleMap = const {},
    Map<String, DateTime> dateTimeMap = const {},
    Map<String, ObjectId> objectIdMap = const {},
    Map<String, Uuid> uuidMap = const {},
    Map<String, Uint8List> binaryMap = const {},
    Map<String, Decimal128> decimalMap = const {},
    Map<String, bool?> nullableBoolMap = const {},
    Map<String, int?> nullableIntMap = const {},
    Map<String, String?> nullableStringMap = const {},
    Map<String, double?> nullableDoubleMap = const {},
    Map<String, DateTime?> nullableDateTimeMap = const {},
    Map<String, ObjectId?> nullableObjectIdMap = const {},
    Map<String, Uuid?> nullableUuidMap = const {},
    Map<String, Uint8List?> nullableBinaryMap = const {},
    Map<String, Decimal128?> nullableDecimalMap = const {},
    Map<String, Car?> objectsMap = const {},
    Map<String, EmbeddedValue?> embeddedMap = const {},
    Map<String, RealmValue> mixedMap = const {},
  }) {
    RealmObjectBase.set(this, 'key', key);
    RealmObjectBase.set<RealmMap<bool>>(
        this, 'boolMap', RealmMap<bool>(boolMap));
    RealmObjectBase.set<RealmMap<int>>(this, 'intMap', RealmMap<int>(intMap));
    RealmObjectBase.set<RealmMap<String>>(
        this, 'stringMap', RealmMap<String>(stringMap));
    RealmObjectBase.set<RealmMap<double>>(
        this, 'doubleMap', RealmMap<double>(doubleMap));
    RealmObjectBase.set<RealmMap<DateTime>>(
        this, 'dateTimeMap', RealmMap<DateTime>(dateTimeMap));
    RealmObjectBase.set<RealmMap<ObjectId>>(
        this, 'objectIdMap', RealmMap<ObjectId>(objectIdMap));
    RealmObjectBase.set<RealmMap<Uuid>>(
        this, 'uuidMap', RealmMap<Uuid>(uuidMap));
    RealmObjectBase.set<RealmMap<Uint8List>>(
        this, 'binaryMap', RealmMap<Uint8List>(binaryMap));
    RealmObjectBase.set<RealmMap<Decimal128>>(
        this, 'decimalMap', RealmMap<Decimal128>(decimalMap));
    RealmObjectBase.set<RealmMap<bool?>>(
        this, 'nullableBoolMap', RealmMap<bool?>(nullableBoolMap));
    RealmObjectBase.set<RealmMap<int?>>(
        this, 'nullableIntMap', RealmMap<int?>(nullableIntMap));
    RealmObjectBase.set<RealmMap<String?>>(
        this, 'nullableStringMap', RealmMap<String?>(nullableStringMap));
    RealmObjectBase.set<RealmMap<double?>>(
        this, 'nullableDoubleMap', RealmMap<double?>(nullableDoubleMap));
    RealmObjectBase.set<RealmMap<DateTime?>>(
        this, 'nullableDateTimeMap', RealmMap<DateTime?>(nullableDateTimeMap));
    RealmObjectBase.set<RealmMap<ObjectId?>>(
        this, 'nullableObjectIdMap', RealmMap<ObjectId?>(nullableObjectIdMap));
    RealmObjectBase.set<RealmMap<Uuid?>>(
        this, 'nullableUuidMap', RealmMap<Uuid?>(nullableUuidMap));
    RealmObjectBase.set<RealmMap<Uint8List?>>(
        this, 'nullableBinaryMap', RealmMap<Uint8List?>(nullableBinaryMap));
    RealmObjectBase.set<RealmMap<Decimal128?>>(
        this, 'nullableDecimalMap', RealmMap<Decimal128?>(nullableDecimalMap));
    RealmObjectBase.set<RealmMap<Car?>>(
        this, 'objectsMap', RealmMap<Car?>(objectsMap));
    RealmObjectBase.set<RealmMap<EmbeddedValue?>>(
        this, 'embeddedMap', RealmMap<EmbeddedValue?>(embeddedMap));
    RealmObjectBase.set<RealmMap<RealmValue>>(
        this, 'mixedMap', RealmMap<RealmValue>(mixedMap));
  }

  TestRealmMaps._();

  @override
  int get key => RealmObjectBase.get<int>(this, 'key') as int;
  @override
  set key(int value) => RealmObjectBase.set(this, 'key', value);

  @override
  RealmMap<bool> get boolMap =>
      RealmObjectBase.get<bool>(this, 'boolMap') as RealmMap<bool>;
  @override
  set boolMap(covariant RealmMap<bool> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<int> get intMap =>
      RealmObjectBase.get<int>(this, 'intMap') as RealmMap<int>;
  @override
  set intMap(covariant RealmMap<int> value) => throw RealmUnsupportedSetError();

  @override
  RealmMap<String> get stringMap =>
      RealmObjectBase.get<String>(this, 'stringMap') as RealmMap<String>;
  @override
  set stringMap(covariant RealmMap<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<double> get doubleMap =>
      RealmObjectBase.get<double>(this, 'doubleMap') as RealmMap<double>;
  @override
  set doubleMap(covariant RealmMap<double> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<DateTime> get dateTimeMap =>
      RealmObjectBase.get<DateTime>(this, 'dateTimeMap') as RealmMap<DateTime>;
  @override
  set dateTimeMap(covariant RealmMap<DateTime> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<ObjectId> get objectIdMap =>
      RealmObjectBase.get<ObjectId>(this, 'objectIdMap') as RealmMap<ObjectId>;
  @override
  set objectIdMap(covariant RealmMap<ObjectId> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<Uuid> get uuidMap =>
      RealmObjectBase.get<Uuid>(this, 'uuidMap') as RealmMap<Uuid>;
  @override
  set uuidMap(covariant RealmMap<Uuid> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<Uint8List> get binaryMap =>
      RealmObjectBase.get<Uint8List>(this, 'binaryMap') as RealmMap<Uint8List>;
  @override
  set binaryMap(covariant RealmMap<Uint8List> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<Decimal128> get decimalMap =>
      RealmObjectBase.get<Decimal128>(this, 'decimalMap')
          as RealmMap<Decimal128>;
  @override
  set decimalMap(covariant RealmMap<Decimal128> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<bool?> get nullableBoolMap =>
      RealmObjectBase.get<bool?>(this, 'nullableBoolMap') as RealmMap<bool?>;
  @override
  set nullableBoolMap(covariant RealmMap<bool?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<int?> get nullableIntMap =>
      RealmObjectBase.get<int?>(this, 'nullableIntMap') as RealmMap<int?>;
  @override
  set nullableIntMap(covariant RealmMap<int?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<String?> get nullableStringMap =>
      RealmObjectBase.get<String?>(this, 'nullableStringMap')
          as RealmMap<String?>;
  @override
  set nullableStringMap(covariant RealmMap<String?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<double?> get nullableDoubleMap =>
      RealmObjectBase.get<double?>(this, 'nullableDoubleMap')
          as RealmMap<double?>;
  @override
  set nullableDoubleMap(covariant RealmMap<double?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<DateTime?> get nullableDateTimeMap =>
      RealmObjectBase.get<DateTime?>(this, 'nullableDateTimeMap')
          as RealmMap<DateTime?>;
  @override
  set nullableDateTimeMap(covariant RealmMap<DateTime?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<ObjectId?> get nullableObjectIdMap =>
      RealmObjectBase.get<ObjectId?>(this, 'nullableObjectIdMap')
          as RealmMap<ObjectId?>;
  @override
  set nullableObjectIdMap(covariant RealmMap<ObjectId?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<Uuid?> get nullableUuidMap =>
      RealmObjectBase.get<Uuid?>(this, 'nullableUuidMap') as RealmMap<Uuid?>;
  @override
  set nullableUuidMap(covariant RealmMap<Uuid?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<Uint8List?> get nullableBinaryMap =>
      RealmObjectBase.get<Uint8List?>(this, 'nullableBinaryMap')
          as RealmMap<Uint8List?>;
  @override
  set nullableBinaryMap(covariant RealmMap<Uint8List?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<Decimal128?> get nullableDecimalMap =>
      RealmObjectBase.get<Decimal128?>(this, 'nullableDecimalMap')
          as RealmMap<Decimal128?>;
  @override
  set nullableDecimalMap(covariant RealmMap<Decimal128?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<Car?> get objectsMap =>
      RealmObjectBase.get<Car?>(this, 'objectsMap') as RealmMap<Car?>;
  @override
  set objectsMap(covariant RealmMap<Car?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<EmbeddedValue?> get embeddedMap =>
      RealmObjectBase.get<EmbeddedValue?>(this, 'embeddedMap')
          as RealmMap<EmbeddedValue?>;
  @override
  set embeddedMap(covariant RealmMap<EmbeddedValue?> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<RealmValue> get mixedMap =>
      RealmObjectBase.get<RealmValue>(this, 'mixedMap') as RealmMap<RealmValue>;
  @override
  set mixedMap(covariant RealmMap<RealmValue> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<TestRealmMaps>> get changes =>
      RealmObjectBase.getChanges<TestRealmMaps>(this);

  @override
  Stream<RealmObjectChanges<TestRealmMaps>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<TestRealmMaps>(this, keyPaths);

  @override
  TestRealmMaps freeze() => RealmObjectBase.freezeObject<TestRealmMaps>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'key': key.toEJson(),
      'boolMap': boolMap.toEJson(),
      'intMap': intMap.toEJson(),
      'stringMap': stringMap.toEJson(),
      'doubleMap': doubleMap.toEJson(),
      'dateTimeMap': dateTimeMap.toEJson(),
      'objectIdMap': objectIdMap.toEJson(),
      'uuidMap': uuidMap.toEJson(),
      'binaryMap': binaryMap.toEJson(),
      'decimalMap': decimalMap.toEJson(),
      'nullableBoolMap': nullableBoolMap.toEJson(),
      'nullableIntMap': nullableIntMap.toEJson(),
      'nullableStringMap': nullableStringMap.toEJson(),
      'nullableDoubleMap': nullableDoubleMap.toEJson(),
      'nullableDateTimeMap': nullableDateTimeMap.toEJson(),
      'nullableObjectIdMap': nullableObjectIdMap.toEJson(),
      'nullableUuidMap': nullableUuidMap.toEJson(),
      'nullableBinaryMap': nullableBinaryMap.toEJson(),
      'nullableDecimalMap': nullableDecimalMap.toEJson(),
      'objectsMap': objectsMap.toEJson(),
      'embeddedMap': embeddedMap.toEJson(),
      'mixedMap': mixedMap.toEJson(),
    };
  }

  static EJsonValue _toEJson(TestRealmMaps value) => value.toEJson();
  static TestRealmMaps _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'key': EJsonValue key,
      } =>
        TestRealmMaps(
          fromEJson(key),
          boolMap: fromEJson(ejson['boolMap']),
          intMap: fromEJson(ejson['intMap']),
          stringMap: fromEJson(ejson['stringMap']),
          doubleMap: fromEJson(ejson['doubleMap']),
          dateTimeMap: fromEJson(ejson['dateTimeMap']),
          objectIdMap: fromEJson(ejson['objectIdMap']),
          uuidMap: fromEJson(ejson['uuidMap']),
          binaryMap: fromEJson(ejson['binaryMap']),
          decimalMap: fromEJson(ejson['decimalMap']),
          nullableBoolMap: fromEJson(ejson['nullableBoolMap']),
          nullableIntMap: fromEJson(ejson['nullableIntMap']),
          nullableStringMap: fromEJson(ejson['nullableStringMap']),
          nullableDoubleMap: fromEJson(ejson['nullableDoubleMap']),
          nullableDateTimeMap: fromEJson(ejson['nullableDateTimeMap']),
          nullableObjectIdMap: fromEJson(ejson['nullableObjectIdMap']),
          nullableUuidMap: fromEJson(ejson['nullableUuidMap']),
          nullableBinaryMap: fromEJson(ejson['nullableBinaryMap']),
          nullableDecimalMap: fromEJson(ejson['nullableDecimalMap']),
          objectsMap: fromEJson(ejson['objectsMap']),
          embeddedMap: fromEJson(ejson['embeddedMap']),
          mixedMap: fromEJson(ejson['mixedMap']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(TestRealmMaps._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, TestRealmMaps, 'TestRealmMaps', [
      SchemaProperty('key', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('boolMap', RealmPropertyType.bool,
          collectionType: RealmCollectionType.map),
      SchemaProperty('intMap', RealmPropertyType.int,
          collectionType: RealmCollectionType.map),
      SchemaProperty('stringMap', RealmPropertyType.string,
          collectionType: RealmCollectionType.map),
      SchemaProperty('doubleMap', RealmPropertyType.double,
          collectionType: RealmCollectionType.map),
      SchemaProperty('dateTimeMap', RealmPropertyType.timestamp,
          collectionType: RealmCollectionType.map),
      SchemaProperty('objectIdMap', RealmPropertyType.objectid,
          collectionType: RealmCollectionType.map),
      SchemaProperty('uuidMap', RealmPropertyType.uuid,
          collectionType: RealmCollectionType.map),
      SchemaProperty('binaryMap', RealmPropertyType.binary,
          collectionType: RealmCollectionType.map),
      SchemaProperty('decimalMap', RealmPropertyType.decimal128,
          collectionType: RealmCollectionType.map),
      SchemaProperty('nullableBoolMap', RealmPropertyType.bool,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableIntMap', RealmPropertyType.int,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableStringMap', RealmPropertyType.string,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableDoubleMap', RealmPropertyType.double,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableDateTimeMap', RealmPropertyType.timestamp,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableObjectIdMap', RealmPropertyType.objectid,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableUuidMap', RealmPropertyType.uuid,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableBinaryMap', RealmPropertyType.binary,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('nullableDecimalMap', RealmPropertyType.decimal128,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('objectsMap', RealmPropertyType.object,
          optional: true,
          linkTarget: 'Car',
          collectionType: RealmCollectionType.map),
      SchemaProperty('embeddedMap', RealmPropertyType.object,
          optional: true,
          linkTarget: 'EmbeddedValue',
          collectionType: RealmCollectionType.map),
      SchemaProperty('mixedMap', RealmPropertyType.mixed,
          optional: true, collectionType: RealmCollectionType.map),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
