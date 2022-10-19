// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_object_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class ObjectIdPrimaryKey extends _ObjectIdPrimaryKey
    with RealmEntity, RealmObjectBase, RealmObject {
  ObjectIdPrimaryKey(
    ObjectId id,
  ) {
    RealmObjectBase.set(this, 'id', id);
  }

  ObjectIdPrimaryKey._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  Stream<RealmObjectChanges<ObjectIdPrimaryKey>> get changes =>
      RealmObjectBase.getChanges<ObjectIdPrimaryKey>(this);

  @override
  ObjectIdPrimaryKey freeze() =>
      RealmObjectBase.freezeObject<ObjectIdPrimaryKey>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(ObjectIdPrimaryKey._);
    return const SchemaObject(
        ObjectType.topLevel, ObjectIdPrimaryKey, 'ObjectIdPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
    ]);
  }
}

class NullableObjectIdPrimaryKey extends _NullableObjectIdPrimaryKey
    with RealmEntity, RealmObjectBase, RealmObject {
  NullableObjectIdPrimaryKey(
    ObjectId? id,
  ) {
    RealmObjectBase.set(this, 'id', id);
  }

  NullableObjectIdPrimaryKey._();

  @override
  ObjectId? get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId?;
  @override
  set id(ObjectId? value) => RealmObjectBase.set(this, 'id', value);

  @override
  Stream<RealmObjectChanges<NullableObjectIdPrimaryKey>> get changes =>
      RealmObjectBase.getChanges<NullableObjectIdPrimaryKey>(this);

  @override
  NullableObjectIdPrimaryKey freeze() =>
      RealmObjectBase.freezeObject<NullableObjectIdPrimaryKey>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(NullableObjectIdPrimaryKey._);
    return const SchemaObject(ObjectType.topLevel, NullableObjectIdPrimaryKey,
        'NullableObjectIdPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.objectid,
          optional: true, primaryKey: true),
    ]);
  }
}

class IntPrimaryKey extends _IntPrimaryKey
    with RealmEntity, RealmObjectBase, RealmObject {
  IntPrimaryKey(
    int id,
  ) {
    RealmObjectBase.set(this, 'id', id);
  }

  IntPrimaryKey._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => RealmObjectBase.set(this, 'id', value);

  @override
  Stream<RealmObjectChanges<IntPrimaryKey>> get changes =>
      RealmObjectBase.getChanges<IntPrimaryKey>(this);

  @override
  IntPrimaryKey freeze() => RealmObjectBase.freezeObject<IntPrimaryKey>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(IntPrimaryKey._);
    return const SchemaObject(
        ObjectType.topLevel, IntPrimaryKey, 'IntPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
    ]);
  }
}

class NullableIntPrimaryKey extends _NullableIntPrimaryKey
    with RealmEntity, RealmObjectBase, RealmObject {
  NullableIntPrimaryKey(
    int? id,
  ) {
    RealmObjectBase.set(this, 'id', id);
  }

  NullableIntPrimaryKey._();

  @override
  int? get id => RealmObjectBase.get<int>(this, 'id') as int?;
  @override
  set id(int? value) => RealmObjectBase.set(this, 'id', value);

  @override
  Stream<RealmObjectChanges<NullableIntPrimaryKey>> get changes =>
      RealmObjectBase.getChanges<NullableIntPrimaryKey>(this);

  @override
  NullableIntPrimaryKey freeze() =>
      RealmObjectBase.freezeObject<NullableIntPrimaryKey>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(NullableIntPrimaryKey._);
    return const SchemaObject(
        ObjectType.topLevel, NullableIntPrimaryKey, 'NullableIntPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.int,
          optional: true, primaryKey: true),
    ]);
  }
}

class StringPrimaryKey extends _StringPrimaryKey
    with RealmEntity, RealmObjectBase, RealmObject {
  StringPrimaryKey(
    String id,
  ) {
    RealmObjectBase.set(this, 'id', id);
  }

  StringPrimaryKey._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  Stream<RealmObjectChanges<StringPrimaryKey>> get changes =>
      RealmObjectBase.getChanges<StringPrimaryKey>(this);

  @override
  StringPrimaryKey freeze() =>
      RealmObjectBase.freezeObject<StringPrimaryKey>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(StringPrimaryKey._);
    return const SchemaObject(
        ObjectType.topLevel, StringPrimaryKey, 'StringPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
    ]);
  }
}

class NullableStringPrimaryKey extends _NullableStringPrimaryKey
    with RealmEntity, RealmObjectBase, RealmObject {
  NullableStringPrimaryKey(
    String? id,
  ) {
    RealmObjectBase.set(this, 'id', id);
  }

  NullableStringPrimaryKey._();

  @override
  String? get id => RealmObjectBase.get<String>(this, 'id') as String?;
  @override
  set id(String? value) => RealmObjectBase.set(this, 'id', value);

  @override
  Stream<RealmObjectChanges<NullableStringPrimaryKey>> get changes =>
      RealmObjectBase.getChanges<NullableStringPrimaryKey>(this);

  @override
  NullableStringPrimaryKey freeze() =>
      RealmObjectBase.freezeObject<NullableStringPrimaryKey>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(NullableStringPrimaryKey._);
    return const SchemaObject(ObjectType.topLevel, NullableStringPrimaryKey,
        'NullableStringPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.string,
          optional: true, primaryKey: true),
    ]);
  }
}

class UuidPrimaryKey extends _UuidPrimaryKey
    with RealmEntity, RealmObjectBase, RealmObject {
  UuidPrimaryKey(
    Uuid id,
  ) {
    RealmObjectBase.set(this, 'id', id);
  }

  UuidPrimaryKey._();

  @override
  Uuid get id => RealmObjectBase.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => RealmObjectBase.set(this, 'id', value);

  @override
  Stream<RealmObjectChanges<UuidPrimaryKey>> get changes =>
      RealmObjectBase.getChanges<UuidPrimaryKey>(this);

  @override
  UuidPrimaryKey freeze() => RealmObjectBase.freezeObject<UuidPrimaryKey>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(UuidPrimaryKey._);
    return const SchemaObject(
        ObjectType.topLevel, UuidPrimaryKey, 'UuidPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.uuid, primaryKey: true),
    ]);
  }
}

class NullableUuidPrimaryKey extends _NullableUuidPrimaryKey
    with RealmEntity, RealmObjectBase, RealmObject {
  NullableUuidPrimaryKey(
    Uuid? id,
  ) {
    RealmObjectBase.set(this, 'id', id);
  }

  NullableUuidPrimaryKey._();

  @override
  Uuid? get id => RealmObjectBase.get<Uuid>(this, 'id') as Uuid?;
  @override
  set id(Uuid? value) => RealmObjectBase.set(this, 'id', value);

  @override
  Stream<RealmObjectChanges<NullableUuidPrimaryKey>> get changes =>
      RealmObjectBase.getChanges<NullableUuidPrimaryKey>(this);

  @override
  NullableUuidPrimaryKey freeze() =>
      RealmObjectBase.freezeObject<NullableUuidPrimaryKey>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(NullableUuidPrimaryKey._);
    return const SchemaObject(
        ObjectType.topLevel, NullableUuidPrimaryKey, 'NullableUuidPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.uuid,
          optional: true, primaryKey: true),
    ]);
  }
}

class RemappedFromAnotherFile extends _RemappedFromAnotherFile
    with RealmEntity, RealmObjectBase, RealmObject {
  RemappedFromAnotherFile({
    RemappedClass? linkToAnotherClass,
  }) {
    RealmObjectBase.set(this, 'property with spaces', linkToAnotherClass);
  }

  RemappedFromAnotherFile._();

  @override
  RemappedClass? get linkToAnotherClass =>
      RealmObjectBase.get<RemappedClass>(this, 'property with spaces')
          as RemappedClass?;
  @override
  set linkToAnotherClass(covariant RemappedClass? value) =>
      RealmObjectBase.set(this, 'property with spaces', value);

  @override
  Stream<RealmObjectChanges<RemappedFromAnotherFile>> get changes =>
      RealmObjectBase.getChanges<RemappedFromAnotherFile>(this);

  @override
  RemappedFromAnotherFile freeze() =>
      RealmObjectBase.freezeObject<RemappedFromAnotherFile>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(RemappedFromAnotherFile._);
    return const SchemaObject(
        ObjectType.topLevel, RemappedFromAnotherFile, 'class with spaces', [
      SchemaProperty('property with spaces', RealmPropertyType.object,
          mapTo: 'property with spaces',
          optional: true,
          linkTarget: 'myRemappedClass'),
    ]);
  }
}

class BoolValue extends _BoolValue
    with RealmEntity, RealmObjectBase, RealmObject {
  BoolValue(
    int key,
    bool value,
  ) {
    RealmObjectBase.set(this, 'key', key);
    RealmObjectBase.set(this, 'value', value);
  }

  BoolValue._();

  @override
  int get key => RealmObjectBase.get<int>(this, 'key') as int;
  @override
  set key(int value) => RealmObjectBase.set(this, 'key', value);

  @override
  bool get value => RealmObjectBase.get<bool>(this, 'value') as bool;
  @override
  set value(bool value) => RealmObjectBase.set(this, 'value', value);

  @override
  Stream<RealmObjectChanges<BoolValue>> get changes =>
      RealmObjectBase.getChanges<BoolValue>(this);

  @override
  BoolValue freeze() => RealmObjectBase.freezeObject<BoolValue>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(BoolValue._);
    return const SchemaObject(ObjectType.topLevel, BoolValue, 'BoolValue', [
      SchemaProperty('key', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('value', RealmPropertyType.bool),
    ]);
  }
}
