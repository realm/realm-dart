// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'main.dart';


// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_local_variable
class Car extends _Car with RealmObject {
  
  @override
  String get make => RealmObject.get<String>(this, "make") as String;
  @override
  set make(String value) => RealmObject.set<String>(this, "make", value);

  @override
  static SchemaObject get schema => SchemaObject(Car)..properties = [
    SchemaProperty("make", RealmPropertyType.string)
  ];
}

class Person extends _Person with RealmObject {
  // ignore_for_file: unused_element, unused_local_variable

  @override
  String get name => RealmObject.get<String>(this, "name") as String;
  @override
  set name(String value) => RealmObject.set<String>(this, "name", value);

  @override
  static SchemaObject get schema => SchemaObject(Person)..properties = [
    SchemaProperty("name", RealmPropertyType.string)
  ];
}

List<SchemaObject> get schema => [Person.schema, Car.schema];