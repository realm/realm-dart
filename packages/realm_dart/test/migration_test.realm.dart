// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class PersonIntName extends _PersonIntName
    with RealmEntity, RealmObjectBase, RealmObject {
  PersonIntName(
    int name,
  ) {
    RealmObjectBase.set(this, 'name', name);
  }

  PersonIntName._();

  @override
  int get name => RealmObjectBase.get<int>(this, 'name') as int;
  @override
  set name(int value) => RealmObjectBase.set(this, 'name', value);

  @override
  Stream<RealmObjectChanges<PersonIntName>> get changes =>
      RealmObjectBase.getChanges<PersonIntName>(this);

  @override
  Stream<RealmObjectChanges<PersonIntName>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<PersonIntName>(this, keyPaths);

  @override
  PersonIntName freeze() => RealmObjectBase.freezeObject<PersonIntName>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'name': name.toEJson(),
    };
  }

  static EJsonValue _toEJson(PersonIntName value) => value.toEJson();
  static PersonIntName _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'name': EJsonValue name,
      } =>
        PersonIntName(
          fromEJson(name),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(PersonIntName._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, PersonIntName, 'Person', [
      SchemaProperty('name', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class StudentV1 extends _StudentV1
    with RealmEntity, RealmObjectBase, RealmObject {
  StudentV1(
    String name, {
    int? yearOfBirth,
  }) {
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'yearOfBirth', yearOfBirth);
  }

  StudentV1._();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  int? get yearOfBirth => RealmObjectBase.get<int>(this, 'yearOfBirth') as int?;
  @override
  set yearOfBirth(int? value) =>
      RealmObjectBase.set(this, 'yearOfBirth', value);

  @override
  Stream<RealmObjectChanges<StudentV1>> get changes =>
      RealmObjectBase.getChanges<StudentV1>(this);

  @override
  Stream<RealmObjectChanges<StudentV1>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<StudentV1>(this, keyPaths);

  @override
  StudentV1 freeze() => RealmObjectBase.freezeObject<StudentV1>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'name': name.toEJson(),
      'yearOfBirth': yearOfBirth.toEJson(),
    };
  }

  static EJsonValue _toEJson(StudentV1 value) => value.toEJson();
  static StudentV1 _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'name': EJsonValue name,
      } =>
        StudentV1(
          fromEJson(name),
          yearOfBirth: fromEJson(ejson['yearOfBirth']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(StudentV1._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, StudentV1, 'Student', [
      SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('yearOfBirth', RealmPropertyType.int, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class MyObjectWithTypo extends _MyObjectWithTypo
    with RealmEntity, RealmObjectBase, RealmObject {
  MyObjectWithTypo(
    String nmae,
    int vlaue,
  ) {
    RealmObjectBase.set(this, 'nmae', nmae);
    RealmObjectBase.set(this, 'vlaue', vlaue);
  }

  MyObjectWithTypo._();

  @override
  String get nmae => RealmObjectBase.get<String>(this, 'nmae') as String;
  @override
  set nmae(String value) => RealmObjectBase.set(this, 'nmae', value);

  @override
  int get vlaue => RealmObjectBase.get<int>(this, 'vlaue') as int;
  @override
  set vlaue(int value) => RealmObjectBase.set(this, 'vlaue', value);

  @override
  Stream<RealmObjectChanges<MyObjectWithTypo>> get changes =>
      RealmObjectBase.getChanges<MyObjectWithTypo>(this);

  @override
  Stream<RealmObjectChanges<MyObjectWithTypo>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<MyObjectWithTypo>(this, keyPaths);

  @override
  MyObjectWithTypo freeze() =>
      RealmObjectBase.freezeObject<MyObjectWithTypo>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'nmae': nmae.toEJson(),
      'vlaue': vlaue.toEJson(),
    };
  }

  static EJsonValue _toEJson(MyObjectWithTypo value) => value.toEJson();
  static MyObjectWithTypo _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'nmae': EJsonValue nmae,
        'vlaue': EJsonValue vlaue,
      } =>
        MyObjectWithTypo(
          fromEJson(nmae),
          fromEJson(vlaue),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(MyObjectWithTypo._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, MyObjectWithTypo, 'MyObject', [
      SchemaProperty('nmae', RealmPropertyType.string),
      SchemaProperty('vlaue', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class MyObjectWithoutTypo extends _MyObjectWithoutTypo
    with RealmEntity, RealmObjectBase, RealmObject {
  MyObjectWithoutTypo(
    String name,
    int value,
  ) {
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'value', value);
  }

  MyObjectWithoutTypo._();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  int get value => RealmObjectBase.get<int>(this, 'value') as int;
  @override
  set value(int value) => RealmObjectBase.set(this, 'value', value);

  @override
  Stream<RealmObjectChanges<MyObjectWithoutTypo>> get changes =>
      RealmObjectBase.getChanges<MyObjectWithoutTypo>(this);

  @override
  Stream<RealmObjectChanges<MyObjectWithoutTypo>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<MyObjectWithoutTypo>(this, keyPaths);

  @override
  MyObjectWithoutTypo freeze() =>
      RealmObjectBase.freezeObject<MyObjectWithoutTypo>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'name': name.toEJson(),
      'value': value.toEJson(),
    };
  }

  static EJsonValue _toEJson(MyObjectWithoutTypo value) => value.toEJson();
  static MyObjectWithoutTypo _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'name': EJsonValue name,
        'value': EJsonValue value,
      } =>
        MyObjectWithoutTypo(
          fromEJson(name),
          fromEJson(value),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(MyObjectWithoutTypo._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, MyObjectWithoutTypo, 'MyObject', [
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('value', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class MyObjectWithoutValue extends _MyObjectWithoutValue
    with RealmEntity, RealmObjectBase, RealmObject {
  MyObjectWithoutValue(
    String name,
  ) {
    RealmObjectBase.set(this, 'name', name);
  }

  MyObjectWithoutValue._();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  Stream<RealmObjectChanges<MyObjectWithoutValue>> get changes =>
      RealmObjectBase.getChanges<MyObjectWithoutValue>(this);

  @override
  Stream<RealmObjectChanges<MyObjectWithoutValue>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<MyObjectWithoutValue>(this, keyPaths);

  @override
  MyObjectWithoutValue freeze() =>
      RealmObjectBase.freezeObject<MyObjectWithoutValue>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'name': name.toEJson(),
    };
  }

  static EJsonValue _toEJson(MyObjectWithoutValue value) => value.toEJson();
  static MyObjectWithoutValue _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'name': EJsonValue name,
      } =>
        MyObjectWithoutValue(
          fromEJson(name),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(MyObjectWithoutValue._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, MyObjectWithoutValue, 'MyObject', [
      SchemaProperty('name', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
