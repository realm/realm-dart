// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_value_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class TuckedIn extends _TuckedIn
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  static var _defaultsSet = false;

  TuckedIn({
    int x = 42,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<TuckedIn>({
        'x': 42,
      });
    }
    RealmObjectBase.set(this, 'x', x);
  }

  TuckedIn._();

  @override
  int get x => RealmObjectBase.get<int>(this, 'x') as int;
  @override
  set x(int value) => RealmObjectBase.set(this, 'x', value);

  @override
  Stream<RealmObjectChanges<TuckedIn>> get changes =>
      RealmObjectBase.getChanges<TuckedIn>(this);

  @override
  TuckedIn freeze() => RealmObjectBase.freezeObject<TuckedIn>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(TuckedIn._);
    return const SchemaObject(ObjectType.embeddedObject, TuckedIn, 'TuckedIn', [
      SchemaProperty('x', RealmPropertyType.int),
    ]);
  }
}

class AnythingGoes extends _AnythingGoes
    with RealmEntity, RealmObjectBase, RealmObject {
  AnythingGoes({
    RealmValue oneAny = const RealmValue.nullValue(),
    Iterable<RealmValue> manyAny = const [],
  }) {
    RealmObjectBase.set(this, 'oneAny', oneAny);
    RealmObjectBase.set<RealmList<RealmValue>>(
        this, 'manyAny', RealmList<RealmValue>(manyAny));
  }

  AnythingGoes._();

  @override
  RealmValue get oneAny =>
      RealmObjectBase.get<RealmValue>(this, 'oneAny') as RealmValue;
  @override
  set oneAny(RealmValue value) => RealmObjectBase.set(this, 'oneAny', value);

  @override
  RealmList<RealmValue> get manyAny =>
      RealmObjectBase.get<RealmValue>(this, 'manyAny') as RealmList<RealmValue>;
  @override
  set manyAny(covariant RealmList<RealmValue> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<AnythingGoes>> get changes =>
      RealmObjectBase.getChanges<AnythingGoes>(this);

  @override
  AnythingGoes freeze() => RealmObjectBase.freezeObject<AnythingGoes>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(AnythingGoes._);
    return const SchemaObject(
        ObjectType.realmObject, AnythingGoes, 'AnythingGoes', [
      SchemaProperty('oneAny', RealmPropertyType.mixed,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('manyAny', RealmPropertyType.mixed,
          optional: true, collectionType: RealmCollectionType.list),
    ]);
  }
}

class Stuff extends _Stuff with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Stuff({
    int i = 42,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Stuff>({
        'i': 42,
      });
    }
    RealmObjectBase.set(this, 'i', i);
  }

  Stuff._();

  @override
  int get i => RealmObjectBase.get<int>(this, 'i') as int;
  @override
  set i(int value) => RealmObjectBase.set(this, 'i', value);

  @override
  Stream<RealmObjectChanges<Stuff>> get changes =>
      RealmObjectBase.getChanges<Stuff>(this);

  @override
  Stuff freeze() => RealmObjectBase.freezeObject<Stuff>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Stuff._);
    return const SchemaObject(ObjectType.realmObject, Stuff, 'Stuff', [
      SchemaProperty('i', RealmPropertyType.int),
    ]);
  }
}
