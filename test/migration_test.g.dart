// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Person extends _PersonIntName with RealmEntity, RealmObject {
  Person(
    int name,
  ) {
    RealmObject.set(this, 'name', name);
  }

  Person._();

  @override
  int get name => RealmObject.get<int>(this, 'name') as int;
  @override
  set name(int value) => RealmObject.set(this, 'name', value);

  @override
  Stream<RealmObjectChanges<Person>> get changes =>
      RealmObject.getChanges<Person>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Person._);
    return const SchemaObject(Person, [
      SchemaProperty('name', RealmPropertyType.int),
    ]);
  }
}
