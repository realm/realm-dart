// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_realm_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Taskv2 extends _Taskv2 with RealmEntity, RealmObjectBase, RealmObject {
  Taskv2(
    ObjectId id,
    String description,
  ) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'description', description);
  }

  Taskv2._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get description =>
      RealmObjectBase.get<String>(this, 'description') as String;
  @override
  set description(String value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  Stream<RealmObjectChanges<Taskv2>> get changes =>
      RealmObjectBase.getChanges<Taskv2>(this);

  @override
  Taskv2 freeze() => RealmObjectBase.freezeObject<Taskv2>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Taskv2._);
    return SchemaObject(ObjectType.realmObject, Taskv2, 'Task', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('description', RealmPropertyType.string),
    ]);
  }

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
