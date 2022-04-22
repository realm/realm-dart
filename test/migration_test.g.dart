// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class PersonIntName extends _PersonIntName with RealmEntity, RealmObject {
  PersonIntName(
    int name,
  ) {
    RealmObject.set(this, 'name', name);
  }

  PersonIntName._();

  @override
  int get name => RealmObject.get<int>(this, 'name') as int;
  @override
  set name(int value) => RealmObject.set(this, 'name', value);

  @override
  Stream<RealmObjectChanges<PersonIntName>> get changes =>
      RealmObject.getChanges<PersonIntName>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(PersonIntName._);
    return const SchemaObject(PersonIntName, 'Person', [
      SchemaProperty('name', RealmPropertyType.int),
    ]);
  }
}
