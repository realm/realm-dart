// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'baas_helper.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class BaasInfo extends _BaasInfo
    with RealmEntity, RealmObjectBase, RealmObject {
  BaasInfo(
    String baasUrl, {
    String? cluster,
    String? apiKey,
    String? privateApiKey,
    String? projectId,
    String? differentiator,
    Iterable<BaasAppDetails> apps = const [],
  }) {
    RealmObjectBase.set(this, 'baasUrl', baasUrl);
    RealmObjectBase.set(this, 'cluster', cluster);
    RealmObjectBase.set(this, 'apiKey', apiKey);
    RealmObjectBase.set(this, 'privateApiKey', privateApiKey);
    RealmObjectBase.set(this, 'projectId', projectId);
    RealmObjectBase.set(this, 'differentiator', differentiator);
    RealmObjectBase.set<RealmList<BaasAppDetails>>(
        this, 'apps', RealmList<BaasAppDetails>(apps));
  }

  BaasInfo._();

  @override
  String get baasUrl => RealmObjectBase.get<String>(this, 'baasUrl') as String;
  @override
  set baasUrl(String value) => RealmObjectBase.set(this, 'baasUrl', value);

  @override
  String? get cluster =>
      RealmObjectBase.get<String>(this, 'cluster') as String?;
  @override
  set cluster(String? value) => RealmObjectBase.set(this, 'cluster', value);

  @override
  String? get apiKey => RealmObjectBase.get<String>(this, 'apiKey') as String?;
  @override
  set apiKey(String? value) => RealmObjectBase.set(this, 'apiKey', value);

  @override
  String? get privateApiKey =>
      RealmObjectBase.get<String>(this, 'privateApiKey') as String?;
  @override
  set privateApiKey(String? value) =>
      RealmObjectBase.set(this, 'privateApiKey', value);

  @override
  String? get projectId =>
      RealmObjectBase.get<String>(this, 'projectId') as String?;
  @override
  set projectId(String? value) => RealmObjectBase.set(this, 'projectId', value);

  @override
  String? get differentiator =>
      RealmObjectBase.get<String>(this, 'differentiator') as String?;
  @override
  set differentiator(String? value) =>
      RealmObjectBase.set(this, 'differentiator', value);

  @override
  RealmList<BaasAppDetails> get apps =>
      RealmObjectBase.get<BaasAppDetails>(this, 'apps')
          as RealmList<BaasAppDetails>;
  @override
  set apps(covariant RealmList<BaasAppDetails> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<BaasInfo>> get changes =>
      RealmObjectBase.getChanges<BaasInfo>(this);

  @override
  BaasInfo freeze() => RealmObjectBase.freezeObject<BaasInfo>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(BaasInfo._);
    return const SchemaObject(ObjectType.realmObject, BaasInfo, 'BaasInfo', [
      SchemaProperty('baasUrl', RealmPropertyType.string),
      SchemaProperty('cluster', RealmPropertyType.string, optional: true),
      SchemaProperty('apiKey', RealmPropertyType.string, optional: true),
      SchemaProperty('privateApiKey', RealmPropertyType.string, optional: true),
      SchemaProperty('projectId', RealmPropertyType.string, optional: true),
      SchemaProperty('differentiator', RealmPropertyType.string,
          optional: true),
      SchemaProperty('apps', RealmPropertyType.object,
          linkTarget: 'BaasAppDetails',
          collectionType: RealmCollectionType.list),
    ]);
  }
}

// ignore_for_file: type=lint
class BaasAppDetails extends _BaasAppDetails
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  BaasAppDetails(
    String appId,
    String clientAppId,
    String name,
    String uniqueName, {
    String? error,
  }) {
    RealmObjectBase.set(this, 'appId', appId);
    RealmObjectBase.set(this, 'clientAppId', clientAppId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'uniqueName', uniqueName);
    RealmObjectBase.set(this, 'error', error);
  }

  BaasAppDetails._();

  @override
  String get appId => RealmObjectBase.get<String>(this, 'appId') as String;
  @override
  set appId(String value) => RealmObjectBase.set(this, 'appId', value);

  @override
  String get clientAppId =>
      RealmObjectBase.get<String>(this, 'clientAppId') as String;
  @override
  set clientAppId(String value) =>
      RealmObjectBase.set(this, 'clientAppId', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get uniqueName =>
      RealmObjectBase.get<String>(this, 'uniqueName') as String;
  @override
  set uniqueName(String value) =>
      RealmObjectBase.set(this, 'uniqueName', value);

  @override
  String? get error => RealmObjectBase.get<String>(this, 'error') as String?;
  @override
  set error(String? value) => RealmObjectBase.set(this, 'error', value);

  @override
  Stream<RealmObjectChanges<BaasAppDetails>> get changes =>
      RealmObjectBase.getChanges<BaasAppDetails>(this);

  @override
  BaasAppDetails freeze() => RealmObjectBase.freezeObject<BaasAppDetails>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(BaasAppDetails._);
    return const SchemaObject(
        ObjectType.embeddedObject, BaasAppDetails, 'BaasAppDetails', [
      SchemaProperty('appId', RealmPropertyType.string),
      SchemaProperty('clientAppId', RealmPropertyType.string),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('uniqueName', RealmPropertyType.string),
      SchemaProperty('error', RealmPropertyType.string, optional: true),
    ]);
  }
}
