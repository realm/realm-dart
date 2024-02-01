// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'indexed_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class WithIndexes extends _WithIndexes with RealmEntity, RealmObjectBase, RealmObject {
  WithIndexes(
    int anInt,
    bool aBool,
    String string,
    DateTime timestamp,
    ObjectId objectId,
    Uuid uuid,
  ) {
    RealmObjectBase.set(this, 'anInt', anInt);
    RealmObjectBase.set(this, 'aBool', aBool);
    RealmObjectBase.set(this, 'string', string);
    RealmObjectBase.set(this, 'timestamp', timestamp);
    RealmObjectBase.set(this, 'objectId', objectId);
    RealmObjectBase.set(this, 'uuid', uuid);
  }

  WithIndexes._();

  @override
  int get anInt => RealmObjectBase.get<int>(this, 'anInt') as int;
  @override
  set anInt(int value) => RealmObjectBase.set(this, 'anInt', value);

  @override
  bool get aBool => RealmObjectBase.get<bool>(this, 'aBool') as bool;
  @override
  set aBool(bool value) => RealmObjectBase.set(this, 'aBool', value);

  @override
  String get string => RealmObjectBase.get<String>(this, 'string') as String;
  @override
  set string(String value) => RealmObjectBase.set(this, 'string', value);

  @override
  DateTime get timestamp => RealmObjectBase.get<DateTime>(this, 'timestamp') as DateTime;
  @override
  set timestamp(DateTime value) => RealmObjectBase.set(this, 'timestamp', value);

  @override
  ObjectId get objectId => RealmObjectBase.get<ObjectId>(this, 'objectId') as ObjectId;
  @override
  set objectId(ObjectId value) => RealmObjectBase.set(this, 'objectId', value);

  @override
  Uuid get uuid => RealmObjectBase.get<Uuid>(this, 'uuid') as Uuid;
  @override
  set uuid(Uuid value) => RealmObjectBase.set(this, 'uuid', value);

  @override
  Stream<RealmObjectChanges<WithIndexes>> get changes => RealmObjectBase.getChanges<WithIndexes>(this);

  @override
  WithIndexes freeze() => RealmObjectBase.freezeObject<WithIndexes>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(WithIndexes._);
    return const SchemaObject(ObjectType.realmObject, WithIndexes, 'WithIndexes', [
      SchemaProperty('anInt', RealmPropertyType.int, indexType: RealmIndexType.regular),
      SchemaProperty('aBool', RealmPropertyType.bool, indexType: RealmIndexType.regular),
      SchemaProperty('string', RealmPropertyType.string, indexType: RealmIndexType.regular),
      SchemaProperty('timestamp', RealmPropertyType.timestamp, indexType: RealmIndexType.regular),
      SchemaProperty('objectId', RealmPropertyType.objectid, indexType: RealmIndexType.regular),
      SchemaProperty('uuid', RealmPropertyType.uuid, indexType: RealmIndexType.regular),
    ]);
  }
}

class NoIndexes extends _NoIndexes with RealmEntity, RealmObjectBase, RealmObject {
  NoIndexes(
    int anInt,
    bool aBool,
    String string,
    DateTime timestamp,
    ObjectId objectId,
    Uuid uuid,
  ) {
    RealmObjectBase.set(this, 'anInt', anInt);
    RealmObjectBase.set(this, 'aBool', aBool);
    RealmObjectBase.set(this, 'string', string);
    RealmObjectBase.set(this, 'timestamp', timestamp);
    RealmObjectBase.set(this, 'objectId', objectId);
    RealmObjectBase.set(this, 'uuid', uuid);
  }

  NoIndexes._();

  @override
  int get anInt => RealmObjectBase.get<int>(this, 'anInt') as int;
  @override
  set anInt(int value) => RealmObjectBase.set(this, 'anInt', value);

  @override
  bool get aBool => RealmObjectBase.get<bool>(this, 'aBool') as bool;
  @override
  set aBool(bool value) => RealmObjectBase.set(this, 'aBool', value);

  @override
  String get string => RealmObjectBase.get<String>(this, 'string') as String;
  @override
  set string(String value) => RealmObjectBase.set(this, 'string', value);

  @override
  DateTime get timestamp => RealmObjectBase.get<DateTime>(this, 'timestamp') as DateTime;
  @override
  set timestamp(DateTime value) => RealmObjectBase.set(this, 'timestamp', value);

  @override
  ObjectId get objectId => RealmObjectBase.get<ObjectId>(this, 'objectId') as ObjectId;
  @override
  set objectId(ObjectId value) => RealmObjectBase.set(this, 'objectId', value);

  @override
  Uuid get uuid => RealmObjectBase.get<Uuid>(this, 'uuid') as Uuid;
  @override
  set uuid(Uuid value) => RealmObjectBase.set(this, 'uuid', value);

  @override
  Stream<RealmObjectChanges<NoIndexes>> get changes => RealmObjectBase.getChanges<NoIndexes>(this);

  @override
  NoIndexes freeze() => RealmObjectBase.freezeObject<NoIndexes>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(NoIndexes._);
    return const SchemaObject(ObjectType.realmObject, NoIndexes, 'NoIndexes', [
      SchemaProperty('anInt', RealmPropertyType.int),
      SchemaProperty('aBool', RealmPropertyType.bool),
      SchemaProperty('string', RealmPropertyType.string),
      SchemaProperty('timestamp', RealmPropertyType.timestamp),
      SchemaProperty('objectId', RealmPropertyType.objectid),
      SchemaProperty('uuid', RealmPropertyType.uuid),
    ]);
  }
}

class ObjectWithFTSIndex extends _ObjectWithFTSIndex with RealmEntity, RealmObjectBase, RealmObject {
  ObjectWithFTSIndex(
    String title,
    String summary, {
    String? nullableSummary,
  }) {
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'summary', summary);
    RealmObjectBase.set(this, 'nullableSummary', nullableSummary);
  }

  ObjectWithFTSIndex._();

  @override
  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  @override
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  @override
  String get summary => RealmObjectBase.get<String>(this, 'summary') as String;
  @override
  set summary(String value) => RealmObjectBase.set(this, 'summary', value);

  @override
  String? get nullableSummary => RealmObjectBase.get<String>(this, 'nullableSummary') as String?;
  @override
  set nullableSummary(String? value) => RealmObjectBase.set(this, 'nullableSummary', value);

  @override
  Stream<RealmObjectChanges<ObjectWithFTSIndex>> get changes => RealmObjectBase.getChanges<ObjectWithFTSIndex>(this);

  @override
  ObjectWithFTSIndex freeze() => RealmObjectBase.freezeObject<ObjectWithFTSIndex>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(ObjectWithFTSIndex._);
    return const SchemaObject(ObjectType.realmObject, ObjectWithFTSIndex, 'ObjectWithFTSIndex', [
      SchemaProperty('title', RealmPropertyType.string),
      SchemaProperty('summary', RealmPropertyType.string, indexType: RealmIndexType.fullText),
      SchemaProperty('nullableSummary', RealmPropertyType.string, optional: true, indexType: RealmIndexType.fullText),
    ]);
  }
}
