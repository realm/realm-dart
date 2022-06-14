// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_or_update_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Friend extends _Friend with RealmEntity, RealmObject {
  Friend(
    int id, {
    Friend? bestFriend,
    Iterable<Friend> friends = const [],
  }) {
    RealmObject.set(this, 'id', id);
    RealmObject.set(this, 'bestFriend', bestFriend);
    RealmObject.set<RealmList<Friend>>(
        this, 'friends', RealmList<Friend>(friends));
  }

  Friend._();

  @override
  int get id => RealmObject.get<int>(this, 'id') as int;
  @override
  set id(int value) => throw RealmUnsupportedSetError();

  @override
  Friend? get bestFriend =>
      RealmObject.get<Friend>(this, 'bestFriend') as Friend?;
  @override
  set bestFriend(covariant Friend? value) =>
      RealmObject.set(this, 'bestFriend', value);

  @override
  RealmList<Friend> get friends =>
      RealmObject.get<Friend>(this, 'friends') as RealmList<Friend>;
  @override
  set friends(covariant RealmList<Friend> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Friend>> get changes =>
      RealmObject.getChanges<Friend>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Friend._);
    return const SchemaObject(Friend, 'Friend', [
      SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('bestFriend', RealmPropertyType.object,
          optional: true, linkTarget: 'Friend'),
      SchemaProperty('friends', RealmPropertyType.object,
          linkTarget: 'Friend', collectionType: RealmCollectionType.list),
    ]);
  }
}
