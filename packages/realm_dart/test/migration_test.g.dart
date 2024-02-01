// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class PersonIntName extends _PersonIntName with RealmEntity, RealmObjectBase, RealmObject {
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
  Stream<RealmObjectChanges<PersonIntName>> get changes => RealmObjectBase.getChanges<PersonIntName>(this);

  @override
  PersonIntName freeze() => RealmObjectBase.freezeObject<PersonIntName>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(PersonIntName._);
    return const SchemaObject(ObjectType.realmObject, PersonIntName, 'Person', [
      SchemaProperty('name', RealmPropertyType.int),
    ]);
  }
}

class StudentV1 extends _StudentV1 with RealmEntity, RealmObjectBase, RealmObject {
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
  set yearOfBirth(int? value) => RealmObjectBase.set(this, 'yearOfBirth', value);

  @override
  Stream<RealmObjectChanges<StudentV1>> get changes => RealmObjectBase.getChanges<StudentV1>(this);

  @override
  StudentV1 freeze() => RealmObjectBase.freezeObject<StudentV1>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(StudentV1._);
    return const SchemaObject(ObjectType.realmObject, StudentV1, 'Student', [
      SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('yearOfBirth', RealmPropertyType.int, optional: true),
    ]);
  }
}

class MyObjectWithTypo extends _MyObjectWithTypo with RealmEntity, RealmObjectBase, RealmObject {
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
  Stream<RealmObjectChanges<MyObjectWithTypo>> get changes => RealmObjectBase.getChanges<MyObjectWithTypo>(this);

  @override
  MyObjectWithTypo freeze() => RealmObjectBase.freezeObject<MyObjectWithTypo>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(MyObjectWithTypo._);
    return const SchemaObject(ObjectType.realmObject, MyObjectWithTypo, 'MyObject', [
      SchemaProperty('nmae', RealmPropertyType.string),
      SchemaProperty('vlaue', RealmPropertyType.int),
    ]);
  }
}

class MyObjectWithoutTypo extends _MyObjectWithoutTypo with RealmEntity, RealmObjectBase, RealmObject {
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
  Stream<RealmObjectChanges<MyObjectWithoutTypo>> get changes => RealmObjectBase.getChanges<MyObjectWithoutTypo>(this);

  @override
  MyObjectWithoutTypo freeze() => RealmObjectBase.freezeObject<MyObjectWithoutTypo>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(MyObjectWithoutTypo._);
    return const SchemaObject(ObjectType.realmObject, MyObjectWithoutTypo, 'MyObject', [
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('value', RealmPropertyType.int),
    ]);
  }
}

class MyObjectWithoutValue extends _MyObjectWithoutValue with RealmEntity, RealmObjectBase, RealmObject {
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
  Stream<RealmObjectChanges<MyObjectWithoutValue>> get changes => RealmObjectBase.getChanges<MyObjectWithoutValue>(this);

  @override
  MyObjectWithoutValue freeze() => RealmObjectBase.freezeObject<MyObjectWithoutValue>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(MyObjectWithoutValue._);
    return const SchemaObject(ObjectType.realmObject, MyObjectWithoutValue, 'MyObject', [
      SchemaProperty('name', RealmPropertyType.string),
    ]);
  }
}
