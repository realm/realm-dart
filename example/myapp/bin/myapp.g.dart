// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myapp.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class MyCar extends _MyCar with RealmObject {
  MyCar(
    String make,
  ) {
    RealmObject.set(this, 'make', make);
  }

  MyCar._();

  @override
  String get make => RealmObject.get<String>(this, 'make') as String;

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(MyCar._);
    return const SchemaObject(MyCar, [
      SchemaProperty('make', RealmPropertyType.string, primaryKey: true),
    ]);
  }
}
