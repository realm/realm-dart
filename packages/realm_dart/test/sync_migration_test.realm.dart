// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_migration_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class NullablesV0 extends _NullablesV0
    with RealmEntity, RealmObjectBase, RealmObject {
  NullablesV0(
    ObjectId id,
    ObjectId differentiator, {
    bool? boolValue,
    int? intValue,
    double? doubleValue,
    Decimal128? decimalValue,
    DateTime? dateValue,
    String? stringValue,
    ObjectId? objectIdValue,
    Uuid? uuidValue,
    Uint8List? binaryValue,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'differentiator', differentiator);
    RealmObjectBase.set(this, 'boolValue', boolValue);
    RealmObjectBase.set(this, 'intValue', intValue);
    RealmObjectBase.set(this, 'doubleValue', doubleValue);
    RealmObjectBase.set(this, 'decimalValue', decimalValue);
    RealmObjectBase.set(this, 'dateValue', dateValue);
    RealmObjectBase.set(this, 'stringValue', stringValue);
    RealmObjectBase.set(this, 'objectIdValue', objectIdValue);
    RealmObjectBase.set(this, 'uuidValue', uuidValue);
    RealmObjectBase.set(this, 'binaryValue', binaryValue);
  }

  NullablesV0._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  ObjectId get differentiator =>
      RealmObjectBase.get<ObjectId>(this, 'differentiator') as ObjectId;
  @override
  set differentiator(ObjectId value) =>
      RealmObjectBase.set(this, 'differentiator', value);

  @override
  bool? get boolValue => RealmObjectBase.get<bool>(this, 'boolValue') as bool?;
  @override
  set boolValue(bool? value) => RealmObjectBase.set(this, 'boolValue', value);

  @override
  int? get intValue => RealmObjectBase.get<int>(this, 'intValue') as int?;
  @override
  set intValue(int? value) => RealmObjectBase.set(this, 'intValue', value);

  @override
  double? get doubleValue =>
      RealmObjectBase.get<double>(this, 'doubleValue') as double?;
  @override
  set doubleValue(double? value) =>
      RealmObjectBase.set(this, 'doubleValue', value);

  @override
  Decimal128? get decimalValue =>
      RealmObjectBase.get<Decimal128>(this, 'decimalValue') as Decimal128?;
  @override
  set decimalValue(Decimal128? value) =>
      RealmObjectBase.set(this, 'decimalValue', value);

  @override
  DateTime? get dateValue =>
      RealmObjectBase.get<DateTime>(this, 'dateValue') as DateTime?;
  @override
  set dateValue(DateTime? value) =>
      RealmObjectBase.set(this, 'dateValue', value);

  @override
  String? get stringValue =>
      RealmObjectBase.get<String>(this, 'stringValue') as String?;
  @override
  set stringValue(String? value) =>
      RealmObjectBase.set(this, 'stringValue', value);

  @override
  ObjectId? get objectIdValue =>
      RealmObjectBase.get<ObjectId>(this, 'objectIdValue') as ObjectId?;
  @override
  set objectIdValue(ObjectId? value) =>
      RealmObjectBase.set(this, 'objectIdValue', value);

  @override
  Uuid? get uuidValue => RealmObjectBase.get<Uuid>(this, 'uuidValue') as Uuid?;
  @override
  set uuidValue(Uuid? value) => RealmObjectBase.set(this, 'uuidValue', value);

  @override
  Uint8List? get binaryValue =>
      RealmObjectBase.get<Uint8List>(this, 'binaryValue') as Uint8List?;
  @override
  set binaryValue(Uint8List? value) =>
      RealmObjectBase.set(this, 'binaryValue', value);

  @override
  Stream<RealmObjectChanges<NullablesV0>> get changes =>
      RealmObjectBase.getChanges<NullablesV0>(this);

  @override
  NullablesV0 freeze() => RealmObjectBase.freezeObject<NullablesV0>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'differentiator': differentiator.toEJson(),
      'boolValue': boolValue.toEJson(),
      'intValue': intValue.toEJson(),
      'doubleValue': doubleValue.toEJson(),
      'decimalValue': decimalValue.toEJson(),
      'dateValue': dateValue.toEJson(),
      'stringValue': stringValue.toEJson(),
      'objectIdValue': objectIdValue.toEJson(),
      'uuidValue': uuidValue.toEJson(),
      'binaryValue': binaryValue.toEJson(),
    };
  }

  static EJsonValue _toEJson(NullablesV0 value) => value.toEJson();
  static NullablesV0 _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'differentiator': EJsonValue differentiator,
        'boolValue': EJsonValue boolValue,
        'intValue': EJsonValue intValue,
        'doubleValue': EJsonValue doubleValue,
        'decimalValue': EJsonValue decimalValue,
        'dateValue': EJsonValue dateValue,
        'stringValue': EJsonValue stringValue,
        'objectIdValue': EJsonValue objectIdValue,
        'uuidValue': EJsonValue uuidValue,
        'binaryValue': EJsonValue binaryValue,
      } =>
        NullablesV0(
          fromEJson(id),
          fromEJson(differentiator),
          boolValue: fromEJson(boolValue),
          intValue: fromEJson(intValue),
          doubleValue: fromEJson(doubleValue),
          decimalValue: fromEJson(decimalValue),
          dateValue: fromEJson(dateValue),
          stringValue: fromEJson(stringValue),
          objectIdValue: fromEJson(objectIdValue),
          uuidValue: fromEJson(uuidValue),
          binaryValue: fromEJson(binaryValue),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(NullablesV0._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.realmObject, NullablesV0, 'Nullables', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('differentiator', RealmPropertyType.objectid),
      SchemaProperty('boolValue', RealmPropertyType.bool, optional: true),
      SchemaProperty('intValue', RealmPropertyType.int, optional: true),
      SchemaProperty('doubleValue', RealmPropertyType.double, optional: true),
      SchemaProperty('decimalValue', RealmPropertyType.decimal128,
          optional: true),
      SchemaProperty('dateValue', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('stringValue', RealmPropertyType.string, optional: true),
      SchemaProperty('objectIdValue', RealmPropertyType.objectid,
          optional: true),
      SchemaProperty('uuidValue', RealmPropertyType.uuid, optional: true),
      SchemaProperty('binaryValue', RealmPropertyType.binary, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class NullablesV1 extends _NullablesV1
    with RealmEntity, RealmObjectBase, RealmObject {
  NullablesV1(
    ObjectId id,
    ObjectId differentiator,
    bool boolValue,
    int intValue,
    double doubleValue,
    Decimal128 decimalValue,
    DateTime dateValue,
    String stringValue,
    ObjectId objectIdValue,
    Uuid uuidValue,
    Uint8List binaryValue,
    String willBeRemoved,
  ) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'differentiator', differentiator);
    RealmObjectBase.set(this, 'boolValue', boolValue);
    RealmObjectBase.set(this, 'intValue', intValue);
    RealmObjectBase.set(this, 'doubleValue', doubleValue);
    RealmObjectBase.set(this, 'decimalValue', decimalValue);
    RealmObjectBase.set(this, 'dateValue', dateValue);
    RealmObjectBase.set(this, 'stringValue', stringValue);
    RealmObjectBase.set(this, 'objectIdValue', objectIdValue);
    RealmObjectBase.set(this, 'uuidValue', uuidValue);
    RealmObjectBase.set(this, 'binaryValue', binaryValue);
    RealmObjectBase.set(this, 'willBeRemoved', willBeRemoved);
  }

  NullablesV1._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  ObjectId get differentiator =>
      RealmObjectBase.get<ObjectId>(this, 'differentiator') as ObjectId;
  @override
  set differentiator(ObjectId value) =>
      RealmObjectBase.set(this, 'differentiator', value);

  @override
  bool get boolValue => RealmObjectBase.get<bool>(this, 'boolValue') as bool;
  @override
  set boolValue(bool value) => RealmObjectBase.set(this, 'boolValue', value);

  @override
  int get intValue => RealmObjectBase.get<int>(this, 'intValue') as int;
  @override
  set intValue(int value) => RealmObjectBase.set(this, 'intValue', value);

  @override
  double get doubleValue =>
      RealmObjectBase.get<double>(this, 'doubleValue') as double;
  @override
  set doubleValue(double value) =>
      RealmObjectBase.set(this, 'doubleValue', value);

  @override
  Decimal128 get decimalValue =>
      RealmObjectBase.get<Decimal128>(this, 'decimalValue') as Decimal128;
  @override
  set decimalValue(Decimal128 value) =>
      RealmObjectBase.set(this, 'decimalValue', value);

  @override
  DateTime get dateValue =>
      RealmObjectBase.get<DateTime>(this, 'dateValue') as DateTime;
  @override
  set dateValue(DateTime value) =>
      RealmObjectBase.set(this, 'dateValue', value);

  @override
  String get stringValue =>
      RealmObjectBase.get<String>(this, 'stringValue') as String;
  @override
  set stringValue(String value) =>
      RealmObjectBase.set(this, 'stringValue', value);

  @override
  ObjectId get objectIdValue =>
      RealmObjectBase.get<ObjectId>(this, 'objectIdValue') as ObjectId;
  @override
  set objectIdValue(ObjectId value) =>
      RealmObjectBase.set(this, 'objectIdValue', value);

  @override
  Uuid get uuidValue => RealmObjectBase.get<Uuid>(this, 'uuidValue') as Uuid;
  @override
  set uuidValue(Uuid value) => RealmObjectBase.set(this, 'uuidValue', value);

  @override
  Uint8List get binaryValue =>
      RealmObjectBase.get<Uint8List>(this, 'binaryValue') as Uint8List;
  @override
  set binaryValue(Uint8List value) =>
      RealmObjectBase.set(this, 'binaryValue', value);

  @override
  String get willBeRemoved =>
      RealmObjectBase.get<String>(this, 'willBeRemoved') as String;
  @override
  set willBeRemoved(String value) =>
      RealmObjectBase.set(this, 'willBeRemoved', value);

  @override
  Stream<RealmObjectChanges<NullablesV1>> get changes =>
      RealmObjectBase.getChanges<NullablesV1>(this);

  @override
  NullablesV1 freeze() => RealmObjectBase.freezeObject<NullablesV1>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'differentiator': differentiator.toEJson(),
      'boolValue': boolValue.toEJson(),
      'intValue': intValue.toEJson(),
      'doubleValue': doubleValue.toEJson(),
      'decimalValue': decimalValue.toEJson(),
      'dateValue': dateValue.toEJson(),
      'stringValue': stringValue.toEJson(),
      'objectIdValue': objectIdValue.toEJson(),
      'uuidValue': uuidValue.toEJson(),
      'binaryValue': binaryValue.toEJson(),
      'willBeRemoved': willBeRemoved.toEJson(),
    };
  }

  static EJsonValue _toEJson(NullablesV1 value) => value.toEJson();
  static NullablesV1 _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'differentiator': EJsonValue differentiator,
        'boolValue': EJsonValue boolValue,
        'intValue': EJsonValue intValue,
        'doubleValue': EJsonValue doubleValue,
        'decimalValue': EJsonValue decimalValue,
        'dateValue': EJsonValue dateValue,
        'stringValue': EJsonValue stringValue,
        'objectIdValue': EJsonValue objectIdValue,
        'uuidValue': EJsonValue uuidValue,
        'binaryValue': EJsonValue binaryValue,
        'willBeRemoved': EJsonValue willBeRemoved,
      } =>
        NullablesV1(
          fromEJson(id),
          fromEJson(differentiator),
          fromEJson(boolValue),
          fromEJson(intValue),
          fromEJson(doubleValue),
          fromEJson(decimalValue),
          fromEJson(dateValue),
          fromEJson(stringValue),
          fromEJson(objectIdValue),
          fromEJson(uuidValue),
          fromEJson(binaryValue),
          fromEJson(willBeRemoved),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(NullablesV1._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.realmObject, NullablesV1, 'Nullables', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('differentiator', RealmPropertyType.objectid),
      SchemaProperty('boolValue', RealmPropertyType.bool),
      SchemaProperty('intValue', RealmPropertyType.int),
      SchemaProperty('doubleValue', RealmPropertyType.double),
      SchemaProperty('decimalValue', RealmPropertyType.decimal128),
      SchemaProperty('dateValue', RealmPropertyType.timestamp),
      SchemaProperty('stringValue', RealmPropertyType.string),
      SchemaProperty('objectIdValue', RealmPropertyType.objectid),
      SchemaProperty('uuidValue', RealmPropertyType.uuid),
      SchemaProperty('binaryValue', RealmPropertyType.binary),
      SchemaProperty('willBeRemoved', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
