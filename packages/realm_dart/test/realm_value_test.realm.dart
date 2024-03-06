// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_value_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
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

  EJsonValue toEJson() {
    return <String, dynamic>{
      'x': x.toEJson(),
    };
  }

  static EJsonValue _toEJson(TuckedIn value) => value.toEJson();
  static TuckedIn _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'x': EJsonValue x,
      } =>
        TuckedIn(
          x: fromEJson(x),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(TuckedIn._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.embeddedObject, TuckedIn, 'TuckedIn', [
      SchemaProperty('x', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class AnythingGoes extends _AnythingGoes
    with RealmEntity, RealmObjectBase, RealmObject {
  AnythingGoes({
    RealmValue oneAny = const RealmValue.nullValue(),
    Iterable<RealmValue> manyAny = const [],
    Set<RealmValue> setOfAny = const {},
    Map<String, RealmValue> dictOfAny = const {},
  }) {
    RealmObjectBase.set(this, 'oneAny', oneAny);
    RealmObjectBase.set<RealmList<RealmValue>>(
        this, 'manyAny', RealmList<RealmValue>(manyAny));
    RealmObjectBase.set<RealmSet<RealmValue>>(
        this, 'setOfAny', RealmSet<RealmValue>(setOfAny));
    RealmObjectBase.set<RealmMap<RealmValue>>(
        this, 'dictOfAny', RealmMap<RealmValue>(dictOfAny));
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
  RealmMap<RealmValue> get dictOfAny =>
      RealmObjectBase.get<RealmValue>(this, 'dictOfAny')
          as RealmMap<RealmValue>;
  @override
  set dictOfAny(covariant RealmMap<RealmValue> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<RealmValue> get setOfAny =>
      RealmObjectBase.get<RealmValue>(this, 'setOfAny') as RealmSet<RealmValue>;
  @override
  set setOfAny(covariant RealmSet<RealmValue> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<AnythingGoes>> get changes =>
      RealmObjectBase.getChanges<AnythingGoes>(this);

  @override
  AnythingGoes freeze() => RealmObjectBase.freezeObject<AnythingGoes>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'oneAny': oneAny.toEJson(),
      'manyAny': manyAny.toEJson(),
      'dictOfAny': dictOfAny.toEJson(),
      'setOfAny': setOfAny.toEJson(),
    };
  }

  static EJsonValue _toEJson(AnythingGoes value) => value.toEJson();
  static AnythingGoes _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'oneAny': EJsonValue oneAny,
        'manyAny': EJsonValue manyAny,
        'dictOfAny': EJsonValue dictOfAny,
        'setOfAny': EJsonValue setOfAny,
      } =>
        AnythingGoes(
          oneAny: fromEJson(oneAny),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(AnythingGoes._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.realmObject, AnythingGoes, 'AnythingGoes', [
      SchemaProperty('oneAny', RealmPropertyType.mixed,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('manyAny', RealmPropertyType.mixed,
          optional: true, collectionType: RealmCollectionType.list),
      SchemaProperty('dictOfAny', RealmPropertyType.mixed,
          optional: true, collectionType: RealmCollectionType.map),
      SchemaProperty('setOfAny', RealmPropertyType.mixed,
          optional: true, collectionType: RealmCollectionType.set),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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

  EJsonValue toEJson() {
    return <String, dynamic>{
      'i': i.toEJson(),
    };
  }

  static EJsonValue _toEJson(Stuff value) => value.toEJson();
  static Stuff _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'i': EJsonValue i,
      } =>
        Stuff(
          i: fromEJson(i),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Stuff._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.realmObject, Stuff, 'Stuff', [
      SchemaProperty('i', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
