// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuration_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class LinkToClassInAnotherFile extends _LinkToClassInAnotherFile
    with RealmEntity, RealmObjectBase, RealmObject {
  LinkToClassInAnotherFile({
    Iterable<RemappedClass> listProperty = const [],
  }) {
    RealmObjectBase.set<RealmList<RemappedClass>>(
        this, 'listProperty', RealmList<RemappedClass>(listProperty));
  }

  LinkToClassInAnotherFile._();

  @override
  RealmList<RemappedClass> get listProperty =>
      RealmObjectBase.get<RemappedClass>(this, 'listProperty')
          as RealmList<RemappedClass>;
  @override
  set listProperty(covariant RealmList<RemappedClass> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<LinkToClassInAnotherFile>> get changes =>
      RealmObjectBase.getChanges<LinkToClassInAnotherFile>(this);

  @override
  LinkToClassInAnotherFile freeze() =>
      RealmObjectBase.freezeObject<LinkToClassInAnotherFile>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(LinkToClassInAnotherFile._);
    return SchemaObject(ObjectType.realmObject, LinkToClassInAnotherFile,
        'LinkToClassInAnotherFile', [
      SchemaProperty('listProperty', RealmPropertyType.object,
          linkTarget: 'myRemappedClass',
          linkTargetSchema: () => RemappedClass.schema,
          collectionType: RealmCollectionType.list),
    ]);
  }
}
