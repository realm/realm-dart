// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:objectid/objectid.dart';
import 'package:sane_uuid/uuid.dart';

Type _typeOf<T>() => T;

/// @nodoc
class Mapping<T> {
  const Mapping({this.indexable = false, this.canBePrimaryKey = false});

  final bool indexable;
  final bool canBePrimaryKey;

  // Types
  Type get type => T;
  Type get nullableType => _typeOf<T?>();
}

const _intMapping = Mapping<int>(indexable: true, canBePrimaryKey: true);
const _boolMapping = Mapping<bool>(indexable: true);

/// All supported `Realm` property types.
/// {@category Configuration}
enum RealmPropertyType {
  int(_intMapping),
  bool(_boolMapping),
  string(Mapping<String>(indexable: true, canBePrimaryKey: true)),
  _3, // ignore: unused_field, constant_identifier_names
  binary,
  _5, // ignore: unused_field, constant_identifier_names
  mixed(Mapping<RealmValue>(indexable: true)),
  _7, // ignore: unused_field, constant_identifier_names
  timestamp(Mapping<DateTime>(indexable: true)),
  float,
  double,
  decimal128,
  object,
  _13, // ignore: unused_field, constant_identifier_names
  linkingObjects,
  objectid(Mapping<ObjectId>(indexable: true, canBePrimaryKey: true)),
  _16, // ignore: unused_field, constant_identifier_names
  uuid(Mapping<Uuid>(indexable: true, canBePrimaryKey: true));

  const RealmPropertyType([this.mapping = const Mapping<Never>()]);

  final Mapping<dynamic> mapping;
}

/// Describes the indexing mode for properties annotated with the @Indexed annotation.
enum RealmIndexType {
  /// Describes an index with no special capabilities. This type of index is
  /// suitable for equality searches as well as comparison operations for numeric values.
  regular,

  /// Describes a Full-Text index on a string property.
  ///
  /// The full-text index currently support this set of features:
  /// * Only token or word search, e.g. `query("bio TEXT \$0", "computer dancing")`
  ///   will find all objects that contains the words `computer` and `dancing` in their `bio` property
  /// * Tokens are diacritics- and case-insensitive, e.g. `query("bio TEXT \$0", "cafe dancing")`
  ///   and `query("bio TEXT \$0", "café DANCING")` will return the same set of matches.
  /// * Ignoring results with certain tokens is done using `-`, e.g. `query("bio TEXT \$0", "computer -dancing")`
  ///   will find all objects that contain `computer` but not `dancing`.
  /// * Tokens only consist of alphanumerical characters from ASCII and the Latin-1 supplement. All other characters
  ///   are considered whitespace. In particular words using `-` like `full-text` are split into two tokens.
  ///
  /// Note the following constraints before using full-text search:
  /// * Token prefix or suffix search like `query("bio TEXT \$0", "comp* *cing")` is not supported.
  /// * Only ASCII and Latin-1 alphanumerical chars are included in the index (most western languages).
  /// * Only boolean match is supported, i.e. "found" or "not found". It is not possible to sort results by "relevance".
  fullText
}

/// All supported `Realm` collection types.
/// {@category Configuration}
enum RealmCollectionType {
  none,
  list,
  set,
  _3, // ignore: unused_field, constant_identifier_names
  map;

  String get plural => switch (this) {
        RealmCollectionType.list => 'lists',
        RealmCollectionType.set => 'sets',
        RealmCollectionType.map => 'maps',
        _ => 'none',
      };
}

/// A base class of all Realm errors.
/// {@category Realm}
class RealmError extends Error {
  final String? message;
  RealmError(String this.message);

  @override
  String toString() => "Realm error : $message";
}

/// An error throw when operating on an object that has been closed.
/// {@category Realm}
class RealmClosedError extends RealmError {
  RealmClosedError(super.message);
}

/// Thrown if the operation is not supported.
/// {@category Realm}
class RealmUnsupportedSetError extends UnsupportedError implements RealmError {
  RealmUnsupportedSetError() : super('Cannot set late final field on realm object');
}

/// Thrown if the Realm operation is not allowed by the current state of the object.
class RealmStateError extends StateError implements RealmError {
  RealmStateError(super.message);
}

/// @nodoc
abstract class Decimal128 {}

/// @nodoc
abstract class RealmObjectBaseMarker {}

/// @nodoc
abstract class RealmObjectMarker implements RealmObjectBaseMarker {}

/// @nodoc
abstract class EmbeddedObjectMarker implements RealmObjectBaseMarker {}

/// An enum describing the possible types that can be wrapped inside [RealmValue]
enum RealmValueType {
  /// The [RealmValue] represents `null`
  nullValue,

  /// The [RealmValue] represents a [boolean] value
  boolean,

  /// The [RealmValue] represents a [String] value
  string,

  /// The [RealmValue] represents an [int] value
  int,

  /// The [RealmValue] represents a [double] value
  double,

  /// The [RealmValue] represents a `RealmObject` instance value
  object,

  /// The [RealmValue] represents an [ObjectId] value
  objectId,

  /// The [RealmValue] represents a [DateTime] value
  dateTime,

  /// The [RealmValue] represents a [Decimal128] value
  decimal,

  /// The [RealmValue] represents an [Uuid] value
  uuid,

  /// The [RealmValue] represents a binary ([Uint8List]) value
  binary,

  /// The [RealmValue] represents a `List<RealmValue>`
  list,

  /// The [RealmValue] represents a `Map<String, RealmValue>`
  map;

  /// Returns `true` if the enum value represents a collection - i.e. it's [list] or [map].
  bool get isCollection => this == RealmValueType.list || this == RealmValueType.map;
}

/// A type that can represent any valid realm data type, except embedded objects.
///
/// You can use [RealmValue] to declare fields on realm models, in which case it must be non-nullable,
/// but it can wrap a null-value. List of [RealmValue] (`List<RealmValue>`) are also legal.
///
/// [RealmValue] fields can be [Indexed]
///
/// ```dart
/// @RealmModel()
/// class _AnythingGoes {
///   @Indexed()
///   late RealmValue any;
///   late List<RealmValue> manyAny;
/// }
///
/// void main() {
///   final realm = Realm(Configuration.local([AnythingGoes.schema]));
///   realm.write(() {
///     final something = realm.add(AnythingGoes(any: RealmValue.string('text')));
///     something.manyAny.addAll([
///       null,
///       true,
///       'text',
///       42,
///       3.14,
///     ].map(RealmValue.from));
///   });
/// }
/// ```
class RealmValue {
  final Object? value;

  final RealmValueType type;

  /// Casts [value] to [T]. An exception will be thrown if the value is not convertible to [T].
  T as<T>() => value as T; // better for code completion

  // This is private, so user cannot accidentally construct an invalid instance
  const RealmValue._(this.value, this.type);

  const RealmValue.nullValue() : this._(null, RealmValueType.nullValue);
  const RealmValue.bool(bool b) : this._(b, RealmValueType.boolean);
  const RealmValue.string(String text) : this._(text, RealmValueType.string);
  const RealmValue.int(int i) : this._(i, RealmValueType.int);
  const RealmValue.double(double d) : this._(d, RealmValueType.double);
  // TODO: RealmObjectMarker introduced to avoid dependency inversion. It would be better if we could use RealmObject directly. https://github.com/realm/realm-dart/issues/701
  const RealmValue.realmObject(RealmObjectMarker o) : this._(o, RealmValueType.object);
  const RealmValue.dateTime(DateTime timestamp) : this._(timestamp, RealmValueType.dateTime);
  const RealmValue.objectId(ObjectId id) : this._(id, RealmValueType.objectId);
  const RealmValue.decimal128(Decimal128 decimal) : this._(decimal, RealmValueType.decimal);
  const RealmValue.uuid(Uuid uuid) : this._(uuid, RealmValueType.uuid);
  const RealmValue.binary(Uint8List binary) : this._(binary, RealmValueType.binary);
  const RealmValue.list(List<RealmValue> list) : this._(list, RealmValueType.list);
  const RealmValue.map(Map<String, RealmValue> map) : this._(map, RealmValueType.map);

  /// Constructs a RealmValue from an arbitrary object. Collections will be converted recursively as long
  /// as all their values are compatible.
  ///
  /// Throws [ArgumentError] if any of the values inside the graph cannot be stored in a [RealmValue].
  factory RealmValue.from(Object? object) {
    return switch (object) {
      null => RealmValue.nullValue(),
      bool b => RealmValue.bool(b),
      String text => RealmValue.string(text),
      int i => RealmValue.int(i),
      double d => RealmValue.double(d),
      RealmObjectMarker o => RealmValue.realmObject(o),
      DateTime d => RealmValue.dateTime(d),
      ObjectId id => RealmValue.objectId(id),
      Decimal128 decimal => RealmValue.decimal128(decimal),
      Uuid uuid => RealmValue.uuid(uuid),
      Uint8List binary => RealmValue.binary(binary),
      Map<String, RealmValue> d => RealmValue.map(d),
      Map<String, dynamic> d => RealmValue.map(d.map((key, value) => MapEntry(key, RealmValue.from(value)))),
      List<RealmValue> l => RealmValue.list(l),
      List<dynamic> l => RealmValue.list(l.map((o) => RealmValue.from(o)).toList()),
      Iterable<RealmValue> i => RealmValue.list(i.toList()),
      Iterable<dynamic> i => RealmValue.list(i.map((o) => RealmValue.from(o)).toList()),
      _ => throw ArgumentError.value(object.runtimeType, 'object', 'Unsupported type'),
    };
  }

  /// Constructs a RealmValue from a valid json string. The json object must contain only
  /// values that are supported by [RealmValue].
  ///
  /// Throws [FormatException] if the [json] argument is not valid json.
  factory RealmValue.fromJson(String json) {
    return RealmValue.from(jsonDecode(json));
  }

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;
    final v = value;
    if (other is RealmValue) {
      final ov = other.value;
      if (v is Uint8List && ov is Uint8List) return memEquals(v, ov); // special case binary data
      return type == other.type && v == ov;
    }
    return v == other; // asymmetric comparison for convenience
  }

  @override
  int get hashCode => Object.hash(type, value);

  @override
  String toString() => 'RealmValue($value)';
}

/// Compares two [Uint8List]s by comparing 8 bytes at a time.
bool memEquals(Uint8List x, Uint8List y) {
  if (identical(x, y)) return true;
  if (x.lengthInBytes != y.lengthInBytes) return false;

  var words = x.lengthInBytes ~/ 8; // number of full words
  var xW = x.buffer.asUint64List(0, words);
  var yW = y.buffer.asUint64List(0, words);

  // compare words
  for (var i = 0; i < xW.length; i += 1) {
    if (xW[i] != yW[i]) return false;
  }

  // compare remaining bytes
  for (var i = words * 8; i < x.lengthInBytes; i += 1) {
    if (x[i] != y[i]) return false;
  }

  return true; // no diff, they are equal
}

/// A base type for the supported geospatial shapes.
sealed class GeoShape {}

/// A point on the earth's surface.
///
/// It cannot be persisted as a property on a realm object.
///
/// Instead, you must use a custom embedded object with the following structure:
/// ```dart
/// @RealmModel(ObjectType.embeddedObject)
/// class _Location {
///   final String type = 'Point';
///   final List<double> coordinates = const [0, 0];
///
///   // The rest of the class is just convenience methods
///   double get lon => coordinates[0];
///   set lon(double value) => coordinates[0] = value;
///
///   double get lat => coordinates[1];
///   set lat(double value) => coordinates[1] = value;
///
///   GeoPoint toGeoPoint() => GeoPoint(lon: lon, lat: lat);
/// }
/// ```
/// You can then use it as a property on a realm object:
/// ```dart
/// @RealmModel()
/// class _Restaurant {
///   @PrimaryKey()
///   late String name;
///   _Location? location;
/// }
/// ```
/// For convenience add an extension method on [GeoPoint]:
/// ```dart
/// extension on GeoPoint {
///   Location toLocation() {
///     return Location(coordinates: [lon, lat]);
///   }
/// }
/// ```
/// to easily convert between [GeoPoint]s and `Location`s.
///
/// The following may also be useful:
/// ```dart
/// extension on (num, num) {
///   GeoPoint toGeoPoint() => GeoPoint(lon: $1.toDouble(), lat: $2.toDouble());
///   Location toLocation() => toGeoPoint().toLocation();
/// }
/// ```
final class GeoPoint implements GeoShape {
  final double lon;
  final double lat;

  /// Create a point from a [lon]gitude and [lat]gitude.
  /// [lon] must be between -180 and 180, and [lat] must be between -90 and 90.
  GeoPoint({required this.lon, required this.lat}) {
    if (lon < -180 || lon > 180) throw ArgumentError.value(lon, 'lon', 'must be between -180 and 180');
    if (lat < -90 || lat > 90) throw ArgumentError.value(lat, 'lat', 'must be between -90 and 90');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GeoPoint) return false;
    return lat == other.lat && lon == other.lon;
  }

  @override
  int get hashCode => Object.hash(lon, lat);

  @override
  String toString() => '[$lon, $lat]';
}

/// A box on the earth's surface.
///
/// This type can be used as the query argument for a `geoWithin` query.
/// It cannot be persisted as a property on a realm object.
final class GeoBox implements GeoShape {
  final GeoPoint southWest;
  final GeoPoint northEast;

  /// Create a box from a [southWest] and a [northEast] point
  const GeoBox(this.southWest, this.northEast);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GeoBox) return false;
    return southWest == other.southWest && northEast == other.northEast;
  }

  @override
  int get hashCode => Object.hash(southWest, northEast);

  @override
  String toString() => 'geoBox($southWest, $northEast)';
}

typedef GeoRing = List<GeoPoint>;

extension on GeoRing {
  void validate() {
    if (first != last) throw ArgumentError('Vertices must form a ring (first != last)');
    if (length < 4) throw ArgumentError('Ring must have at least 3 different vertices');
  }
}

/// A polygon on the earth's surface.
///
/// This type can be used as the query argument for a `geoWithin` query.
/// It cannot be persisted as a property on a realm object.
final class GeoPolygon implements GeoShape {
  final GeoRing outerRing;
  final List<GeoRing> holes;

  /// Create a polygon from an [outerRing] and a list of [holes]
  /// The outer ring must be a closed ring, and the holes must be non-overlapping
  /// closed rings inside the outer ring.
  GeoPolygon(this.outerRing, [this.holes = const []]) {
    outerRing.validate();
    for (final hole in holes) {
      hole.validate();
    }
  }

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GeoPolygon) return false;
    return outerRing == other.outerRing && holes == other.holes;
  }

  @override
  int get hashCode => Object.hash(outerRing, holes);

  @override
  String toString() {
    ringToString(GeoRing ring) => '{${ring.join(', ')}}';

    final outerRingString = ringToString(outerRing);
    if (holes.isEmpty) return 'geoPolygon($outerRingString)';

    final holesString = holes.map(ringToString).join(', ');
    return 'geoPolygon($outerRingString, $holesString)';
  }
}

const _metersPerMile = 1609.344;
const _radiansPerMeterOnEarthSphere = 1.5678502891116e-7; // at equator
const _radiansPerDegree = pi / 180;

/// An equatorial distance on earth's surface.
final class GeoDistance implements Comparable<GeoDistance> {
  /// The distance in radians
  final double radians;

  /// Create a distance from radians
  const GeoDistance(this.radians);

  /// Create a distance from [meters]
  GeoDistance.fromMeters(double meters) : radians = meters * _radiansPerMeterOnEarthSphere;

  /// Create a distance from [degrees]
  GeoDistance.fromDegrees(double degrees) : radians = degrees * _radiansPerDegree;

  /// Create a distance from [kilometers]
  factory GeoDistance.fromKilometers(double kilometers) => GeoDistance.fromMeters(kilometers * 1000);

  /// Create a distance from [miles]
  factory GeoDistance.fromMiles(double miles) => GeoDistance.fromMeters(miles * _metersPerMile);

  /// The distance in degrees
  double get degrees => radians / _radiansPerDegree;

  /// The distance in meters
  double get meters => radians / _radiansPerMeterOnEarthSphere;

  /// The distance in kilometers
  double get kilometers => meters / 1000;

  /// The distance in miles
  double get miles => meters / _metersPerMile;

  @override
  int compareTo(GeoDistance other) => radians.compareTo(other.radians);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GeoDistance) return false;
    return compareTo(other) == 0;
  }

  @override
  int get hashCode => radians.hashCode;

  @override
  String toString() => '$radians';
}

/// Convert a [num] to a [GeoDistance]
extension DoubleToGeoDistance on num {
  /// Create a distance from radians
  GeoDistance get radians => GeoDistance(toDouble());

  /// Create a distance from degrees
  GeoDistance get degrees => GeoDistance.fromDegrees(toDouble());

  /// Create a distance from meters
  GeoDistance get meters => GeoDistance.fromMeters(toDouble());

  /// Create a distance from kilometers
  GeoDistance get kilometers => GeoDistance.fromKilometers(toDouble());

  /// Create a distance from miles
  GeoDistance get miles => GeoDistance.fromMiles(toDouble());
}

/// A circle on the earth's surface.
///
/// This type can be used as the query argument for a `geoWithin` query.
/// It cannot be persisted as a property on a realm object.
final class GeoCircle implements GeoShape {
  final GeoPoint center;
  final GeoDistance radius;

  /// Create a circle from a [center] point and a [radius]
  const GeoCircle(this.center, this.radius);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GeoCircle) return false;
    return center == other.center && radius == other.radius;
  }

  @override
  int get hashCode => Object.hash(center, radius);

  @override
  String toString() => 'geoCircle($center, $radius)';
}
