// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_or_update_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Friend extends _Friend with RealmEntity, RealmObject {
  Friend(
    int id, {
    Friend? friend,
  }) {
    RealmObject.set(this, 'id', id);
    RealmObject.set(this, 'friend', friend);
  }

  Friend._();

  @override
  int get id => RealmObject.get<int>(this, 'id') as int;
  @override
  set id(int value) => throw RealmUnsupportedSetError();

  @override
  Friend? get friend => RealmObject.get<Friend>(this, 'friend') as Friend?;
  @override
  set friend(covariant Friend? value) => RealmObject.set(this, 'friend', value);

  @override
  Stream<RealmObjectChanges<Friend>> get changes =>
      RealmObject.getChanges<Friend>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Friend._);
    return const SchemaObject(Friend, 'Friend', [
      SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('friend', RealmPropertyType.object,
          optional: true, linkTarget: 'Friend'),
    ]);
  }
}
