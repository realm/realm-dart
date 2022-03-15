// **************************************************************************
// RealmObjectGenerator
// **************************************************************************
part of 'pinhole.dart';

class Foo extends _Foo with RealmEntity, RealmObject {
  static var _defaultsSet = false;

  Foo({
    int x = 0,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObject.setDefaults<Foo>({
        'x': 0,
      });
    }
    RealmObject.set(this, 'x', x);
  }

  Foo._();

  @override
  int get x => RealmObject.get<int>(this, 'x') as int;
  @override
  set x(int value) => RealmObject.set(this, 'x', value);

  @override
  Stream<RealmObjectChanges<Foo>> get changes => RealmObject.getChanges<Foo>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Foo._);
    return const SchemaObject(Foo, [
      SchemaProperty('x', RealmPropertyType.int),
    ]);
  }
}
