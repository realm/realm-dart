// **************************************************************************
// RealmObjectGenerator
// **************************************************************************
part of 'required_argument.dart';

class Person extends _Person with RealmEntity, RealmObject {
  Person(
    String name,
  ) {
    RealmObject.set(this, 'name', name);
  }

  Person._();

  @override
  String get name => RealmObject.get<String>(this, 'name') as String;
  @override
  set name(String value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Person>> get changes => RealmObject.getChanges<Person>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Person._);
    return const SchemaObject(Person, [
      SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
    ]);
  }
}
