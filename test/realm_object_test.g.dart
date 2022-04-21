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
    return const SchemaObject(ObjectIdPrimaryKey, 'ObjectIdPrimaryKey', [
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
    return const SchemaObject(IntPrimaryKey, 'IntPrimaryKey', [
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
    return const SchemaObject(StringPrimaryKey, 'StringPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
    ]);
  }
}

class UuidPrimaryKey extends _UuidPrimaryKey with RealmEntity, RealmObject {
  UuidPrimaryKey(
    Uuid id,
  ) {
    RealmObject.set(this, 'id', id);
  }

  UuidPrimaryKey._();

  @override
  Uuid get id => RealmObject.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<UuidPrimaryKey>> get changes =>
      RealmObject.getChanges<UuidPrimaryKey>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(UuidPrimaryKey._);
    return const SchemaObject(UuidPrimaryKey, 'UuidPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.uuid, primaryKey: true),
    ]);
  }
}

class RemappedFromAnotherFile extends _RemappedFromAnotherFile
    with RealmEntity, RealmObject {
  RemappedFromAnotherFile({
    RemappedClass? linkToAnotherClass,
  }) {
    RealmObject.set(this, 'mapped property', linkToAnotherClass);
  }

  RemappedFromAnotherFile._();

  @override
  RemappedClass? get linkToAnotherClass =>
      RealmObject.get<RemappedClass>(this, 'mapped property') as RemappedClass?;
  @override
  set linkToAnotherClass(covariant RemappedClass? value) =>
      RealmObject.set(this, 'mapped property', value);

  @override
  Stream<RealmObjectChanges<RemappedFromAnotherFile>> get changes =>
      RealmObject.getChanges<RemappedFromAnotherFile>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(RemappedFromAnotherFile._);
    return const SchemaObject(
        RemappedFromAnotherFile, 'this_is_also_remapped', [
      SchemaProperty('mapped property', RealmPropertyType.object,
          mapTo: 'mapped property',
          optional: true,
          linkTarget: '__other class__'),
    ]);
  }
}
