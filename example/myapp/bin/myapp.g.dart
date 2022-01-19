// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myapp.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Car extends _Car with RealmObject {
  Car(
    String make,
  ) {
    RealmObject.set(this, 'make', make);
  }

  Car._();

  @override
  String get make => RealmObject.get<String>(this, 'make') as String;

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Car._);
    return const SchemaObject(Car, [
      SchemaProperty('make', RealmPropertyType.string, primaryKey: true),
    ]);
  }
}
