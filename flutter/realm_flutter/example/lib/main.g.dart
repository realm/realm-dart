// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'main.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_local_variable
class Car extends _Car with RealmObject {
  static bool? _defaultsSet;

  Car([String make = 'Tesla']) {
    _defaultsSet ??= RealmObject.setDefaults<Car>({"make": "Tesla"});
  }

  Car._();

  @override
  String get make => RealmObject.get<String>(this, "make") as String;
  @override
  set make(String value) => RealmObject.set<String>(this, "make", value);

  static SchemaObject get schema {
    RealmObject.registerFactory<Car>(() => Car._());
    return SchemaObject(Car)..properties = [SchemaProperty("make", RealmPropertyType.string, primaryKey: true)];
  }
}
