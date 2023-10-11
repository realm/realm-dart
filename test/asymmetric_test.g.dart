// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asymmetric_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Asymmetric extends _Asymmetric
    with RealmEntity, RealmObjectBase, AsymmetricObject {
  Asymmetric(
    ObjectId id, {
    Iterable<Embedded> embeddedObjects = const [],
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set<RealmList<Embedded>>(
        this, 'embeddedObjects', RealmList<Embedded>(embeddedObjects));
  }

  Asymmetric._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  RealmList<Embedded> get embeddedObjects =>
      RealmObjectBase.get<Embedded>(this, 'embeddedObjects')
          as RealmList<Embedded>;
  @override
  set embeddedObjects(covariant RealmList<Embedded> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Asymmetric>> get changes =>
      RealmObjectBase.getChanges<Asymmetric>(this);

  @override
  Asymmetric freeze() => RealmObjectBase.freezeObject<Asymmetric>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Asymmetric._);
    return const SchemaObject(
        ObjectType.asymmetricObject, Asymmetric, 'Asymmetric', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('embeddedObjects', RealmPropertyType.object,
          linkTarget: 'Embedded', collectionType: RealmCollectionType.list),
    ]);
  }
}

// ignore_for_file: type=lint
class Embedded extends _Embedded
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  Embedded(
    int value, {
    RealmValue any = const RealmValue.nullValue(),
    Symmetric? symmetric,
  }) {
    RealmObjectBase.set(this, 'value', value);
    RealmObjectBase.set(this, 'any', any);
    RealmObjectBase.set(this, 'symmetric', symmetric);
  }

  Embedded._();

  @override
  int get value => RealmObjectBase.get<int>(this, 'value') as int;
  @override
  set value(int value) => RealmObjectBase.set(this, 'value', value);

  @override
  RealmValue get any =>
      RealmObjectBase.get<RealmValue>(this, 'any') as RealmValue;
  @override
  set any(RealmValue value) => RealmObjectBase.set(this, 'any', value);

  @override
  Symmetric? get symmetric =>
      RealmObjectBase.get<Symmetric>(this, 'symmetric') as Symmetric?;
  @override
  set symmetric(covariant Symmetric? value) =>
      RealmObjectBase.set(this, 'symmetric', value);

  @override
  Stream<RealmObjectChanges<Embedded>> get changes =>
      RealmObjectBase.getChanges<Embedded>(this);

  @override
  Embedded freeze() => RealmObjectBase.freezeObject<Embedded>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Embedded._);
    return const SchemaObject(ObjectType.embeddedObject, Embedded, 'Embedded', [
      SchemaProperty('value', RealmPropertyType.int),
      SchemaProperty('any', RealmPropertyType.mixed, optional: true),
      SchemaProperty('symmetric', RealmPropertyType.object,
          optional: true, linkTarget: 'Symmetric'),
    ]);
  }
}

// ignore_for_file: type=lint
class Symmetric extends _Symmetric
    with RealmEntity, RealmObjectBase, RealmObject {
  Symmetric(
    ObjectId id,
  ) {
    RealmObjectBase.set(this, '_id', id);
  }

  Symmetric._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  Stream<RealmObjectChanges<Symmetric>> get changes =>
      RealmObjectBase.getChanges<Symmetric>(this);

  @override
  Symmetric freeze() => RealmObjectBase.freezeObject<Symmetric>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Symmetric._);
    return const SchemaObject(ObjectType.realmObject, Symmetric, 'Symmetric', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
    ]);
  }
}
