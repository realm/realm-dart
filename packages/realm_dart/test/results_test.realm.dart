// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'results_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class TestNotificationObject extends _TestNotificationObject
    with RealmEntity, RealmObjectBase, RealmObject {
  TestNotificationObject({
    String? stringProperty,
    int? intProperty,
    int? remappedIntProperty,
    TestNotificationObject? link,
    Iterable<TestNotificationObject> list = const [],
    Set<TestNotificationObject> set = const {},
    Map<String, TestNotificationObject?> map = const {},
    TestNotificationDifferentType? linkDifferentType,
    Iterable<TestNotificationDifferentType> listDifferentType = const [],
    Set<TestNotificationDifferentType> setDifferentType = const {},
    Map<String, TestNotificationDifferentType?> mapDifferentType = const {},
    TestNotificationEmbeddedObject? embedded,
  }) {
    RealmObjectBase.set(this, 'stringProperty', stringProperty);
    RealmObjectBase.set(this, 'intProperty', intProperty);
    RealmObjectBase.set(this, '_remappedIntProperty', remappedIntProperty);
    RealmObjectBase.set(this, 'link', link);
    RealmObjectBase.set<RealmList<TestNotificationObject>>(
        this, 'list', RealmList<TestNotificationObject>(list));
    RealmObjectBase.set<RealmSet<TestNotificationObject>>(
        this, 'set', RealmSet<TestNotificationObject>(set));
    RealmObjectBase.set<RealmMap<TestNotificationObject?>>(
        this, 'map', RealmMap<TestNotificationObject?>(map));
    RealmObjectBase.set(this, 'linkDifferentType', linkDifferentType);
    RealmObjectBase.set<RealmList<TestNotificationDifferentType>>(
        this,
        'listDifferentType',
        RealmList<TestNotificationDifferentType>(listDifferentType));
    RealmObjectBase.set<RealmSet<TestNotificationDifferentType>>(
        this,
        'setDifferentType',
        RealmSet<TestNotificationDifferentType>(setDifferentType));
    RealmObjectBase.set<RealmMap<TestNotificationDifferentType?>>(
        this,
        'mapDifferentType',
        RealmMap<TestNotificationDifferentType?>(mapDifferentType));
    RealmObjectBase.set(this, 'embedded', embedded);
  }

  TestNotificationObject._();

  @override
  String? get stringProperty =>
      RealmObjectBase.get<String>(this, 'stringProperty') as String?;
  @override
  set stringProperty(String? value) =>
      RealmObjectBase.set(this, 'stringProperty', value);

  @override
  int? get intProperty => RealmObjectBase.get<int>(this, 'intProperty') as int?;
  @override
  set intProperty(int? value) =>
      RealmObjectBase.set(this, 'intProperty', value);

  @override
  int? get remappedIntProperty =>
      RealmObjectBase.get<int>(this, '_remappedIntProperty') as int?;
  @override
  set remappedIntProperty(int? value) =>
      RealmObjectBase.set(this, '_remappedIntProperty', value);

  @override
  TestNotificationObject? get link =>
      RealmObjectBase.get<TestNotificationObject>(this, 'link')
          as TestNotificationObject?;
  @override
  set link(covariant TestNotificationObject? value) =>
      RealmObjectBase.set(this, 'link', value);

  @override
  RealmList<TestNotificationObject> get list =>
      RealmObjectBase.get<TestNotificationObject>(this, 'list')
          as RealmList<TestNotificationObject>;
  @override
  set list(covariant RealmList<TestNotificationObject> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<TestNotificationObject> get set =>
      RealmObjectBase.get<TestNotificationObject>(this, 'set')
          as RealmSet<TestNotificationObject>;
  @override
  set set(covariant RealmSet<TestNotificationObject> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<TestNotificationObject?> get map =>
      RealmObjectBase.get<TestNotificationObject?>(this, 'map')
          as RealmMap<TestNotificationObject?>;
  @override
  set map(covariant RealmMap<TestNotificationObject?> value) =>
      throw RealmUnsupportedSetError();

  @override
  TestNotificationDifferentType? get linkDifferentType =>
      RealmObjectBase.get<TestNotificationDifferentType>(
          this, 'linkDifferentType') as TestNotificationDifferentType?;
  @override
  set linkDifferentType(covariant TestNotificationDifferentType? value) =>
      RealmObjectBase.set(this, 'linkDifferentType', value);

  @override
  RealmList<TestNotificationDifferentType> get listDifferentType =>
      RealmObjectBase.get<TestNotificationDifferentType>(
              this, 'listDifferentType')
          as RealmList<TestNotificationDifferentType>;
  @override
  set listDifferentType(
          covariant RealmList<TestNotificationDifferentType> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmSet<TestNotificationDifferentType> get setDifferentType =>
      RealmObjectBase.get<TestNotificationDifferentType>(
          this, 'setDifferentType') as RealmSet<TestNotificationDifferentType>;
  @override
  set setDifferentType(
          covariant RealmSet<TestNotificationDifferentType> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmMap<TestNotificationDifferentType?> get mapDifferentType =>
      RealmObjectBase.get<TestNotificationDifferentType?>(
          this, 'mapDifferentType') as RealmMap<TestNotificationDifferentType?>;
  @override
  set mapDifferentType(
          covariant RealmMap<TestNotificationDifferentType?> value) =>
      throw RealmUnsupportedSetError();

  @override
  TestNotificationEmbeddedObject? get embedded =>
      RealmObjectBase.get<TestNotificationEmbeddedObject>(this, 'embedded')
          as TestNotificationEmbeddedObject?;
  @override
  set embedded(covariant TestNotificationEmbeddedObject? value) =>
      RealmObjectBase.set(this, 'embedded', value);

  @override
  RealmResults<TestNotificationObject> get backlink {
    if (!isManaged) {
      throw RealmError('Using backlinks is only possible for managed objects.');
    }
    return RealmObjectBase.get<TestNotificationObject>(this, 'backlink')
        as RealmResults<TestNotificationObject>;
  }

  @override
  set backlink(covariant RealmResults<TestNotificationObject> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<TestNotificationObject>> get changes =>
      RealmObjectBase.getChanges<TestNotificationObject>(this);

  @override
  Stream<RealmObjectChanges<TestNotificationObject>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<TestNotificationObject>(this, keyPaths);

  @override
  TestNotificationObject freeze() =>
      RealmObjectBase.freezeObject<TestNotificationObject>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'stringProperty': stringProperty.toEJson(),
      'intProperty': intProperty.toEJson(),
      '_remappedIntProperty': remappedIntProperty.toEJson(),
      'link': link.toEJson(),
      'list': list.toEJson(),
      'set': set.toEJson(),
      'map': map.toEJson(),
      'linkDifferentType': linkDifferentType.toEJson(),
      'listDifferentType': listDifferentType.toEJson(),
      'setDifferentType': setDifferentType.toEJson(),
      'mapDifferentType': mapDifferentType.toEJson(),
      'embedded': embedded.toEJson(),
    };
  }

  static EJsonValue _toEJson(TestNotificationObject value) => value.toEJson();
  static TestNotificationObject _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return TestNotificationObject(
      stringProperty: fromEJson(ejson['stringProperty']),
      intProperty: fromEJson(ejson['intProperty']),
      remappedIntProperty: fromEJson(ejson['_remappedIntProperty']),
      link: fromEJson(ejson['link']),
      list: fromEJson(ejson['list']),
      set: fromEJson(ejson['set']),
      map: fromEJson(ejson['map']),
      linkDifferentType: fromEJson(ejson['linkDifferentType']),
      listDifferentType: fromEJson(ejson['listDifferentType']),
      setDifferentType: fromEJson(ejson['setDifferentType']),
      mapDifferentType: fromEJson(ejson['mapDifferentType']),
      embedded: fromEJson(ejson['embedded']),
    );
  }

  static final schema = () {
    RealmObjectBase.registerFactory(TestNotificationObject._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, TestNotificationObject,
        'TestNotificationObject', [
      SchemaProperty('stringProperty', RealmPropertyType.string,
          optional: true),
      SchemaProperty('intProperty', RealmPropertyType.int, optional: true),
      SchemaProperty('remappedIntProperty', RealmPropertyType.int,
          mapTo: '_remappedIntProperty', optional: true),
      SchemaProperty('link', RealmPropertyType.object,
          optional: true, linkTarget: 'TestNotificationObject'),
      SchemaProperty('list', RealmPropertyType.object,
          linkTarget: 'TestNotificationObject',
          collectionType: RealmCollectionType.list),
      SchemaProperty('set', RealmPropertyType.object,
          linkTarget: 'TestNotificationObject',
          collectionType: RealmCollectionType.set),
      SchemaProperty('map', RealmPropertyType.object,
          optional: true,
          linkTarget: 'TestNotificationObject',
          collectionType: RealmCollectionType.map),
      SchemaProperty('linkDifferentType', RealmPropertyType.object,
          optional: true, linkTarget: 'TestNotificationDifferentType'),
      SchemaProperty('listDifferentType', RealmPropertyType.object,
          linkTarget: 'TestNotificationDifferentType',
          collectionType: RealmCollectionType.list),
      SchemaProperty('setDifferentType', RealmPropertyType.object,
          linkTarget: 'TestNotificationDifferentType',
          collectionType: RealmCollectionType.set),
      SchemaProperty('mapDifferentType', RealmPropertyType.object,
          optional: true,
          linkTarget: 'TestNotificationDifferentType',
          collectionType: RealmCollectionType.map),
      SchemaProperty('embedded', RealmPropertyType.object,
          optional: true, linkTarget: 'TestNotificationEmbeddedObject'),
      SchemaProperty('backlink', RealmPropertyType.linkingObjects,
          linkOriginProperty: 'link',
          collectionType: RealmCollectionType.list,
          linkTarget: 'TestNotificationObject'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class TestNotificationEmbeddedObject extends _TestNotificationEmbeddedObject
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  TestNotificationEmbeddedObject({
    String? stringProperty,
    int? intProperty,
  }) {
    RealmObjectBase.set(this, 'stringProperty', stringProperty);
    RealmObjectBase.set(this, 'intProperty', intProperty);
  }

  TestNotificationEmbeddedObject._();

  @override
  String? get stringProperty =>
      RealmObjectBase.get<String>(this, 'stringProperty') as String?;
  @override
  set stringProperty(String? value) =>
      RealmObjectBase.set(this, 'stringProperty', value);

  @override
  int? get intProperty => RealmObjectBase.get<int>(this, 'intProperty') as int?;
  @override
  set intProperty(int? value) =>
      RealmObjectBase.set(this, 'intProperty', value);

  @override
  Stream<RealmObjectChanges<TestNotificationEmbeddedObject>> get changes =>
      RealmObjectBase.getChanges<TestNotificationEmbeddedObject>(this);

  @override
  Stream<RealmObjectChanges<TestNotificationEmbeddedObject>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<TestNotificationEmbeddedObject>(
          this, keyPaths);

  @override
  TestNotificationEmbeddedObject freeze() =>
      RealmObjectBase.freezeObject<TestNotificationEmbeddedObject>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'stringProperty': stringProperty.toEJson(),
      'intProperty': intProperty.toEJson(),
    };
  }

  static EJsonValue _toEJson(TestNotificationEmbeddedObject value) =>
      value.toEJson();
  static TestNotificationEmbeddedObject _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return TestNotificationEmbeddedObject(
      stringProperty: fromEJson(ejson['stringProperty']),
      intProperty: fromEJson(ejson['intProperty']),
    );
  }

  static final schema = () {
    RealmObjectBase.registerFactory(TestNotificationEmbeddedObject._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.embeddedObject,
        TestNotificationEmbeddedObject, 'TestNotificationEmbeddedObject', [
      SchemaProperty('stringProperty', RealmPropertyType.string,
          optional: true),
      SchemaProperty('intProperty', RealmPropertyType.int, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class TestNotificationDifferentType extends _TestNotificationDifferentType
    with RealmEntity, RealmObjectBase, RealmObject {
  TestNotificationDifferentType({
    String? stringProperty,
    int? intProperty,
    TestNotificationDifferentType? link,
  }) {
    RealmObjectBase.set(this, 'stringProperty', stringProperty);
    RealmObjectBase.set(this, 'intProperty', intProperty);
    RealmObjectBase.set(this, 'link', link);
  }

  TestNotificationDifferentType._();

  @override
  String? get stringProperty =>
      RealmObjectBase.get<String>(this, 'stringProperty') as String?;
  @override
  set stringProperty(String? value) =>
      RealmObjectBase.set(this, 'stringProperty', value);

  @override
  int? get intProperty => RealmObjectBase.get<int>(this, 'intProperty') as int?;
  @override
  set intProperty(int? value) =>
      RealmObjectBase.set(this, 'intProperty', value);

  @override
  TestNotificationDifferentType? get link =>
      RealmObjectBase.get<TestNotificationDifferentType>(this, 'link')
          as TestNotificationDifferentType?;
  @override
  set link(covariant TestNotificationDifferentType? value) =>
      RealmObjectBase.set(this, 'link', value);

  @override
  Stream<RealmObjectChanges<TestNotificationDifferentType>> get changes =>
      RealmObjectBase.getChanges<TestNotificationDifferentType>(this);

  @override
  Stream<RealmObjectChanges<TestNotificationDifferentType>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<TestNotificationDifferentType>(
          this, keyPaths);

  @override
  TestNotificationDifferentType freeze() =>
      RealmObjectBase.freezeObject<TestNotificationDifferentType>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'stringProperty': stringProperty.toEJson(),
      'intProperty': intProperty.toEJson(),
      'link': link.toEJson(),
    };
  }

  static EJsonValue _toEJson(TestNotificationDifferentType value) =>
      value.toEJson();
  static TestNotificationDifferentType _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return TestNotificationDifferentType(
      stringProperty: fromEJson(ejson['stringProperty']),
      intProperty: fromEJson(ejson['intProperty']),
      link: fromEJson(ejson['link']),
    );
  }

  static final schema = () {
    RealmObjectBase.registerFactory(TestNotificationDifferentType._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject,
        TestNotificationDifferentType, 'TestNotificationDifferentType', [
      SchemaProperty('stringProperty', RealmPropertyType.string,
          optional: true),
      SchemaProperty('intProperty', RealmPropertyType.int, optional: true),
      SchemaProperty('link', RealmPropertyType.object,
          optional: true, linkTarget: 'TestNotificationDifferentType'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
