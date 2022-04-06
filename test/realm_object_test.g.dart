// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_object_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

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

class NullableIntPrimaryKey extends _NullableIntPrimaryKey
    with RealmEntity, RealmObject {
  NullableIntPrimaryKey(
    int? id,
  ) {
    RealmObject.set(this, 'id', id);
  }

  NullableIntPrimaryKey._();

  @override
  int? get id => RealmObject.get<int>(this, 'id') as int?;
  @override
  set id(int? value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<NullableIntPrimaryKey>> get changes =>
      RealmObject.getChanges<NullableIntPrimaryKey>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(NullableIntPrimaryKey._);
    return const SchemaObject(NullableIntPrimaryKey, [
      SchemaProperty('id', RealmPropertyType.int,
          optional: true, primaryKey: true),
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

class NullableStringPrimaryKey extends _NullableStringPrimaryKey
    with RealmEntity, RealmObject {
  NullableStringPrimaryKey(
    String? id,
  ) {
    RealmObject.set(this, 'id', id);
  }

  NullableStringPrimaryKey._();

  @override
  String? get id => RealmObject.get<String>(this, 'id') as String?;
  @override
  set id(String? value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<NullableStringPrimaryKey>> get changes =>
      RealmObject.getChanges<NullableStringPrimaryKey>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(NullableStringPrimaryKey._);
    return const SchemaObject(NullableStringPrimaryKey, [
      SchemaProperty('id', RealmPropertyType.string,
          optional: true, primaryKey: true),
    ]);
  }
}

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

class NullableObjectIdPrimaryKey extends _NullableObjectIdPrimaryKey
    with RealmEntity, RealmObject {
  NullableObjectIdPrimaryKey(
    ObjectId? id,
  ) {
    RealmObject.set(this, 'id', id);
  }

  NullableObjectIdPrimaryKey._();

  @override
  ObjectId? get id => RealmObject.get<ObjectId>(this, 'id') as ObjectId?;
  @override
  set id(ObjectId? value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<NullableObjectIdPrimaryKey>> get changes =>
      RealmObject.getChanges<NullableObjectIdPrimaryKey>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(NullableObjectIdPrimaryKey._);
    return const SchemaObject(NullableObjectIdPrimaryKey, [
      SchemaProperty('id', RealmPropertyType.objectid,
          optional: true, primaryKey: true),
    ]);
  }
}
