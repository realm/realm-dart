// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Car extends _Car with RealmObject {
  static var _defaultsSet = false;

  Car(
    String make,
  ) {
    RealmObject.set(this, 'make', make);
    _defaultsSet = _defaultsSet || RealmObject.setDefaults<Car>({});
  }

  Car._();

  @override
  String get make => RealmObject.get<String>(this, 'make') as String;

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Car._);
    return const SchemaObject(Car, [
      SchemaProperty('make', RealmPropertyType.string, primaryKey: true),
    ]);
  }
}

class Person extends _Person with RealmObject {
  static var _defaultsSet = false;

  Person(
    String name,
  ) {
    this.name = name;
    _defaultsSet = _defaultsSet || RealmObject.setDefaults<Person>({});
  }

  Person._();

  @override
  String get name => RealmObject.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObject.set(this, 'name', value);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Person._);
    return const SchemaObject(Person, [
      SchemaProperty('name', RealmPropertyType.string),
    ]);
  }
}

class Dog extends _Dog with RealmObject {
  static var _defaultsSet = false;

  Dog(
    String name, {
    int? age,
    Person? owner,
  }) {
    RealmObject.set(this, 'name', name);
    this.age = age;
    this.owner = owner;
    _defaultsSet = _defaultsSet || RealmObject.setDefaults<Dog>({});
  }

  Dog._();

  @override
  String get name => RealmObject.get<String>(this, 'name') as String;

  @override
  int? get age => RealmObject.get<int>(this, 'age') as int?;
  @override
  set age(int? value) => RealmObject.set(this, 'age', value);

  @override
  Person? get owner => RealmObject.get<Person>(this, 'owner') as Person?;
  @override
  set owner(covariant Person? value) => RealmObject.set(this, 'owner', value);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Dog._);
    return const SchemaObject(Dog, [
      SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('age', RealmPropertyType.int, optional: true),
      SchemaProperty('owner', RealmPropertyType.object,
          optional: true, linkTarget: 'Person'),
    ]);
  }
}

class Team extends _Team with RealmObject {
  static var _defaultsSet = false;

  Team(
    String name,
  ) {
    this.name = name;
    _defaultsSet = _defaultsSet || RealmObject.setDefaults<Team>({});
  }

  Team._();

  @override
  String get name => RealmObject.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObject.set(this, 'name', value);

  @override
  List<Person> get players =>
      RealmObject.get<Person>(this, 'players') as List<Person>;

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Team._);
    return const SchemaObject(Team, [
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('players', RealmPropertyType.object,
          linkTarget: 'Person', collectionType: RealmCollectionType.list),
    ]);
  }
}
