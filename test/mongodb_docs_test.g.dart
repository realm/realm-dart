// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mongodb_docs_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class AtlasDocAllTypes extends _AtlasDocAllTypes
    with RealmEntity, RealmObjectBase, RealmObject {
  AtlasDocAllTypes(
    ObjectId id,
    String stringProp,
    bool boolProp,
    DateTime dateProp,
    double doubleProp,
    ObjectId objectIdProp,
    Uuid uuidProp,
    int intProp, {
    String? nullableStringProp,
    bool? nullableBoolProp,
    DateTime? nullableDateProp,
    double? nullableDoubleProp,
    ObjectId? nullableObjectIdProp,
    Uuid? nullableUuidProp,
    int? nullableIntProp,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'stringProp', stringProp);
    RealmObjectBase.set(this, 'boolProp', boolProp);
    RealmObjectBase.set(this, 'dateProp', dateProp);
    RealmObjectBase.set(this, 'doubleProp', doubleProp);
    RealmObjectBase.set(this, 'objectIdProp', objectIdProp);
    RealmObjectBase.set(this, 'uuidProp', uuidProp);
    RealmObjectBase.set(this, 'intProp', intProp);
    RealmObjectBase.set(this, 'nullableStringProp', nullableStringProp);
    RealmObjectBase.set(this, 'nullableBoolProp', nullableBoolProp);
    RealmObjectBase.set(this, 'nullableDateProp', nullableDateProp);
    RealmObjectBase.set(this, 'nullableDoubleProp', nullableDoubleProp);
    RealmObjectBase.set(this, 'nullableObjectIdProp', nullableObjectIdProp);
    RealmObjectBase.set(this, 'nullableUuidProp', nullableUuidProp);
    RealmObjectBase.set(this, 'nullableIntProp', nullableIntProp);
  }

  AtlasDocAllTypes._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get stringProp =>
      RealmObjectBase.get<String>(this, 'stringProp') as String;
  @override
  set stringProp(String value) =>
      RealmObjectBase.set(this, 'stringProp', value);

  @override
  bool get boolProp => RealmObjectBase.get<bool>(this, 'boolProp') as bool;
  @override
  set boolProp(bool value) => RealmObjectBase.set(this, 'boolProp', value);

  @override
  DateTime get dateProp =>
      RealmObjectBase.get<DateTime>(this, 'dateProp') as DateTime;
  @override
  set dateProp(DateTime value) => RealmObjectBase.set(this, 'dateProp', value);

  @override
  double get doubleProp =>
      RealmObjectBase.get<double>(this, 'doubleProp') as double;
  @override
  set doubleProp(double value) =>
      RealmObjectBase.set(this, 'doubleProp', value);

  @override
  ObjectId get objectIdProp =>
      RealmObjectBase.get<ObjectId>(this, 'objectIdProp') as ObjectId;
  @override
  set objectIdProp(ObjectId value) =>
      RealmObjectBase.set(this, 'objectIdProp', value);

  @override
  Uuid get uuidProp => RealmObjectBase.get<Uuid>(this, 'uuidProp') as Uuid;
  @override
  set uuidProp(Uuid value) => RealmObjectBase.set(this, 'uuidProp', value);

  @override
  int get intProp => RealmObjectBase.get<int>(this, 'intProp') as int;
  @override
  set intProp(int value) => RealmObjectBase.set(this, 'intProp', value);

  @override
  String? get nullableStringProp =>
      RealmObjectBase.get<String>(this, 'nullableStringProp') as String?;
  @override
  set nullableStringProp(String? value) =>
      RealmObjectBase.set(this, 'nullableStringProp', value);

  @override
  bool? get nullableBoolProp =>
      RealmObjectBase.get<bool>(this, 'nullableBoolProp') as bool?;
  @override
  set nullableBoolProp(bool? value) =>
      RealmObjectBase.set(this, 'nullableBoolProp', value);

  @override
  DateTime? get nullableDateProp =>
      RealmObjectBase.get<DateTime>(this, 'nullableDateProp') as DateTime?;
  @override
  set nullableDateProp(DateTime? value) =>
      RealmObjectBase.set(this, 'nullableDateProp', value);

  @override
  double? get nullableDoubleProp =>
      RealmObjectBase.get<double>(this, 'nullableDoubleProp') as double?;
  @override
  set nullableDoubleProp(double? value) =>
      RealmObjectBase.set(this, 'nullableDoubleProp', value);

  @override
  ObjectId? get nullableObjectIdProp =>
      RealmObjectBase.get<ObjectId>(this, 'nullableObjectIdProp') as ObjectId?;
  @override
  set nullableObjectIdProp(ObjectId? value) =>
      RealmObjectBase.set(this, 'nullableObjectIdProp', value);

  @override
  Uuid? get nullableUuidProp =>
      RealmObjectBase.get<Uuid>(this, 'nullableUuidProp') as Uuid?;
  @override
  set nullableUuidProp(Uuid? value) =>
      RealmObjectBase.set(this, 'nullableUuidProp', value);

  @override
  int? get nullableIntProp =>
      RealmObjectBase.get<int>(this, 'nullableIntProp') as int?;
  @override
  set nullableIntProp(int? value) =>
      RealmObjectBase.set(this, 'nullableIntProp', value);

  @override
  Stream<RealmObjectChanges<AtlasDocAllTypes>> get changes =>
      RealmObjectBase.getChanges<AtlasDocAllTypes>(this);

  @override
  AtlasDocAllTypes freeze() =>
      RealmObjectBase.freezeObject<AtlasDocAllTypes>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(AtlasDocAllTypes._);
    return const SchemaObject(
        ObjectType.realmObject, AtlasDocAllTypes, 'AtlasDocAllTypes', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('stringProp', RealmPropertyType.string),
      SchemaProperty('boolProp', RealmPropertyType.bool),
      SchemaProperty('dateProp', RealmPropertyType.timestamp),
      SchemaProperty('doubleProp', RealmPropertyType.double),
      SchemaProperty('objectIdProp', RealmPropertyType.objectid),
      SchemaProperty('uuidProp', RealmPropertyType.uuid),
      SchemaProperty('intProp', RealmPropertyType.int),
      SchemaProperty('nullableStringProp', RealmPropertyType.string,
          optional: true),
      SchemaProperty('nullableBoolProp', RealmPropertyType.bool,
          optional: true),
      SchemaProperty('nullableDateProp', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('nullableDoubleProp', RealmPropertyType.double,
          optional: true),
      SchemaProperty('nullableObjectIdProp', RealmPropertyType.objectid,
          optional: true),
      SchemaProperty('nullableUuidProp', RealmPropertyType.uuid,
          optional: true),
      SchemaProperty('nullableIntProp', RealmPropertyType.int, optional: true),
    ]);
  }
}
