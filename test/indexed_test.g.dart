// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'indexed_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class WithIndexes extends _WithIndexes
    with RealmEntity, RealmObjectBase, RealmObject {
  WithIndexes(
    int anInt,
    String string,
    bool aBool,
    DateTime timestamp,
    ObjectId objectId,
    Uuid uuid,
  ) {
    RealmObjectBase.set(this, 'anInt', anInt);
    RealmObjectBase.set(this, 'string', string);
    RealmObjectBase.set(this, 'aBool', aBool);
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
  String get string => RealmObjectBase.get<String>(this, 'string') as String;
  @override
  set string(String value) => RealmObjectBase.set(this, 'string', value);

  @override
  bool get aBool => RealmObjectBase.get<bool>(this, 'aBool') as bool;
  @override
  set aBool(bool value) => RealmObjectBase.set(this, 'aBool', value);

  @override
  DateTime get timestamp =>
      RealmObjectBase.get<DateTime>(this, 'timestamp') as DateTime;
  @override
  set timestamp(DateTime value) =>
      RealmObjectBase.set(this, 'timestamp', value);

  @override
  ObjectId get objectId =>
      RealmObjectBase.get<ObjectId>(this, 'objectId') as ObjectId;
  @override
  set objectId(ObjectId value) => RealmObjectBase.set(this, 'objectId', value);

  @override
  Uuid get uuid => RealmObjectBase.get<Uuid>(this, 'uuid') as Uuid;
  @override
  set uuid(Uuid value) => RealmObjectBase.set(this, 'uuid', value);

  @override
  Stream<RealmObjectChanges<WithIndexes>> get changes =>
      RealmObjectBase.getChanges<WithIndexes>(this);

  @override
  WithIndexes freeze() => RealmObjectBase.freezeObject<WithIndexes>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(WithIndexes._);
    return const SchemaObject(
        ObjectType.realmObject, WithIndexes, 'WithIndexes', [
      SchemaProperty('anInt', RealmPropertyType.int, indexed: true),
      SchemaProperty('string', RealmPropertyType.string, indexed: true),
      SchemaProperty('aBool', RealmPropertyType.bool, indexed: true),
      SchemaProperty('timestamp', RealmPropertyType.timestamp, indexed: true),
      SchemaProperty('objectId', RealmPropertyType.objectid, indexed: true),
      SchemaProperty('uuid', RealmPropertyType.uuid, indexed: true),
    ]);
  }
}

class NoIndexes extends _NoIndexes
    with RealmEntity, RealmObjectBase, RealmObject {
  NoIndexes(
    int anInt,
    String string,
    bool aBool,
    DateTime timestamp,
    ObjectId objectId,
    Uuid uuid,
  ) {
    RealmObjectBase.set(this, 'anInt', anInt);
    RealmObjectBase.set(this, 'string', string);
    RealmObjectBase.set(this, 'aBool', aBool);
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
  String get string => RealmObjectBase.get<String>(this, 'string') as String;
  @override
  set string(String value) => RealmObjectBase.set(this, 'string', value);

  @override
  bool get aBool => RealmObjectBase.get<bool>(this, 'aBool') as bool;
  @override
  set aBool(bool value) => RealmObjectBase.set(this, 'aBool', value);

  @override
  DateTime get timestamp =>
      RealmObjectBase.get<DateTime>(this, 'timestamp') as DateTime;
  @override
  set timestamp(DateTime value) =>
      RealmObjectBase.set(this, 'timestamp', value);

  @override
  ObjectId get objectId =>
      RealmObjectBase.get<ObjectId>(this, 'objectId') as ObjectId;
  @override
  set objectId(ObjectId value) => RealmObjectBase.set(this, 'objectId', value);

  @override
  Uuid get uuid => RealmObjectBase.get<Uuid>(this, 'uuid') as Uuid;
  @override
  set uuid(Uuid value) => RealmObjectBase.set(this, 'uuid', value);

  @override
  Stream<RealmObjectChanges<NoIndexes>> get changes =>
      RealmObjectBase.getChanges<NoIndexes>(this);

  @override
  NoIndexes freeze() => RealmObjectBase.freezeObject<NoIndexes>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(NoIndexes._);
    return const SchemaObject(ObjectType.realmObject, NoIndexes, 'NoIndexes', [
      SchemaProperty('anInt', RealmPropertyType.int),
      SchemaProperty('string', RealmPropertyType.string),
      SchemaProperty('aBool', RealmPropertyType.bool),
      SchemaProperty('timestamp', RealmPropertyType.timestamp),
      SchemaProperty('objectId', RealmPropertyType.objectid),
      SchemaProperty('uuid', RealmPropertyType.uuid),
    ]);
  }
}
