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
    Iterable<Target> manyTargets = const [],
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
  Stream<RealmObjectChanges<Source>> get changes =>
      RealmObjectBase.getChanges<Source>(this);

  @override
  Source freeze() => RealmObjectBase.freezeObject<Source>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Source._);
    return const SchemaObject(ObjectType.realmObject, Source, 'Source', [
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('oneTarget', RealmPropertyType.object,
          mapTo: 'et mål', optional: true, linkTarget: 'Target'),
      SchemaProperty('manyTargets', RealmPropertyType.object,
          linkTarget: 'Target', collectionType: RealmCollectionType.list),
    ]);
  }
}

// ignore_for_file: type=lint
class Target extends _Target with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Target({
    String name = 'target',
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Target>({
        'name': 'target',
      });
    }
    RealmObjectBase.set(this, 'name', name);
  }

  Target._();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

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

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Target._);
    return const SchemaObject(ObjectType.realmObject, Target, 'Target', [
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('oneToMany', RealmPropertyType.linkingObjects,
          linkOriginProperty: 'et mål',
          collectionType: RealmCollectionType.list,
          linkTarget: 'Source'),
      SchemaProperty('manyToMany', RealmPropertyType.linkingObjects,
          linkOriginProperty: 'manyTargets',
          collectionType: RealmCollectionType.list,
          linkTarget: 'Source'),
    ]);
  }
}
