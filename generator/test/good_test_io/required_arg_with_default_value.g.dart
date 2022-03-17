// **************************************************************************
// RealmObjectGenerator
// **************************************************************************
part of 'required_arg_with_default_value.dart';

class Person extends _Person with RealmEntity, RealmObject {
  static var _defaultsSet = false;

  Person({
    int age = 47,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObject.setDefaults<Person>({
        'age': 47,
      });
    }
    RealmObject.set(this, 'age', age);
  }

  Person._();

  @override
  int get age => RealmObject.get<int>(this, 'age') as int;
  @override
  set age(int value) => RealmObject.set(this, 'age', value);

  @override
  Stream<RealmObjectChanges<Person>> get changes => RealmObject.getChanges<Person>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Person._);
    return const SchemaObject(Person, [
      SchemaProperty('age', RealmPropertyType.int),
    ]);
  }
}
