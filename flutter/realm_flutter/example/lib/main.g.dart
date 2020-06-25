// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Car extends RealmObject {
  Car._constructor() : super.constructor();
  Car() {}

  @RealmProperty()
  String get make => super['make'];
  set make(String value) => super['make'] = value;

  static dynamic getSchema() {
    return RealmObject.getSchema('Car', [
      new SchemaProperty('make', type: 'string'),
    ]);
  }
}
