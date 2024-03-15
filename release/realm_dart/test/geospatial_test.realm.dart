// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geospatial_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
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

  EJsonValue toEJson() {
    return <String, dynamic>{
      'type': type.toEJson(),
      'coordinates': coordinates.toEJson(),
    };
  }

  static EJsonValue _toEJson(Location value) => value.toEJson();
  static Location _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'type': EJsonValue type,
        'coordinates': EJsonValue coordinates,
      } =>
        Location(
          type: fromEJson(type),
          coordinates: fromEJson(coordinates),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Location._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.embeddedObject, Location, 'Location', [
      SchemaProperty('type', RealmPropertyType.string),
      SchemaProperty('coordinates', RealmPropertyType.double,
          collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
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

  EJsonValue toEJson() {
    return <String, dynamic>{
      'name': name.toEJson(),
      'location': location.toEJson(),
    };
  }

  static EJsonValue _toEJson(Restaurant value) => value.toEJson();
  static Restaurant _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'name': EJsonValue name,
        'location': EJsonValue location,
      } =>
        Restaurant(
          fromEJson(name),
          location: fromEJson(location),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Restaurant._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.realmObject, Restaurant, 'Restaurant', [
      SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('location', RealmPropertyType.object,
          optional: true, linkTarget: 'Location'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class LocationList extends _LocationList
    with RealmEntity, RealmObjectBase, RealmObject {
  LocationList({
    Iterable<Location> locations = const [],
  }) {
    RealmObjectBase.set<RealmList<Location>>(
        this, 'locations', RealmList<Location>(locations));
  }

  LocationList._();

  @override
  RealmList<Location> get locations =>
      RealmObjectBase.get<Location>(this, 'locations') as RealmList<Location>;
  @override
  set locations(covariant RealmList<Location> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<LocationList>> get changes =>
      RealmObjectBase.getChanges<LocationList>(this);

  @override
  LocationList freeze() => RealmObjectBase.freezeObject<LocationList>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'locations': locations.toEJson(),
    };
  }

  static EJsonValue _toEJson(LocationList value) => value.toEJson();
  static LocationList _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'locations': EJsonValue locations,
      } =>
        LocationList(
          locations: fromEJson(locations),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(LocationList._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.realmObject, LocationList, 'LocationList', [
      SchemaProperty('locations', RealmPropertyType.object,
          linkTarget: 'Location', collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
