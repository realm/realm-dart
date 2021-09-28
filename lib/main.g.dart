// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Car extends RealmObject {
  // ignore_for_file: unused_element, unused_local_variable
  Car._constructor() : super.constructor();
  Car();

  @RealmProperty()
  String get make => super['make'] as String;
  set make(String value) => super['make'] = value;

  static dynamic getSchema() {
    const dynamic type = _Car;
    return RealmObject.getSchema('Car', [
      SchemaProperty('make', type: 'string'),
    ]);
  }
}

class Person extends RealmObject {
  // ignore_for_file: unused_element, unused_local_variable
  Person._constructor() : super.constructor();
  Person();

  @RealmProperty()
  String get name => super['name'] as String;
  set name(String value) => super['name'] = value;

  static dynamic getSchema() {
    const dynamic type = _Person;
    return RealmObject.getSchema('Person', [
      SchemaProperty('name', type: 'string'),
    ]);
  }
}
