// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myapp.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Car extends _Car with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Car(
    String make, {
    String? model,
    int? kilometers = 500,
    Person? owner,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Car>({
        'kilometers': 500,
      });
    }
    RealmObjectBase.set(this, 'make', make);
    RealmObjectBase.set(this, 'model', model);
    RealmObjectBase.set(this, 'kilometers', kilometers);
    RealmObjectBase.set(this, 'owner', owner);
  }

  Car._();

  @override
  String get make => RealmObjectBase.get<String>(this, 'make') as String;
  @override
  set make(String value) => RealmObjectBase.set(this, 'make', value);

  @override
  String? get model => RealmObjectBase.get<String>(this, 'model') as String?;
  @override
  set model(String? value) => RealmObjectBase.set(this, 'model', value);

  @override
  int? get kilometers => RealmObjectBase.get<int>(this, 'kilometers') as int?;
  @override
  set kilometers(int? value) => RealmObjectBase.set(this, 'kilometers', value);

  @override
  Person? get owner => RealmObjectBase.get<Person>(this, 'owner') as Person?;
  @override
  set owner(covariant Person? value) =>
      RealmObjectBase.set(this, 'owner', value);

  @override
  Stream<RealmObjectChanges<Car>> get changes =>
      RealmObjectBase.getChanges<Car>(this);

  @override
  Car freeze() => RealmObjectBase.freezeObject<Car>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Car._);
    return SchemaObject(ObjectType.realmObject, Car, 'Car', [
      SchemaProperty('make', RealmPropertyType.string),
      SchemaProperty('model', RealmPropertyType.string, optional: true),
      SchemaProperty('kilometers', RealmPropertyType.int, optional: true),
      SchemaProperty('owner', RealmPropertyType.object,
          optional: true,
          linkTarget: 'Person',
          linkTargetSchema: () => Person.schema),
    ]);
  }
}

// ignore_for_file: type=lint
class Person extends _Person with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Person(
    String name, {
    int age = 1,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Person>({
        'age': 1,
      });
    }
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'age', age);
  }

  Person._();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  int get age => RealmObjectBase.get<int>(this, 'age') as int;
  @override
  set age(int value) => RealmObjectBase.set(this, 'age', value);

  @override
  Stream<RealmObjectChanges<Person>> get changes =>
      RealmObjectBase.getChanges<Person>(this);

  @override
  Person freeze() => RealmObjectBase.freezeObject<Person>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Person._);
    return SchemaObject(ObjectType.realmObject, Person, 'Person', [
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('age', RealmPropertyType.int),
    ]);
  }
}
