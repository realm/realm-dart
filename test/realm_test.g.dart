// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Car extends _Car with RealmObject {
  Car({
    required String make,
  }) {
    this.make = make;
  }

  @override
  String get make => RealmObject.get<String>(this, 'make');
  @override
  set make(String value) => RealmObject.set<String>(this, 'make', value);

  static const schema = SchemaObject(Car, [
    SchemaProperty('make', RealmPropertyType.string),
  ]);
}

class Person extends _Person with RealmObject {
  Person({
    required String name,
  }) {
    this.name = name;
  }

  @override
  String get name => RealmObject.get<String>(this, 'name');
  @override
  set name(String value) => RealmObject.set<String>(this, 'name', value);

  static const schema = SchemaObject(Person, [
    SchemaProperty('name', RealmPropertyType.string),
  ]);
}
