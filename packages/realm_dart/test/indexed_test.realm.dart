// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'indexed_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class WithIndexes extends _WithIndexes
    with RealmEntity, RealmObjectBase, RealmObject {
  WithIndexes(
    int anInt,
    bool aBool,
    String string,
    DateTime timestamp,
    ObjectId objectId,
    Uuid uuid,
  ) {
    RealmObjectBase.set(this, 'anInt', anInt);
    RealmObjectBase.set(this, 'aBool', aBool);
    RealmObjectBase.set(this, 'string', string);
    RealmObjectBase.set(this, 'timestamp', timestamp);
    RealmObjectBase.set(this, 'objectId', objectId);
    RealmObjectBase.set(this, 'uuid', uuid);
  }

  WithIndexes._();

  @override
  int get anInt => RealmObjectBase.get<int>(this, 'anInt') as int;
  @override
  set anInt(int value) => RealmObjectBase.set(this, 'anInt', value);

  @override
  bool get aBool => RealmObjectBase.get<bool>(this, 'aBool') as bool;
  @override
  set aBool(bool value) => RealmObjectBase.set(this, 'aBool', value);

  @override
  String get string => RealmObjectBase.get<String>(this, 'string') as String;
  @override
  set string(String value) => RealmObjectBase.set(this, 'string', value);

  @override
  DateTime get timestamp =>
      RealmObjectBase.get<DateTime>(this, 'timestamp') as DateTime;
  @override
  set timestamp(DateTime value) =>
      RealmObjectBase.set(this, 'timestamp', value);

  @override
  ObjectId get objectId =>
      RealmObjectBase.get<ObjectId>(this, 'objectId') as ObjectId;
  @override
  set objectId(ObjectId value) => RealmObjectBase.set(this, 'objectId', value);

  @override
  Uuid get uuid => RealmObjectBase.get<Uuid>(this, 'uuid') as Uuid;
  @override
  set uuid(Uuid value) => RealmObjectBase.set(this, 'uuid', value);

  @override
  Stream<RealmObjectChanges<WithIndexes>> get changes =>
      RealmObjectBase.getChanges<WithIndexes>(this);

  @override
  WithIndexes freeze() => RealmObjectBase.freezeObject<WithIndexes>(this);

  static EJsonValue _encodeWithIndexes(WithIndexes value) {
    return <String, dynamic>{
      'anInt': toEJson(value.anInt),
      'aBool': toEJson(value.aBool),
      'string': toEJson(value.string),
      'timestamp': toEJson(value.timestamp),
      'objectId': toEJson(value.objectId),
      'uuid': toEJson(value.uuid),
    };
  }

  static WithIndexes _decodeWithIndexes(EJsonValue ejson) {
    return switch (ejson) {
      {
        'anInt': EJsonValue anInt,
        'aBool': EJsonValue aBool,
        'string': EJsonValue string,
        'timestamp': EJsonValue timestamp,
        'objectId': EJsonValue objectId,
        'uuid': EJsonValue uuid,
      } =>
        WithIndexes(
          fromEJson(anInt),
          fromEJson(aBool),
          fromEJson(string),
          fromEJson(timestamp),
          fromEJson(objectId),
          fromEJson(uuid),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(WithIndexes._);
    register(_encodeWithIndexes, _decodeWithIndexes);
    return const SchemaObject(
        ObjectType.realmObject, WithIndexes, 'WithIndexes', [
      SchemaProperty('anInt', RealmPropertyType.int,
          indexType: RealmIndexType.regular),
      SchemaProperty('aBool', RealmPropertyType.bool,
          indexType: RealmIndexType.regular),
      SchemaProperty('string', RealmPropertyType.string,
          indexType: RealmIndexType.regular),
      SchemaProperty('timestamp', RealmPropertyType.timestamp,
          indexType: RealmIndexType.regular),
      SchemaProperty('objectId', RealmPropertyType.objectid,
          indexType: RealmIndexType.regular),
      SchemaProperty('uuid', RealmPropertyType.uuid,
          indexType: RealmIndexType.regular),
    ]);
  }();
}

class NoIndexes extends _NoIndexes
    with RealmEntity, RealmObjectBase, RealmObject {
  NoIndexes(
    int anInt,
    bool aBool,
    String string,
    DateTime timestamp,
    ObjectId objectId,
    Uuid uuid,
  ) {
    RealmObjectBase.set(this, 'anInt', anInt);
    RealmObjectBase.set(this, 'aBool', aBool);
    RealmObjectBase.set(this, 'string', string);
    RealmObjectBase.set(this, 'timestamp', timestamp);
    RealmObjectBase.set(this, 'objectId', objectId);
    RealmObjectBase.set(this, 'uuid', uuid);
  }

  NoIndexes._();

  @override
  int get anInt => RealmObjectBase.get<int>(this, 'anInt') as int;
  @override
  set anInt(int value) => RealmObjectBase.set(this, 'anInt', value);

  @override
  bool get aBool => RealmObjectBase.get<bool>(this, 'aBool') as bool;
  @override
  set aBool(bool value) => RealmObjectBase.set(this, 'aBool', value);

  @override
  String get string => RealmObjectBase.get<String>(this, 'string') as String;
  @override
  set string(String value) => RealmObjectBase.set(this, 'string', value);

  @override
  DateTime get timestamp =>
      RealmObjectBase.get<DateTime>(this, 'timestamp') as DateTime;
  @override
  set timestamp(DateTime value) =>
      RealmObjectBase.set(this, 'timestamp', value);

  @override
  ObjectId get objectId =>
      RealmObjectBase.get<ObjectId>(this, 'objectId') as ObjectId;
  @override
  set objectId(ObjectId value) => RealmObjectBase.set(this, 'objectId', value);

  @override
  Uuid get uuid => RealmObjectBase.get<Uuid>(this, 'uuid') as Uuid;
  @override
  set uuid(Uuid value) => RealmObjectBase.set(this, 'uuid', value);

  @override
  Stream<RealmObjectChanges<NoIndexes>> get changes =>
      RealmObjectBase.getChanges<NoIndexes>(this);

  @override
  NoIndexes freeze() => RealmObjectBase.freezeObject<NoIndexes>(this);

  static EJsonValue _encodeNoIndexes(NoIndexes value) {
    return <String, dynamic>{
      'anInt': toEJson(value.anInt),
      'aBool': toEJson(value.aBool),
      'string': toEJson(value.string),
      'timestamp': toEJson(value.timestamp),
      'objectId': toEJson(value.objectId),
      'uuid': toEJson(value.uuid),
    };
  }

  static NoIndexes _decodeNoIndexes(EJsonValue ejson) {
    return switch (ejson) {
      {
        'anInt': EJsonValue anInt,
        'aBool': EJsonValue aBool,
        'string': EJsonValue string,
        'timestamp': EJsonValue timestamp,
        'objectId': EJsonValue objectId,
        'uuid': EJsonValue uuid,
      } =>
        NoIndexes(
          fromEJson(anInt),
          fromEJson(aBool),
          fromEJson(string),
          fromEJson(timestamp),
          fromEJson(objectId),
          fromEJson(uuid),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(NoIndexes._);
    register(_encodeNoIndexes, _decodeNoIndexes);
    return const SchemaObject(ObjectType.realmObject, NoIndexes, 'NoIndexes', [
      SchemaProperty('anInt', RealmPropertyType.int),
      SchemaProperty('aBool', RealmPropertyType.bool),
      SchemaProperty('string', RealmPropertyType.string),
      SchemaProperty('timestamp', RealmPropertyType.timestamp),
      SchemaProperty('objectId', RealmPropertyType.objectid),
      SchemaProperty('uuid', RealmPropertyType.uuid),
    ]);
  }();
}

class ObjectWithFTSIndex extends _ObjectWithFTSIndex
    with RealmEntity, RealmObjectBase, RealmObject {
  ObjectWithFTSIndex(
    String title,
    String summary, {
    String? nullableSummary,
  }) {
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'summary', summary);
    RealmObjectBase.set(this, 'nullableSummary', nullableSummary);
  }

  ObjectWithFTSIndex._();

  @override
  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  @override
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  @override
  String get summary => RealmObjectBase.get<String>(this, 'summary') as String;
  @override
  set summary(String value) => RealmObjectBase.set(this, 'summary', value);

  @override
  String? get nullableSummary =>
      RealmObjectBase.get<String>(this, 'nullableSummary') as String?;
  @override
  set nullableSummary(String? value) =>
      RealmObjectBase.set(this, 'nullableSummary', value);

  @override
  Stream<RealmObjectChanges<ObjectWithFTSIndex>> get changes =>
      RealmObjectBase.getChanges<ObjectWithFTSIndex>(this);

  @override
  ObjectWithFTSIndex freeze() =>
      RealmObjectBase.freezeObject<ObjectWithFTSIndex>(this);

  static EJsonValue _encodeObjectWithFTSIndex(ObjectWithFTSIndex value) {
    return <String, dynamic>{
      'title': toEJson(value.title),
      'summary': toEJson(value.summary),
      'nullableSummary': toEJson(value.nullableSummary),
    };
  }

  static ObjectWithFTSIndex _decodeObjectWithFTSIndex(EJsonValue ejson) {
    return switch (ejson) {
      {
        'title': EJsonValue title,
        'summary': EJsonValue summary,
        'nullableSummary': EJsonValue nullableSummary,
      } =>
        ObjectWithFTSIndex(
          fromEJson(title),
          fromEJson(summary),
          nullableSummary: fromEJson(nullableSummary),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ObjectWithFTSIndex._);
    register(_encodeObjectWithFTSIndex, _decodeObjectWithFTSIndex);
    return const SchemaObject(
        ObjectType.realmObject, ObjectWithFTSIndex, 'ObjectWithFTSIndex', [
      SchemaProperty('title', RealmPropertyType.string),
      SchemaProperty('summary', RealmPropertyType.string,
          indexType: RealmIndexType.fullText),
      SchemaProperty('nullableSummary', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.fullText),
    ]);
  }();
}
