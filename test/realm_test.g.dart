// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class CardV1 extends _CardV1 with RealmEntity, RealmObjectBase, RealmObject {
  CardV1(
    ObjectId id, {
    Iterable<int> cardsReference = const [],
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set<RealmList<int>>(
        this, 'cardsReference', RealmList<int>(cardsReference));
  }

  CardV1._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  RealmList<int> get cardsReference =>
      RealmObjectBase.get<int>(this, 'cardsReference') as RealmList<int>;
  @override
  set cardsReference(covariant RealmList<int> value) =>
      throw RealmUnsupportedSetError();

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
      SchemaProperty('cardsReference', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
    ]);
  }
}

class CardV2 extends _CardV2 with RealmEntity, RealmObjectBase, RealmObject {
  CardV2(
    ObjectId id, {
    Iterable<CardItem> cardsReference = const [],
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set<RealmList<CardItem>>(
        this, 'cardsReference', RealmList<CardItem>(cardsReference));
  }

  CardV2._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  RealmList<CardItem> get cardsReference =>
      RealmObjectBase.get<CardItem>(this, 'cardsReference')
          as RealmList<CardItem>;
  @override
  set cardsReference(covariant RealmList<CardItem> value) =>
      throw RealmUnsupportedSetError();

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
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('cardsReference', RealmPropertyType.object,
          linkTarget: 'CardItem', collectionType: RealmCollectionType.list),
    ]);
  }
}

class CardItem extends _CardItem
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  CardItem(
    int value,
  ) {
    RealmObjectBase.set(this, 'value', value);
  }

  CardItem._();

  @override
  int get value => RealmObjectBase.get<int>(this, 'value') as int;
  @override
  set value(int value) => RealmObjectBase.set(this, 'value', value);

  @override
  Stream<RealmObjectChanges<CardItem>> get changes =>
      RealmObjectBase.getChanges<CardItem>(this);

  @override
  CardItem freeze() => RealmObjectBase.freezeObject<CardItem>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(CardItem._);
    return const SchemaObject(ObjectType.embeddedObject, CardItem, 'CardItem', [
      SchemaProperty('value', RealmPropertyType.int),
    ]);
  }
}
