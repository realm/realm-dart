// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Car extends _Car with RealmObject {
  Car({
    String? make,
  }) {
    _make = make ?? "Tesla";
  }

  @override
  String get make => RealmObject.get<String>(this, 'make') as String;
  set _make(String value) => RealmObject.set(this, 'make', value);

  static const schema = SchemaObject(Car, [
    SchemaProperty('make', RealmPropertyType.string, primaryKey: true),
  ]);
}

class Person extends _Person with RealmObject {
  Person({
    required String name,
  }) {
    this.name = name;
  }

  @override
  String get name => RealmObject.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObject.set(this, 'name', value);

  static const schema = SchemaObject(Person, [
    SchemaProperty('name', RealmPropertyType.string),
  ]);
}

class Dog extends _Dog with RealmObject {
  Dog({
    required String name,
    int? age,
    Person? owner,
  }) {
    _name = name;
    this.age = age;
    this.owner = owner;
  }

  @override
  String get name => RealmObject.get<String>(this, 'name') as String;
  set _name(String value) => RealmObject.set(this, 'name', value);

  @override
  int? get age => RealmObject.get<int>(this, 'age') as int?;
  @override
  set age(int? value) => RealmObject.set(this, 'age', value);

  @override
  Person? get owner => RealmObject.get<Person>(this, 'owner') as Person?;
  @override
  set owner(covariant Person? value) => RealmObject.set(this, 'owner', value);

  static const schema = SchemaObject(Dog, [
    SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
    SchemaProperty('age', RealmPropertyType.int, optional: true),
    SchemaProperty('owner', RealmPropertyType.object, optional: true),
  ]);
}

class Team extends _Team with RealmObject {
  Team({
    required String name,
    List<Person>? players,
  }) {
    this.name = name;
    this.players = players ?? [];
  }

  @override
  String get name => RealmObject.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObject.set(this, 'name', value);

  @override
  List<Person> get players => RealmObject.get<List<Person>>(this, 'players') as List<Person>;
  @override
  set players(covariant List<Person> value) => RealmObject.set(this, 'players', value);

  static const schema = SchemaObject(Team, [
    SchemaProperty('name', RealmPropertyType.string),
    SchemaProperty('players', RealmPropertyType.object),
  ]);
}
