// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class PersonIntName extends _PersonIntName with RealmEntity, RealmObject {
  PersonIntName(
    int name,
  ) {
    _nameProperty.setValue(this, name);
  }

  PersonIntName._();

  static const _nameProperty = ValueProperty<int>(
    'name',
    RealmPropertyType.int,
  );
  @override
  int get name => _nameProperty.getValue(this);
  @override
  set name(int value) => _nameProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<PersonIntName>> get changes =>
      RealmObject.getChanges(this);

  static const schema = SchemaObject<PersonIntName>(
    PersonIntName._,
    'Person',
    {
      'name': _nameProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class StudentV1 extends _StudentV1 with RealmEntity, RealmObject {
  StudentV1(
    String name, {
    int? yearOfBirth,
  }) {
    _nameProperty.setValue(this, name);
    _yearOfBirthProperty.setValue(this, yearOfBirth);
  }

  StudentV1._();

  static const _nameProperty = ValueProperty<String>(
    'name',
    RealmPropertyType.string,
    primaryKey: true,
  );
  @override
  String get name => _nameProperty.getValue(this);
  @override
  set name(String value) => throw RealmUnsupportedSetError();

  static const _yearOfBirthProperty = ValueProperty<int?>(
    'yearOfBirth',
    RealmPropertyType.int,
  );
  @override
  int? get yearOfBirth => _yearOfBirthProperty.getValue(this);
  @override
  set yearOfBirth(int? value) => _yearOfBirthProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<StudentV1>> get changes =>
      RealmObject.getChanges(this);

  static const schema = SchemaObject<StudentV1>(
    StudentV1._,
    'Student',
    {
      'name': _nameProperty,
      'yearOfBirth': _yearOfBirthProperty,
    },
    _nameProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class MyObjectWithTypo extends _MyObjectWithTypo with RealmEntity, RealmObject {
  MyObjectWithTypo(
    String nmae,
    int vlaue,
  ) {
    _nmaeProperty.setValue(this, nmae);
    _vlaueProperty.setValue(this, vlaue);
  }

  MyObjectWithTypo._();

  static const _nmaeProperty = ValueProperty<String>(
    'nmae',
    RealmPropertyType.string,
  );
  @override
  String get nmae => _nmaeProperty.getValue(this);
  @override
  set nmae(String value) => _nmaeProperty.setValue(this, value);

  static const _vlaueProperty = ValueProperty<int>(
    'vlaue',
    RealmPropertyType.int,
  );
  @override
  int get vlaue => _vlaueProperty.getValue(this);
  @override
  set vlaue(int value) => _vlaueProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<MyObjectWithTypo>> get changes =>
      RealmObject.getChanges(this);

  static const schema = SchemaObject<MyObjectWithTypo>(
    MyObjectWithTypo._,
    'MyObject',
    {
      'nmae': _nmaeProperty,
      'vlaue': _vlaueProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class MyObjectWithoutTypo extends _MyObjectWithoutTypo
    with RealmEntity, RealmObject {
  MyObjectWithoutTypo(
    String name,
    int value,
  ) {
    _nameProperty.setValue(this, name);
    _valueProperty.setValue(this, value);
  }

  MyObjectWithoutTypo._();

  static const _nameProperty = ValueProperty<String>(
    'name',
    RealmPropertyType.string,
  );
  @override
  String get name => _nameProperty.getValue(this);
  @override
  set name(String value) => _nameProperty.setValue(this, value);

  static const _valueProperty = ValueProperty<int>(
    'value',
    RealmPropertyType.int,
  );
  @override
  int get value => _valueProperty.getValue(this);
  @override
  set value(int value) => _valueProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<MyObjectWithoutTypo>> get changes =>
      RealmObject.getChanges(this);

  static const schema = SchemaObject<MyObjectWithoutTypo>(
    MyObjectWithoutTypo._,
    'MyObject',
    {
      'name': _nameProperty,
      'value': _valueProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class MyObjectWithoutValue extends _MyObjectWithoutValue
    with RealmEntity, RealmObject {
  MyObjectWithoutValue(
    String name,
  ) {
    _nameProperty.setValue(this, name);
  }

  MyObjectWithoutValue._();

  static const _nameProperty = ValueProperty<String>(
    'name',
    RealmPropertyType.string,
  );
  @override
  String get name => _nameProperty.getValue(this);
  @override
  set name(String value) => _nameProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<MyObjectWithoutValue>> get changes =>
      RealmObject.getChanges(this);

  static const schema = SchemaObject<MyObjectWithoutValue>(
    MyObjectWithoutValue._,
    'MyObject',
    {
      'name': _nameProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}
