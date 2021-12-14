// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

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
  set make(String value) => RealmObject.set(this, 'make', value);

  static const schema = SchemaObject(Car, [
    SchemaProperty('make', RealmPropertyType.string),
  ]);
}
