// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

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
  PersonIntName freeze() => RealmObjectBase.freezeObject<PersonIntName>(this);

  static EJsonValue _encodePersonIntName(PersonIntName value) {
    return <String, dynamic>{
      'name': toEJson(value.name),
    };
  }

  static PersonIntName _decodePersonIntName(EJsonValue ejson) {
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
    register(_encodePersonIntName, _decodePersonIntName);
    return const SchemaObject(ObjectType.realmObject, PersonIntName, 'Person', [
      SchemaProperty('name', RealmPropertyType.int),
    ]);
  }();
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
  StudentV1 freeze() => RealmObjectBase.freezeObject<StudentV1>(this);

  static EJsonValue _encodeStudentV1(StudentV1 value) {
    return <String, dynamic>{
      'name': toEJson(value.name),
      'yearOfBirth': toEJson(value.yearOfBirth),
    };
  }

  static StudentV1 _decodeStudentV1(EJsonValue ejson) {
    return switch (ejson) {
      {
        'name': EJsonValue name,
        'yearOfBirth': EJsonValue yearOfBirth,
      } =>
        StudentV1(
          fromEJson(name),
          yearOfBirth: fromEJson(yearOfBirth),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(StudentV1._);
    register(_encodeStudentV1, _decodeStudentV1);
    return const SchemaObject(ObjectType.realmObject, StudentV1, 'Student', [
      SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('yearOfBirth', RealmPropertyType.int, optional: true),
    ]);
  }();
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
  MyObjectWithTypo freeze() =>
      RealmObjectBase.freezeObject<MyObjectWithTypo>(this);

  static EJsonValue _encodeMyObjectWithTypo(MyObjectWithTypo value) {
    return <String, dynamic>{
      'nmae': toEJson(value.nmae),
      'vlaue': toEJson(value.vlaue),
    };
  }

  static MyObjectWithTypo _decodeMyObjectWithTypo(EJsonValue ejson) {
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
    register(_encodeMyObjectWithTypo, _decodeMyObjectWithTypo);
    return const SchemaObject(
        ObjectType.realmObject, MyObjectWithTypo, 'MyObject', [
      SchemaProperty('nmae', RealmPropertyType.string),
      SchemaProperty('vlaue', RealmPropertyType.int),
    ]);
  }();
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
  MyObjectWithoutTypo freeze() =>
      RealmObjectBase.freezeObject<MyObjectWithoutTypo>(this);

  static EJsonValue _encodeMyObjectWithoutTypo(MyObjectWithoutTypo value) {
    return <String, dynamic>{
      'name': toEJson(value.name),
      'value': toEJson(value.value),
    };
  }

  static MyObjectWithoutTypo _decodeMyObjectWithoutTypo(EJsonValue ejson) {
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
    register(_encodeMyObjectWithoutTypo, _decodeMyObjectWithoutTypo);
    return const SchemaObject(
        ObjectType.realmObject, MyObjectWithoutTypo, 'MyObject', [
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('value', RealmPropertyType.int),
    ]);
  }();
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
  MyObjectWithoutValue freeze() =>
      RealmObjectBase.freezeObject<MyObjectWithoutValue>(this);

  static EJsonValue _encodeMyObjectWithoutValue(MyObjectWithoutValue value) {
    return <String, dynamic>{
      'name': toEJson(value.name),
    };
  }

  static MyObjectWithoutValue _decodeMyObjectWithoutValue(EJsonValue ejson) {
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
    register(_encodeMyObjectWithoutValue, _decodeMyObjectWithoutValue);
    return const SchemaObject(
        ObjectType.realmObject, MyObjectWithoutValue, 'MyObject', [
      SchemaProperty('name', RealmPropertyType.string),
    ]);
  }();
}
