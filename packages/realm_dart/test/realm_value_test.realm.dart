// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_value_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class TuckedIn extends _TuckedIn
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  static var _defaultsSet = false;

  TuckedIn({
    int x = 42,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<TuckedIn>({
        'x': 42,
      });
    }
    RealmObjectBase.set(this, 'x', x);
  }

  TuckedIn._();

  @override
  int get x => RealmObjectBase.get<int>(this, 'x') as int;
  @override
  set x(int value) => RealmObjectBase.set(this, 'x', value);

  @override
  Stream<RealmObjectChanges<TuckedIn>> get changes =>
      RealmObjectBase.getChanges<TuckedIn>(this);

  @override
  Stream<RealmObjectChanges<TuckedIn>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<TuckedIn>(this, keyPaths);

  @override
  TuckedIn freeze() => RealmObjectBase.freezeObject<TuckedIn>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'x': x.toEJson(),
    };
  }

  static EJsonValue _toEJson(TuckedIn value) => value.toEJson();
  static TuckedIn _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return TuckedIn(
      x: fromEJson(ejson['x'], defaultValue: 42),
    );
  }

  static final schema = () {
    RealmObjectBase.registerFactory(TuckedIn._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.embeddedObject, TuckedIn, 'TuckedIn', [
      SchemaProperty('x', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
