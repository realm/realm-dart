// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_value_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class AnythingGoes extends _AnythingGoes
    with RealmEntity, RealmObjectBase, RealmObject {
  AnythingGoes({
    RealmValue any = const RealmValue.nullValue(),
    Iterable<RealmValue> manyAny = const [],
  }) {
    RealmObjectBase.set(this, 'any', any);
    RealmObjectBase.set<RealmList<RealmValue>>(
        this, 'manyAny', RealmList<RealmValue>(manyAny));
  }

  AnythingGoes._();

  @override
  RealmValue get any =>
      RealmObjectBase.get<RealmValue>(this, 'any') as RealmValue;
  @override
  set any(RealmValue value) => RealmObjectBase.set(this, 'any', value);

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
      SchemaProperty('any', RealmPropertyType.mixed,
          optional: true, indexed: true),
      SchemaProperty('manyAny', RealmPropertyType.mixed,
          optional: true, collectionType: RealmCollectionType.list),
    ]);
  }
}
