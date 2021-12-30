// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Car extends _Car with RealmObject {
  static var _defaultsSet = false;

  Car(
    String make,
  ) {
    this.make = make;
    _defaultsSet = _defaultsSet || RealmObject.setDefaults<Car>({});
  }

  Car._();

  @override
  String get make => RealmObject.get<String>(this, 'make') as String;
  @override
  set make(String value) => RealmObject.set(this, 'make', value);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory<Car>(() => Car._());
    return const SchemaObject(Car, [
      SchemaProperty('make', RealmPropertyType.string),
    ]);
  }
}
