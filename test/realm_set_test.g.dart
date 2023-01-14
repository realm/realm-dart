// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_set_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class TestRealmSets extends _TestRealmSets with RealmEntity, RealmObjectBase, RealmObject {
  TestRealmSets(
    int key,
    //  Set<bool> boolSet,
    //  Set<int> intSet,
    //  Set<String> stringSet,
    //  Set<double> doubleSet
  ) {
    RealmObjectBase.set(this, 'key', key);
    RealmObjectBase.set<RealmSet<bool>>(this, 'boolSet', RealmSet<bool>({}));
    RealmObjectBase.set<RealmSet<int>>(this, 'intSet', RealmSet<int>({}));
    RealmObjectBase.set<RealmSet<String>>(this, 'stringSet', RealmSet<String>({}));
    RealmObjectBase.set<RealmSet<double>>(this, 'doubleSet', RealmSet<double>({}));
    // RealmObjectBase.set(this, 'boolSet', boolSet);
    // RealmObjectBase.set(this, 'intSet', intSet);
    // RealmObjectBase.set(this, 'stringSet', stringSet);
    // RealmObjectBase.set(this, 'doubleSet', doubleSet);
  }

  TestRealmSets._();

  @override
  int get key => RealmObjectBase.get<int>(this, 'key') as int;
  @override
  set key(int value) => RealmObjectBase.set(this, 'key', value);

  @override
  RealmSet<bool> get boolSet => RealmObjectBase.get<bool>(this, 'boolSet') as RealmSet<bool>;
  @override
  set boolSet(covariant RealmSet<bool> value) => throw RealmUnsupportedSetError();

  @override
  RealmSet<int> get intSet => RealmObjectBase.get<int>(this, 'intSet') as RealmSet<int>;
  @override
  set intSet(covariant RealmSet<int> value) => throw RealmUnsupportedSetError();

  @override
  RealmSet<String> get stringSet => RealmObjectBase.get<String>(this, 'stringSet') as RealmSet<String>;
  @override
  set stringSet(covariant RealmSet<String> value) => throw RealmUnsupportedSetError();

  @override
  RealmSet<double> get doubleSet => RealmObjectBase.get<double>(this, 'doubleSet') as RealmSet<double>;
  @override
  set doubleSet(covariant RealmSet<double> value) => throw RealmUnsupportedSetError();

  // @override
  // RealmSet<int> get intSet => RealmObjectBase.get<RealmSet<int>>(this, 'intSet') as RealmSet<int>;
  // @override
  // set intSet(covariant RealmSet<int> value) => throw RealmUnsupportedSetError();

  // @override
  // RealmSet<String> get stringSet => RealmObjectBase.get<RealmSet<String>>(this, 'stringSet') as RealmSet<String>;
  // @override
  // set stringSet(covariant RealmSet<String> value) => throw RealmUnsupportedSetError();

  // @override
  // RealmSet<double> get doubleSet => RealmObjectBase.get<RealmSet<double>>(this, 'doubleSet') as RealmSet<double>;
  // @override
  // set doubleSet(covariant RealmSet<double> value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<TestRealmSets>> get changes => RealmObjectBase.getChanges<TestRealmSets>(this);

  @override
  TestRealmSets freeze() => RealmObjectBase.freezeObject<TestRealmSets>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(TestRealmSets._);
    return const SchemaObject(ObjectType.realmObject, TestRealmSets, 'TestRealmSets', [
      SchemaProperty('key', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('boolSet', RealmPropertyType.bool, collectionType: RealmCollectionType.set),
      SchemaProperty('intSet', RealmPropertyType.int, collectionType: RealmCollectionType.set),
      SchemaProperty('stringSet', RealmPropertyType.string, collectionType: RealmCollectionType.set),
      SchemaProperty('doubleSet', RealmPropertyType.double, collectionType: RealmCollectionType.set),
      // SchemaProperty('intSet', RealmPropertyType.int, collectionType: RealmCollectionType.set),
      // SchemaProperty('stringSet', RealmPropertyType.string, collectionType: RealmCollectionType.set),
      // SchemaProperty('doubleSet', RealmPropertyType.double, collectionType: RealmCollectionType.set),
    ]);
  }
}
