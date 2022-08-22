// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class PersonIntName extends _PersonIntName with RealmEntity, RealmObject {
  PersonIntName(
    int name,
  ) {
    RealmObject.set(this, 'name', name);
  }

  PersonIntName._();

  @override
  int get name => RealmObject.get<int>(this, 'name') as int;
  @override
  set name(int value) => RealmObject.set(this, 'name', value);

  @override
  Stream<RealmObjectChanges<PersonIntName>> get changes =>
      RealmObject.getChanges<PersonIntName>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(PersonIntName._);
    return const SchemaObject(PersonIntName, 'Person', [
      SchemaProperty('name', RealmPropertyType.int),
    ]);
  }
}

class StudentV1 extends _StudentV1 with RealmEntity, RealmObject {
  StudentV1(
    String name, {
    int? yearOfBirth,
  }) {
    RealmObject.set(this, 'name', name);
    RealmObject.set(this, 'yearOfBirth', yearOfBirth);
  }

  StudentV1._();

  @override
  String get name => RealmObject.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObject.set(this, 'name', value);

  @override
  int? get yearOfBirth => RealmObject.get<int>(this, 'yearOfBirth') as int?;
  @override
  set yearOfBirth(int? value) => RealmObject.set(this, 'yearOfBirth', value);

  @override
  Stream<RealmObjectChanges<StudentV1>> get changes =>
      RealmObject.getChanges<StudentV1>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(StudentV1._);
    return const SchemaObject(StudentV1, 'Student', [
      SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('yearOfBirth', RealmPropertyType.int, optional: true),
    ]);
  }
}

class MyObjectWithTypo extends _MyObjectWithTypo with RealmEntity, RealmObject {
  MyObjectWithTypo(
    String nmae,
    int vlaue,
  ) {
    RealmObject.set(this, 'nmae', nmae);
    RealmObject.set(this, 'vlaue', vlaue);
  }

  MyObjectWithTypo._();

  @override
  String get nmae => RealmObject.get<String>(this, 'nmae') as String;
  @override
  set nmae(String value) => RealmObject.set(this, 'nmae', value);

  @override
  int get vlaue => RealmObject.get<int>(this, 'vlaue') as int;
  @override
  set vlaue(int value) => RealmObject.set(this, 'vlaue', value);

  @override
  Stream<RealmObjectChanges<MyObjectWithTypo>> get changes =>
      RealmObject.getChanges<MyObjectWithTypo>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(MyObjectWithTypo._);
    return const SchemaObject(MyObjectWithTypo, 'MyObject', [
      SchemaProperty('nmae', RealmPropertyType.string),
      SchemaProperty('vlaue', RealmPropertyType.int),
    ]);
  }
}

class MyObjectWithoutTypo extends _MyObjectWithoutTypo
    with RealmEntity, RealmObject {
  MyObjectWithoutTypo(
    String name,
    int value,
  ) {
    RealmObject.set(this, 'name', name);
    RealmObject.set(this, 'value', value);
  }

  MyObjectWithoutTypo._();

  @override
  String get name => RealmObject.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObject.set(this, 'name', value);

  @override
  int get value => RealmObject.get<int>(this, 'value') as int;
  @override
  set value(int value) => RealmObject.set(this, 'value', value);

  @override
  Stream<RealmObjectChanges<MyObjectWithoutTypo>> get changes =>
      RealmObject.getChanges<MyObjectWithoutTypo>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(MyObjectWithoutTypo._);
    return const SchemaObject(MyObjectWithoutTypo, 'MyObject', [
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('value', RealmPropertyType.int),
    ]);
  }
}
