// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'indexed_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
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
  Stream<RealmObjectChanges<WithIndexes>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<WithIndexes>(this, keyPaths);

  @override
  WithIndexes freeze() => RealmObjectBase.freezeObject<WithIndexes>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'anInt': anInt.toEJson(),
      'aBool': aBool.toEJson(),
      'string': string.toEJson(),
      'timestamp': timestamp.toEJson(),
      'objectId': objectId.toEJson(),
      'uuid': uuid.toEJson(),
    };
  }

  static EJsonValue _toEJson(WithIndexes value) => value.toEJson();
  static WithIndexes _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
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
    register(_toEJson, _fromEJson);
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

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<NoIndexes>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<NoIndexes>(this, keyPaths);

  @override
  NoIndexes freeze() => RealmObjectBase.freezeObject<NoIndexes>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'anInt': anInt.toEJson(),
      'aBool': aBool.toEJson(),
      'string': string.toEJson(),
      'timestamp': timestamp.toEJson(),
      'objectId': objectId.toEJson(),
      'uuid': uuid.toEJson(),
    };
  }

  static EJsonValue _toEJson(NoIndexes value) => value.toEJson();
  static NoIndexes _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
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
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, NoIndexes, 'NoIndexes', [
      SchemaProperty('anInt', RealmPropertyType.int),
      SchemaProperty('aBool', RealmPropertyType.bool),
      SchemaProperty('string', RealmPropertyType.string),
      SchemaProperty('timestamp', RealmPropertyType.timestamp),
      SchemaProperty('objectId', RealmPropertyType.objectid),
      SchemaProperty('uuid', RealmPropertyType.uuid),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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
  Stream<RealmObjectChanges<ObjectWithFTSIndex>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ObjectWithFTSIndex>(this, keyPaths);

  @override
  ObjectWithFTSIndex freeze() =>
      RealmObjectBase.freezeObject<ObjectWithFTSIndex>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'title': title.toEJson(),
      'summary': summary.toEJson(),
      'nullableSummary': nullableSummary.toEJson(),
    };
  }

  static EJsonValue _toEJson(ObjectWithFTSIndex value) => value.toEJson();
  static ObjectWithFTSIndex _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'title': EJsonValue title,
        'summary': EJsonValue summary,
      } =>
        ObjectWithFTSIndex(
          fromEJson(title),
          fromEJson(summary),
          nullableSummary: fromEJson(ejson['nullableSummary']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ObjectWithFTSIndex._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ObjectWithFTSIndex, 'ObjectWithFTSIndex', [
      SchemaProperty('title', RealmPropertyType.string),
      SchemaProperty('summary', RealmPropertyType.string,
          indexType: RealmIndexType.fullText),
      SchemaProperty('nullableSummary', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.fullText),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
