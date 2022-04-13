// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_object_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class ObjectIdPrimaryKey extends _ObjectIdPrimaryKey
    with RealmEntity, RealmObject {
  ObjectIdPrimaryKey(
    ObjectId id,
  ) {
    RealmObject.set(this, 'id', id);
  }

  ObjectIdPrimaryKey._();

  @override
  ObjectId get id => RealmObject.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<ObjectIdPrimaryKey>> get changes =>
      RealmObject.getChanges<ObjectIdPrimaryKey>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(ObjectIdPrimaryKey._);
    return const SchemaObject(ObjectIdPrimaryKey, [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
    ]);
  }
}

class IntPrimaryKey extends _IntPrimaryKey with RealmEntity, RealmObject {
  IntPrimaryKey(
    int id,
  ) {
    RealmObject.set(this, 'id', id);
  }

  IntPrimaryKey._();

  @override
  int get id => RealmObject.get<int>(this, 'id') as int;
  @override
  set id(int value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<IntPrimaryKey>> get changes =>
      RealmObject.getChanges<IntPrimaryKey>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(IntPrimaryKey._);
    return const SchemaObject(IntPrimaryKey, [
      SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
    ]);
  }
}

class StringPrimaryKey extends _StringPrimaryKey with RealmEntity, RealmObject {
  StringPrimaryKey(
    String id,
  ) {
    RealmObject.set(this, 'id', id);
  }

  StringPrimaryKey._();

  @override
  String get id => RealmObject.get<String>(this, 'id') as String;
  @override
  set id(String value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<StringPrimaryKey>> get changes =>
      RealmObject.getChanges<StringPrimaryKey>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(StringPrimaryKey._);
    return const SchemaObject(StringPrimaryKey, [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
    ]);
  }
}
