// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backlinks_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Source extends _Source with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Source({
    String name = 'source',
    Target? oneTarget,
    Target? dynamicTarget,
    Iterable<Target> manyTargets = const [],
    Iterable<Target> dynamicManyTargets = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Source>({
        'name': 'source',
      });
    }
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'et mål', oneTarget);
    RealmObjectBase.set(this, 'dynamisk mål', dynamicTarget);
    RealmObjectBase.set<RealmList<Target>>(
        this, 'manyTargets', RealmList<Target>(manyTargets));
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
  Source freeze() => RealmObjectBase.freezeObject<Source>(this);

  static EJsonValue _encodeSource(Source value) {
    return <String, dynamic>{
      'name': toEJson(value.name),
      'et mål': toEJson(value.oneTarget),
      'manyTargets': toEJson(value.manyTargets),
      'dynamisk mål': toEJson(value.dynamicTarget),
      'dynamicManyTargets': toEJson(value.dynamicManyTargets),
    };
  }

  static Source _decodeSource(EJsonValue ejson) {
    return switch (ejson) {
      {
        'name': EJsonValue name,
        'et mål': EJsonValue oneTarget,
        'manyTargets': EJsonValue manyTargets,
        'dynamisk mål': EJsonValue dynamicTarget,
        'dynamicManyTargets': EJsonValue dynamicManyTargets,
      } =>
        Source(
          name: fromEJson(name),
          oneTarget: fromEJson(oneTarget),
          dynamicTarget: fromEJson(dynamicTarget),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Source._);
    register(_encodeSource, _decodeSource);
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
  Target freeze() => RealmObjectBase.freezeObject<Target>(this);

  static EJsonValue _encodeTarget(Target value) {
    return <String, dynamic>{
      'name': toEJson(value.name),
      'source': toEJson(value.source),
      'oneToMany': toEJson(value.oneToMany),
      'manyToMany': toEJson(value.manyToMany),
    };
  }

  static Target _decodeTarget(EJsonValue ejson) {
    return switch (ejson) {
      {
        'name': EJsonValue name,
        'source': EJsonValue source,
        'oneToMany': EJsonValue oneToMany,
        'manyToMany': EJsonValue manyToMany,
      } =>
        Target(
          name: fromEJson(name),
          source: fromEJson(source),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Target._);
    register(_encodeTarget, _decodeTarget);
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
}
