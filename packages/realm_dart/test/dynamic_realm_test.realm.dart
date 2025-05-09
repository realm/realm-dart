// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_realm_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
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
  Stream<RealmObjectChanges<Taskv2>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Taskv2>(this, keyPaths);

  @override
  Taskv2 freeze() => RealmObjectBase.freezeObject<Taskv2>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'description': description.toEJson(),
    };
  }

  static EJsonValue _toEJson(Taskv2 value) => value.toEJson();
  static Taskv2 _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'description': EJsonValue description,
      } =>
        Taskv2(
          fromEJson(id),
          fromEJson(description),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Taskv2._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Taskv2, 'Task', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('description', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
