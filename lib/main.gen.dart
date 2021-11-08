// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'main.dart';


// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_local_variable
class Car extends _Car with RealmObject {
  
  @override
  String get make => super.getString("make");
  @override
  set make(String value) => super.setString("make", value);

  @override
  static SchemaObject get schema => SchemaObject(Car)..properties = [
    SchemaProperty("make", RealmPropertyType.String)
  ];
}

class Person extends _Person with RealmObject {
  // ignore_for_file: unused_element, unused_local_variable

  @override
  String get name => super.getString("name");
  @override
  set name(String value) => super.setString("name", value);

  @override
  static SchemaObject get schema => SchemaObject(Person)..properties = [
    SchemaProperty("name", RealmPropertyType.String)
  ];
}