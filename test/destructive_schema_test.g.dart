// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destructive_schema_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class CardV1 extends _CardV1 with RealmEntity, RealmObjectBase, RealmObject {
  CardV1(
    ObjectId id,
  ) {
    RealmObjectBase.set(this, '_id', id);
  }

  CardV1._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  Stream<RealmObjectChanges<CardV1>> get changes =>
      RealmObjectBase.getChanges<CardV1>(this);

  @override
  CardV1 freeze() => RealmObjectBase.freezeObject<CardV1>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(CardV1._);
    return const SchemaObject(ObjectType.realmObject, CardV1, 'Card', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
    ]);
  }
}

class CardV2 extends _CardV2 with RealmEntity, RealmObjectBase, RealmObject {
  CardV2(
    Uuid id,
  ) {
    RealmObjectBase.set(this, '_id', id);
  }

  CardV2._();

  @override
  Uuid get id => RealmObjectBase.get<Uuid>(this, '_id') as Uuid;
  @override
  set id(Uuid value) => RealmObjectBase.set(this, '_id', value);

  @override
  Stream<RealmObjectChanges<CardV2>> get changes =>
      RealmObjectBase.getChanges<CardV2>(this);

  @override
  CardV2 freeze() => RealmObjectBase.freezeObject<CardV2>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(CardV2._);
    return const SchemaObject(ObjectType.realmObject, CardV2, 'Card', [
      SchemaProperty('id', RealmPropertyType.uuid,
          mapTo: '_id', primaryKey: true),
    ]);
  }
}
