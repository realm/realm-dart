// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backlinks_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Source extends _Source with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Source({
    String name = 'source',
    Target? oneTarget,
    Iterable<Target> manyTargets = const [],
    Target? dynamicTarget,
    Iterable<Target> dynamicManyTargets = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Source>({
        'name': 'source',
      });
    }
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'et mål', oneTarget);
    RealmObjectBase.set<RealmList<Target>>(
        this, 'manyTargets', RealmList<Target>(manyTargets));
    RealmObjectBase.set(this, 'dynamisk mål', dynamicTarget);
    RealmObjectBase.set<RealmList<Target>>(
        this, 'dynamicManyTargets', RealmList<Target>(dynamicManyTargets));
  }

  Source._();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  Target? get oneTarget =>
      RealmObjectBase.get<Target>(this, 'et mål') as Target?;
  @override
  set oneTarget(covariant Target? value) =>
      RealmObjectBase.set(this, 'et mål', value);

  @override
  RealmList<Target> get manyTargets =>
      RealmObjectBase.get<Target>(this, 'manyTargets') as RealmList<Target>;
  @override
  set manyTargets(covariant RealmList<Target> value) =>
      throw RealmUnsupportedSetError();

  @override
  Target? get dynamicTarget =>
      RealmObjectBase.get<Target>(this, 'dynamisk mål') as Target?;
  @override
  set dynamicTarget(covariant Target? value) =>
      RealmObjectBase.set(this, 'dynamisk mål', value);

  @override
  RealmList<Target> get dynamicManyTargets =>
      RealmObjectBase.get<Target>(this, 'dynamicManyTargets')
          as RealmList<Target>;
  @override
  set dynamicManyTargets(covariant RealmList<Target> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Source>> get changes =>
      RealmObjectBase.getChanges<Source>(this);

  @override
  Stream<RealmObjectChanges<Source>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Source>(this, keyPaths);

  @override
  Source freeze() => RealmObjectBase.freezeObject<Source>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'name': name.toEJson(),
      'et mål': oneTarget.toEJson(),
      'manyTargets': manyTargets.toEJson(),
      'dynamisk mål': dynamicTarget.toEJson(),
      'dynamicManyTargets': dynamicManyTargets.toEJson(),
    };
  }

  static EJsonValue _toEJson(Source value) => value.toEJson();
  static Source _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return Source(
      name: fromEJson(ejson['name'], defaultValue: 'source'),
      oneTarget: fromEJson(ejson['et mål']),
      manyTargets: fromEJson(ejson['manyTargets']),
      dynamicTarget: fromEJson(ejson['dynamisk mål']),
      dynamicManyTargets: fromEJson(ejson['dynamicManyTargets']),
    );
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Source._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Source, 'Source', [
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('oneTarget', RealmPropertyType.object,
          mapTo: 'et mål', optional: true, linkTarget: 'Target'),
      SchemaProperty('manyTargets', RealmPropertyType.object,
          linkTarget: 'Target', collectionType: RealmCollectionType.list),
      SchemaProperty('dynamicTarget', RealmPropertyType.object,
          mapTo: 'dynamisk mål', optional: true, linkTarget: 'Target'),
      SchemaProperty('dynamicManyTargets', RealmPropertyType.object,
          linkTarget: 'Target', collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Target extends _Target with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Target({
    String name = 'target',
    Source? source,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Target>({
        'name': 'target',
      });
    }
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'source', source);
  }

  Target._();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  Source? get source => RealmObjectBase.get<Source>(this, 'source') as Source?;
  @override
  set source(covariant Source? value) =>
      RealmObjectBase.set(this, 'source', value);

  @override
  RealmResults<Source> get oneToMany {
    if (!isManaged) {
      throw RealmError('Using backlinks is only possible for managed objects.');
    }
    return RealmObjectBase.get<Source>(this, 'oneToMany')
        as RealmResults<Source>;
  }

  @override
  set oneToMany(covariant RealmResults<Source> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmResults<Source> get manyToMany {
    if (!isManaged) {
      throw RealmError('Using backlinks is only possible for managed objects.');
    }
    return RealmObjectBase.get<Source>(this, 'manyToMany')
        as RealmResults<Source>;
  }

  @override
  set manyToMany(covariant RealmResults<Source> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Target>> get changes =>
      RealmObjectBase.getChanges<Target>(this);

  @override
  Stream<RealmObjectChanges<Target>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Target>(this, keyPaths);

  @override
  Target freeze() => RealmObjectBase.freezeObject<Target>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'name': name.toEJson(),
      'source': source.toEJson(),
    };
  }

  static EJsonValue _toEJson(Target value) => value.toEJson();
  static Target _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return Target(
      name: fromEJson(ejson['name'], defaultValue: 'target'),
      source: fromEJson(ejson['source']),
    );
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Target._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Target, 'Target', [
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('source', RealmPropertyType.object,
          optional: true, linkTarget: 'Source'),
      SchemaProperty('oneToMany', RealmPropertyType.linkingObjects,
          linkOriginProperty: 'et mål',
          collectionType: RealmCollectionType.list,
          linkTarget: 'Source'),
      SchemaProperty('manyToMany', RealmPropertyType.linkingObjects,
          linkOriginProperty: 'manyTargets',
          collectionType: RealmCollectionType.list,
          linkTarget: 'Source'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
