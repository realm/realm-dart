// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'realm_test.dart';


// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_local_variable
class Car extends _Car with RealmObject {
  static bool? _defaultsSet;

  Car({String make = 'Tesla'}) {
      _defaultsSet ??= RealmObject.setDefaults<Car>({"make": "Tesla"});
  }

  Car._() {}

  static Car _createInstance() {
    return Car._();
  }

  @override
  String get make => RealmObject.get<String>(this, "make");
  @override
  set make(String value) => RealmObject.set<String>(this, "make", value);

  static SchemaObject get schema { 
    RealmObject.registerFactory<Car>(_createInstance);
    return SchemaObject(Car)..properties = [SchemaProperty("make", RealmPropertyType.string, primaryKey: true)];
  }
}

class Person extends _Person with RealmObject {
  @override
  String get name => RealmObject.get<String>(this, "name");
  @override
  set name(String value) => RealmObject.set<String>(this, "name", value);

  static SchemaObject get schema => SchemaObject(Person)..properties = [
    SchemaProperty("name", RealmPropertyType.string)
  ];
}