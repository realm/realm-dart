// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_object_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
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

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
    };
  }

  static EJsonValue _toEJson(ObjectIdPrimaryKey value) => value.toEJson();
  static ObjectIdPrimaryKey _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        ObjectIdPrimaryKey(
          fromEJson(id),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ObjectIdPrimaryKey._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ObjectIdPrimaryKey, 'ObjectIdPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
    ]);
  }();
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

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
    };
  }

  static EJsonValue _toEJson(NullableObjectIdPrimaryKey value) =>
      value.toEJson();
  static NullableObjectIdPrimaryKey _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        NullableObjectIdPrimaryKey(
          fromEJson(id),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(NullableObjectIdPrimaryKey._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject,
        NullableObjectIdPrimaryKey, 'NullableObjectIdPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.objectid,
          optional: true, primaryKey: true),
    ]);
  }();
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

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
    };
  }

  static EJsonValue _toEJson(IntPrimaryKey value) => value.toEJson();
  static IntPrimaryKey _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        IntPrimaryKey(
          fromEJson(id),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(IntPrimaryKey._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, IntPrimaryKey, 'IntPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
    ]);
  }();
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

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
    };
  }

  static EJsonValue _toEJson(NullableIntPrimaryKey value) => value.toEJson();
  static NullableIntPrimaryKey _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        NullableIntPrimaryKey(
          fromEJson(id),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(NullableIntPrimaryKey._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, NullableIntPrimaryKey,
        'NullableIntPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.int,
          optional: true, primaryKey: true),
    ]);
  }();
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

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
    };
  }

  static EJsonValue _toEJson(StringPrimaryKey value) => value.toEJson();
  static StringPrimaryKey _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        StringPrimaryKey(
          fromEJson(id),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(StringPrimaryKey._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, StringPrimaryKey, 'StringPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
    ]);
  }();
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

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
    };
  }

  static EJsonValue _toEJson(NullableStringPrimaryKey value) => value.toEJson();
  static NullableStringPrimaryKey _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        NullableStringPrimaryKey(
          fromEJson(id),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(NullableStringPrimaryKey._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, NullableStringPrimaryKey,
        'NullableStringPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.string,
          optional: true, primaryKey: true),
    ]);
  }();
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

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
    };
  }

  static EJsonValue _toEJson(UuidPrimaryKey value) => value.toEJson();
  static UuidPrimaryKey _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        UuidPrimaryKey(
          fromEJson(id),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(UuidPrimaryKey._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, UuidPrimaryKey, 'UuidPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.uuid, primaryKey: true),
    ]);
  }();
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

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
    };
  }

  static EJsonValue _toEJson(NullableUuidPrimaryKey value) => value.toEJson();
  static NullableUuidPrimaryKey _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        NullableUuidPrimaryKey(
          fromEJson(id),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(NullableUuidPrimaryKey._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, NullableUuidPrimaryKey,
        'NullableUuidPrimaryKey', [
      SchemaProperty('id', RealmPropertyType.uuid,
          optional: true, primaryKey: true),
    ]);
  }();
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

  EJsonValue toEJson() {
    return <String, dynamic>{
      'property with spaces': linkToAnotherClass.toEJson(),
    };
  }

  static EJsonValue _toEJson(RemappedFromAnotherFile value) => value.toEJson();
  static RemappedFromAnotherFile _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'property with spaces': EJsonValue linkToAnotherClass,
      } =>
        RemappedFromAnotherFile(
          linkToAnotherClass: fromEJson(linkToAnotherClass),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(RemappedFromAnotherFile._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, RemappedFromAnotherFile, 'class with spaces', [
      SchemaProperty('linkToAnotherClass', RealmPropertyType.object,
          mapTo: 'property with spaces',
          optional: true,
          linkTarget: 'myRemappedClass'),
    ]);
  }();
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

  EJsonValue toEJson() {
    return <String, dynamic>{
      'key': key.toEJson(),
      'value': value.toEJson(),
    };
  }

  static EJsonValue _toEJson(BoolValue value) => value.toEJson();
  static BoolValue _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'key': EJsonValue key,
        'value': EJsonValue value,
      } =>
        BoolValue(
          fromEJson(key),
          fromEJson(value),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(BoolValue._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, BoolValue, 'BoolValue', [
      SchemaProperty('key', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('value', RealmPropertyType.bool),
    ]);
  }();
}
