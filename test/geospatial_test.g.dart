// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geospatial_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Location extends _Location
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  static var _defaultsSet = false;

  Location({
    String type = 'Point',
    Iterable<double> coordinates = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Location>({
        'type': 'Point',
      });
    }
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set<RealmList<double>>(
        this, 'coordinates', RealmList<double>(coordinates));
  }

  Location._();

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;

  @override
  RealmList<double> get coordinates =>
      RealmObjectBase.get<double>(this, 'coordinates') as RealmList<double>;
  @override
  set coordinates(covariant RealmList<double> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Location>> get changes =>
      RealmObjectBase.getChanges<Location>(this);

  @override
  Location freeze() => RealmObjectBase.freezeObject<Location>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Location._);
    return const SchemaObject(ObjectType.embeddedObject, Location, 'Location', [
      SchemaProperty('type', RealmPropertyType.string),
      SchemaProperty('coordinates', RealmPropertyType.double,
          collectionType: RealmCollectionType.list),
    ]);
  }
}

class Restaurant extends _Restaurant
    with RealmEntity, RealmObjectBase, RealmObject {
  Restaurant(
    String name, {
    Location? location,
  }) {
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'location', location);
  }

  Restaurant._();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  Location? get location =>
      RealmObjectBase.get<Location>(this, 'location') as Location?;
  @override
  set location(covariant Location? value) =>
      RealmObjectBase.set(this, 'location', value);

  @override
  Stream<RealmObjectChanges<Restaurant>> get changes =>
      RealmObjectBase.getChanges<Restaurant>(this);

  @override
  Restaurant freeze() => RealmObjectBase.freezeObject<Restaurant>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Restaurant._);
    return const SchemaObject(
        ObjectType.realmObject, Restaurant, 'Restaurant', [
      SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('location', RealmPropertyType.object,
          optional: true, linkTarget: 'Location'),
    ]);
  }
}
