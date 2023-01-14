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
    RealmObjectBase.set<RealmSet<DateTime>>(this, 'dateTimeSet', RealmSet<DateTime>({}));
    RealmObjectBase.set<RealmSet<ObjectId>>(this, 'objectIdSet', RealmSet<ObjectId>({}));
    RealmObjectBase.set<RealmSet<Uuid>>(this, 'uuidSet', RealmSet<Uuid>({}));

    RealmObjectBase.set<RealmSet<bool?>>(this, 'nullableBoolSet', RealmSet<bool?>({}));
    RealmObjectBase.set<RealmSet<int?>>(this, 'nullableIntSet', RealmSet<int?>({}));
    RealmObjectBase.set<RealmSet<String?>>(this, 'nullableStringSet', RealmSet<String?>({}));
    RealmObjectBase.set<RealmSet<double?>>(this, 'nullableDoubleSet', RealmSet<double?>({}));
    RealmObjectBase.set<RealmSet<DateTime?>>(this, 'nullableDateTimeSet', RealmSet<DateTime?>({}));
    RealmObjectBase.set<RealmSet<ObjectId?>>(this, 'nullableObjectIdSet', RealmSet<ObjectId?>({}));
    RealmObjectBase.set<RealmSet<Uuid?>>(this, 'nullableUuidSet', RealmSet<Uuid?>({}));
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

  @override
  RealmSet<DateTime> get dateTimeSet => RealmObjectBase.get<DateTime>(this, 'dateTimeSet') as RealmSet<DateTime>;
  @override
  set dateTimeSet(covariant RealmSet<DateTime> value) => throw RealmUnsupportedSetError();

  @override
  RealmSet<ObjectId> get objectIdSet => RealmObjectBase.get<ObjectId>(this, 'objectIdSet') as RealmSet<ObjectId>;
  @override
  set objectIdSet(covariant RealmSet<ObjectId> value) => throw RealmUnsupportedSetError();

  @override
  RealmSet<Uuid> get uuidSet => RealmObjectBase.get<Uuid>(this, 'uuidSet') as RealmSet<Uuid>;
  @override
  set uuidSet(covariant RealmSet<Uuid> value) => throw RealmUnsupportedSetError();

  @override
  RealmSet<bool?> get nullableBoolSet => RealmObjectBase.get<bool?>(this, 'nullableBoolSet') as RealmSet<bool?>;
  @override
  set nullableBoolSet(covariant RealmSet<bool?> value) => throw RealmUnsupportedSetError();





  @override
  RealmSet<int?> get nullableIntSet => RealmObjectBase.get<int?>(this, 'nullableIntSet') as RealmSet<int?>;
  @override
  set nullableIntSet(covariant RealmSet<int?> value) => throw RealmUnsupportedSetError();

  @override
  RealmSet<String?> get nullableStringSet => RealmObjectBase.get<String?>(this, 'nullableStringSet') as RealmSet<String?>;
  @override
  set nullableStringSet(covariant RealmSet<String?> value) => throw RealmUnsupportedSetError();

  @override
  RealmSet<double?> get nullableDoubleSet => RealmObjectBase.get<double?>(this, 'nullableDoubleSet') as RealmSet<double?>;
  @override
  set nullableDoubleSet(covariant RealmSet<double?> value) => throw RealmUnsupportedSetError();

  @override
  RealmSet<DateTime?> get nullableDateTimeSet => RealmObjectBase.get<DateTime?>(this, 'nullableDateTimeSet') as RealmSet<DateTime?>;
  @override
  set nullableDateTimeSet(covariant RealmSet<DateTime?> value) => throw RealmUnsupportedSetError();

  @override
  RealmSet<ObjectId?> get nullableObjectIdSet => RealmObjectBase.get<ObjectId?>(this, 'nullableObjectIdSet') as RealmSet<ObjectId?>;
  @override
  set nullableObjectIdSet(covariant RealmSet<ObjectId?> value) => throw RealmUnsupportedSetError();

  @override
  RealmSet<Uuid?> get nullableUuidSet => RealmObjectBase.get<Uuid?>(this, 'nullableUuidSet') as RealmSet<Uuid?>;
  @override
  set nullableUuidSet(covariant RealmSet<Uuid?> value) => throw RealmUnsupportedSetError();


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
      SchemaProperty('dateTimeSet', RealmPropertyType.timestamp, collectionType: RealmCollectionType.set),
      SchemaProperty('objectIdSet', RealmPropertyType.objectid, collectionType: RealmCollectionType.set),
      SchemaProperty('uuidSet', RealmPropertyType.uuid, collectionType: RealmCollectionType.set),
      SchemaProperty('nullableBoolSet', RealmPropertyType.bool, collectionType: RealmCollectionType.set, optional: true),
      SchemaProperty('nullableIntSet', RealmPropertyType.int, collectionType: RealmCollectionType.set, optional: true),
      SchemaProperty('nullableStringSet', RealmPropertyType.string, collectionType: RealmCollectionType.set, optional: true),
      SchemaProperty('nullableDoubleSet', RealmPropertyType.double, collectionType: RealmCollectionType.set, optional: true),
      SchemaProperty('nullableDateTimeSet', RealmPropertyType.timestamp, collectionType: RealmCollectionType.set, optional: true),
      SchemaProperty('nullableObjectIdSet', RealmPropertyType.objectid, collectionType: RealmCollectionType.set, optional: true),
      SchemaProperty('nullableUuidSet', RealmPropertyType.uuid, collectionType: RealmCollectionType.set, optional: true),
      
    ]);
  }
}
