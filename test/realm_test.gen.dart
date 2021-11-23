// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'realm_test.dart';


// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_local_variable
class Car extends _Car with RealmObject {
<<<<<<< HEAD
  Car([String make = 'Tesla']) {
      this.make = make;
  }

  @override
  String get make => RealmObject.get<String>(this, "make");
  @override
  set make(String value) => RealmObject.set<String>(this, "make", value);

  static SchemaObject get schema => SchemaObject(Car)..properties = [
    SchemaProperty("make", RealmPropertyType.String)
=======
  
  @override
  String get make => super.getString("make");
  @override
  set make(String value) => super.setString("make", value);

  @override
  static SchemaObject get schema => SchemaObject(Car)..properties = [
    SchemaProperty("make", RealmPropertyType.string)
>>>>>>> master
  ];
}

class Person extends _Person with RealmObject {
<<<<<<< HEAD
  @override
  String get name => RealmObject.get<String>(this, "name");
  @override
  set name(String value) => RealmObject.set<String>(this, "name", value);

  static SchemaObject get schema => SchemaObject(Person)..properties = [
    SchemaProperty("name", RealmPropertyType.String)
=======
  // ignore_for_file: unused_element, unused_local_variable

  @override
  String get name => super.getString("name");
  @override
  set name(String value) => super.setString("name", value);

  @override
  static SchemaObject get schema => SchemaObject(Person)..properties = [
    SchemaProperty("name", RealmPropertyType.string)
>>>>>>> master
  ];
}