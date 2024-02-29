// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:math';

import 'package:realm_common/realm_common.dart';
import 'package:test/test.dart' hide test, throws;

import 'package:realm_dart/realm.dart';
import 'test.dart';


part 'geospatial_test.realm.dart';

@RealmModel(ObjectType.embeddedObject)
class _Location {
  final String type = 'Point';
  late final List<double> coordinates;

  double get lon => coordinates[0];
  set lon(double value) => coordinates[0] = value;

  double get lat => coordinates[1];
  set lat(double value) => coordinates[1] = value;

  GeoPoint toGeoPoint() => GeoPoint(lon: lon, lat: lat);

  @override
  toString() => '($lon, $lat)';
}

@RealmModel()
class _Restaurant {
  @PrimaryKey()
  late String name;
  _Location? location;

  @override
  String toString() => name;
}

void createRestaurants(Realm realm) {
  realm.write(() {
    realm.add(Restaurant('Burger King', location: (0.0, 0.0).toLocation()));
  });
}

@RealmModel()
class _LocationList {
  late final List<_Location> locations;

  @override
  String toString() => '[${locations.join(', ')}]';
}

extension on GeoPoint {
  Location toLocation() {
    return Location(coordinates: [lon, lat]);
  }
}

extension on (num, num) {
  (num, num) get r => ($2, $1);
  GeoPoint toGeoPoint() => GeoPoint(lon: $1.toDouble(), lat: $2.toDouble());
  Location toLocation() => toGeoPoint().toLocation();
}

GeoRing ring(Iterable<(num, num)> coords, {bool close = true}) => GeoRing.from(coords.followedBy(close ? [coords.first] : []).map((c) => c.toGeoPoint()));

void main() {
  setupTests();

  final noma = Restaurant('Noma', location: (12.610534422524335, 55.682837071136916).toLocation());
  final theFatDuck = Restaurant('The Fat Duck', location: (-0.7017480029998424, 51.508054146883474).toLocation());
  final mugaritz = Restaurant('Mugaritz', location: (-1.9169972753911122, 43.27291163851115).toLocation());

  final realm = Realm(Configuration.inMemory([Location.schema, Restaurant.schema]));
  realm.write(() => realm.addAll([noma, theFatDuck, mugaritz]));

  final ringAroundNoma = ring([
    (12.7, 55.7),
    (12.6, 55.7),
    (12.6, 55.6),
  ]);
  final ringAroundTheFatDuck = ring([
    (-0.7, 51.6),
    (-0.7, 51.5),
    (-0.8, 51.5),
  ]);
  final ringAroundMugaritz = ring([
    (-2.0, 43.3),
    (-1.9, 43.3),
    (-1.9, 43.2),
  ]);
  // https://earth.google.com/earth/d/1yxJunwmJ8bOHVveoJZ_ProcCVO_VqYaz?usp=sharing
  final ringAroundAll = ring([
    (14.28516468673617, 56.65398894416146),
    (6.939337946654436, 56.27411809280813),
    (-1.988816029211967, 52.42582816187998),
    (-6.148020252081531, 49.09018453730319),
    (-6.397402529198644, 42.92138665921894),
    (-1.91041351386849, 41.49883413234565),
    (1.196195056765141, 48.58429125105875),
    (7.132994722232744, 52.7379048959241),
    (11.0454979022267, 54.51275033599874),
  ]);

  for (final (shape, restaurants) in [
    (GeoCircle(noma.location!.toGeoPoint(), 0.meters), [noma]),
    (GeoCircle(theFatDuck.location!.toGeoPoint(), 10.meters), [theFatDuck]),
    (GeoCircle(mugaritz.location!.toGeoPoint(), 10.meters), [mugaritz]),
    (GeoCircle(noma.location!.toGeoPoint(), 1000.kilometers), [noma, theFatDuck]),
    (GeoCircle(noma.location!.toGeoPoint(), 3000.miles), [noma, theFatDuck, mugaritz]),
    (GeoBox((12.6, 55.6).toGeoPoint(), (12.7, 55.7).toGeoPoint()), [noma]),
    (GeoBox((-0.8, 51.5).toGeoPoint(), (-0.7, 51.6).toGeoPoint()), [theFatDuck]),
    (GeoBox((-2.0, 43.2).toGeoPoint(), (-1.9, 43.3).toGeoPoint()), [mugaritz]),
    (GeoBox((-0.8, 51.5).toGeoPoint(), (12.7, 55.7).toGeoPoint()), [noma, theFatDuck]),
    (GeoBox((-2.0, 43.2).toGeoPoint(), (12.7, 55.7).toGeoPoint()), [noma, theFatDuck, mugaritz]),
    (GeoPolygon(ringAroundNoma), [noma]),
    (GeoPolygon(ringAroundTheFatDuck), [theFatDuck]),
    (GeoPolygon(ringAroundMugaritz), [mugaritz]),
    (
      GeoPolygon([
        noma.location!.toGeoPoint(),
        theFatDuck.location!.toGeoPoint(),
        mugaritz.location!.toGeoPoint(),
        noma.location!.toGeoPoint(), // close it
      ]),
      [], // corners not included (at least sometimes)
    ),
    (
      GeoPolygon(ringAroundAll),
      [
        noma,
        theFatDuck,
        mugaritz,
      ],
    ),
    (
      GeoPolygon(ringAroundAll, [ringAroundNoma]),
      [
        theFatDuck,
        mugaritz,
      ],
    ),
    (
      GeoPolygon(ringAroundAll, [ringAroundNoma, ringAroundTheFatDuck]),
      [
        mugaritz,
      ],
    ),
    (
      GeoPolygon(ringAroundAll, [ringAroundNoma, ringAroundTheFatDuck, ringAroundMugaritz]),
      [],
    )
  ]) {
    test('geo within $shape', () {
      final results = realm.query<Restaurant>('location geoWithin $shape');
      expect(results, unorderedEquals(restaurants));
      expect(results, realm.query<Restaurant>('location geoWithin \$0', [shape]));
    });
  }

  test('GeoPoint', () {
    final p = (12, 42).toGeoPoint();
    final l = p.toLocation();

    expect(p.lat, l.lat);
    expect(p.lon, l.lon);
    expect(l.coordinates, [p.lon, p.lat]);
  });

  test('GeoPoint', () {
    final validPoints = <(double, double)>[
      (0.0, 0.0),
      (double.minPositive, 0),
    ];
    for (final (lat, lon) in validPoints) {
      final p = (lon, lat).toGeoPoint();
      expect(p.lat, lat);
      expect(p.lon, lon);
    }
  });

  test('GeoPoint invalid args throws', () {
    const latError = 'lat';
    const lonError = 'lon';
    final validPoints = <(double, double, String)>[
      (-90.1, 0, latError),
      (double.negativeInfinity, 0, latError),
      (90.1, 0, latError),
      (double.infinity, 0, latError),
      // lng violations
      (0, -180.1, lonError),
      (0, double.negativeInfinity, lonError),
      (0, 180.1, lonError),
      (0, double.infinity, lonError),
    ];
    for (final (lat, lon, error) in validPoints) {
      expect(() => GeoPoint(lat: lat, lon: lon), throwsA(isA<ArgumentError>().having((e) => e.name, 'name', contains(error))));
    }
  });

  test('GeoBox invalid args throws', () {});

  test('GeoCircle invalid args throws', () {});

  test('GeoPolygon invalid args throws', () {
    expect(() => GeoPolygon(ring([(1, 1)])), throws<ArgumentError>('Ring must have at least 3 different'));
    expect(() => GeoPolygon(ring([(1, 1), (2, 2)])), throws<ArgumentError>('Ring must have at least 3 different'));
    expect(() => GeoPolygon(ring([(1, 1), (2, 2), (3, 3)], close: false)), throws<ArgumentError>('Vertices must form a ring (first != last)'));
    expect(() => GeoPolygon(ring([(1, 1), (2, 2), (3, 3), (4, 4)], close: false)), throws<ArgumentError>('Vertices must form a ring (first != last)'));
  });

  test('GeoPoint.operator==', () {
    final p = GeoPoint(lon: 1, lat: 1);
    expect(p, equals(p));
    expect(p, equals((p as Object))); // ignore: unnecessary_cast
    expect(p, equals(GeoPoint(lon: 1, lat: 1)));
    expect(p, isNot(equals(GeoPoint(lon: 1, lat: 2))));
    expect(p, isNot(equals(Object())));
  });

  test('GeoPoint.hashCode', () {
    final p = GeoPoint(lon: 1, lat: 1);
    expect(p.hashCode, p.hashCode); // stable
    expect(p.hashCode, equals(GeoPoint(lon: 1, lat: 1).hashCode));
    expect(p.hashCode, isNot(equals(GeoPoint(lon: 1, lat: 2).hashCode)));
  });

  test('GeoPoint.toString', () {
    final p = GeoPoint(lon: 1, lat: 1);
    expect(p.toString(), '[1.0, 1.0]'); // we don't use WKT for some reason
  });

  test('GeoBox.operator==', () {
    final b = GeoBox(GeoPoint(lon: 1, lat: 1), GeoPoint(lon: 2, lat: 2));
    expect(b, equals(b));
    expect(b, equals((b as Object))); // ignore: unnecessary_cast
    expect(b, equals(GeoBox(GeoPoint(lon: 1, lat: 1), GeoPoint(lon: 2, lat: 2))));
    expect(b, isNot(equals(GeoBox(GeoPoint(lon: 1, lat: 2), GeoPoint(lon: 2, lat: 2)))));
    expect(b, isNot(equals(GeoBox(GeoPoint(lon: 1, lat: 1), GeoPoint(lon: 2, lat: 3)))));
    expect(b, isNot(equals(Object())));
  });

  test('GeoBox.hashCode', () {
    final b = GeoBox(GeoPoint(lon: 1, lat: 1), GeoPoint(lon: 2, lat: 2));
    expect(b.hashCode, b.hashCode); // stable
    expect(b.hashCode, equals(GeoBox(GeoPoint(lon: 1, lat: 1), GeoPoint(lon: 2, lat: 2)).hashCode));
    expect(b.hashCode, isNot(equals(GeoBox(GeoPoint(lon: 1, lat: 2), GeoPoint(lon: 2, lat: 2))).hashCode));
    expect(b.hashCode, isNot(equals(GeoBox(GeoPoint(lon: 1, lat: 1), GeoPoint(lon: 2, lat: 3))).hashCode));
  });

  test('GeoBox.toString', () {
    final b = GeoBox(GeoPoint(lon: 1, lat: 1), GeoPoint(lon: 2, lat: 2));
    expect(b.toString(), 'geoBox([1.0, 1.0], [2.0, 2.0])'); // we don't use WKT for some reason
  });

  test('GeoCircle.operator==', () {
    final c = GeoCircle(GeoPoint(lon: 1, lat: 1), 1.meters);
    expect(c, equals(c));
    expect(c, equals((c as Object))); // ignore: unnecessary_cast
    expect(c, equals(GeoCircle(GeoPoint(lon: 1, lat: 1), 1.meters)));
    expect(c, isNot(equals(GeoCircle(GeoPoint(lon: 1, lat: 2), 1.meters))));
    expect(c, isNot(equals(GeoCircle(GeoPoint(lon: 1, lat: 1), 2.meters))));
    expect(c, isNot(equals(Object())));
  });

  test('GeoCircle.hashCode', () {
    final c = GeoCircle(GeoPoint(lon: 1, lat: 1), 1.meters);
    expect(c.hashCode, c.hashCode); // stable
    expect(c.hashCode, equals(GeoCircle(GeoPoint(lon: 1, lat: 1), 1.meters).hashCode));
    expect(c.hashCode, isNot(equals(GeoCircle(GeoPoint(lon: 1, lat: 2), 1.meters).hashCode)));
    expect(c.hashCode, isNot(equals(GeoCircle(GeoPoint(lon: 1, lat: 1), 2.meters).hashCode)));
  });

  test('GeoCircle.toString', () {
    final c = GeoCircle(GeoPoint(lon: 1, lat: 1), 1.meters);
    expect(c.toString(), 'geoCircle([1.0, 1.0], ${1.meters.radians})'); // we don't use WKT for some reason
  });

  test('GeoPolygon.operator==', () {
    final p = GeoPolygon(ring([(1, 1), (2, 2), (3, 3)]));
    expect(p, equals(p));
    expect(p, equals((p as Object))); // ignore: unnecessary_cast
    // for efficiency we don't check the ring
    expect(p, isNot(equals(GeoPolygon(ring([(1, 1), (2, 2), (3, 3)])))));
    expect(p, isNot(equals(GeoPolygon(ring([(1, 1), (2, 2), (3, 4)])))));
    expect(p, isNot(equals(Object())));
  });

  test('GeoPolygon.hashCode', () {
    final p = GeoPolygon(ring([(1, 1), (2, 2), (3, 3)]));
    expect(p.hashCode, p.hashCode); // stable
    // for efficiency we don't check the ring
    expect(p.hashCode, isNot(equals(GeoPolygon(ring([(1, 1), (2, 2), (3, 3)])).hashCode)));
    expect(p.hashCode, isNot(equals(GeoPolygon(ring([(1, 1), (2, 2), (3, 4)])).hashCode)));
  });

  test('GeoPolygon.toString', () {
    final p = GeoPolygon(ring([(1, 1), (2, 2), (3, 3)]));
    expect(p.toString(), 'geoPolygon({[1.0, 1.0], [2.0, 2.0], [3.0, 3.0], [1.0, 1.0]})'); // we don't use WKT for some reason
  });

  test('GeoDistance', () {
    final d = GeoDistance(1);
    expect(d.degrees, 180 / pi);
    expect(d.meters, 1 / 1.5678502891116e-7);
    expect(d.kilometers, 1 / 1.5678502891116e-7 / 1000);
    expect(d.miles, d.meters / 1609.344);
    expect(d.toString(), '1.0');

    expect(1.radians, const GeoDistance(1));
    expect(1.degrees, GeoDistance.fromDegrees(1));
    expect(1.meters, GeoDistance.fromMeters(1));
    expect(1.kilometers, GeoDistance.fromKilometers(1));
    expect(1.miles, GeoDistance.fromMiles(1));

    expect(1000.meters, 1.kilometers);
    expect(1609.344.meters, 1.miles);
  });

  test('LocationList', () {
    final config = Configuration.local([Location.schema, LocationList.schema]);
    final realm = getRealm(config);
    const max = 3;
    final random = Random(42);
    final geoPoints = List.generate(max, (index) => GeoPoint(lon: random.nextDouble(), lat: random.nextDouble()));
    final sublists = List.generate(max, (index) {
      final start = random.nextInt(max);
      final end = random.nextInt(max - start) + start;
      return geoPoints.sublist(start, end).map((p) => p.toLocation()).toList();
    });
    realm.write(() {
      realm.addAll(sublists.map((l) => LocationList(locations: l)));
    });

    for (final p in geoPoints) {
      final results = realm.query<LocationList>('ANY locations geoWithin \$0', [GeoCircle(p, 0.radians)]);
      for (final list in results) {
        expect(list.locations.map((l) => l.toGeoPoint()), contains(p));
      }
    }
    final nonEmpty = realm.query<LocationList>('locations.@size > 0');
    final bigCircle = realm.query<LocationList>('ALL locations geoWithin \$0', [GeoCircle(GeoPoint(lon: 0, lat: 0), sqrt(2).radians)]);
    expect(bigCircle, unorderedEquals(nonEmpty));

    final box = GeoBox(GeoPoint(lon: 0, lat: 0), GeoPoint(lon: 1, lat: 1));
    expect(realm.query<LocationList>('ALL locations geoWithin \$0', [box]), unorderedEquals(nonEmpty));
  });
}
