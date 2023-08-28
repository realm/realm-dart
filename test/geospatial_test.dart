////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

import 'dart:async';
import 'dart:math';

import 'package:realm_common/realm_common.dart';
import 'package:test/test.dart' hide test, throws;

import '../lib/realm.dart';
import 'test.dart';

part 'geospatial_test.g.dart';

@RealmModel(ObjectType.embeddedObject)
class _Location {
  final String type = 'Point';
  List<double> coordinates = const [0, 0];

  double get longitude => coordinates[0];
  set longitude(double value) => coordinates[0] = value;

  double get latitude => coordinates[1];
  set latitude(double value) => coordinates[1] = value;
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

extension on GeoPoint {
  Location toLocation() {
    return Location(coordinates: [lng, lat]);
  }
}

extension on Location {
  GeoPoint toGeoPoint() {
    return GeoPoint(coordinates[1], coordinates[0]);
  }
}

extension on num {
  GeoDistance get m => meters;
  GeoDistance get km => kilometers;
}

extension on (num, num) {
  GeoPoint toGeoPoint({bool reverse = false}) => reverse ? GeoPoint($2.toDouble(), $1.toDouble()) : GeoPoint($1.toDouble(), $2.toDouble());
  Location toLocation() => toGeoPoint().toLocation();
}

GeoRing ring(Iterable<(num, num)> coords, {bool close = true, bool reverse = false}) =>
    GeoRing.from(coords.followedBy(close ? [coords.first] : []).map((c) => c.toGeoPoint(reverse: reverse)));

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  final noma = Restaurant('Noma', location: (55.682837071136916, 12.610534422524335).toLocation());
  final theFatDuck = Restaurant('The Fat Duck', location: (51.508054146883474, -0.7017480029998424).toLocation());
  final mugaritz = Restaurant('Mugaritz', location: (43.27291163851115, -1.9169972753911122).toLocation());

  final realm = Realm(Configuration.inMemory([Location.schema, Restaurant.schema]));
  realm.write(() => realm.addAll([noma, theFatDuck, mugaritz]));

  final ringAroundNoma = ring([
    (55.7, 12.7),
    (55.7, 12.6),
    (55.6, 12.6),
  ]);
  final ringAroundTheFatDuck = ring([
    (51.6, -0.7),
    (51.5, -0.7),
    (51.5, -0.8),
  ]);
  final ringAroundMugaritz = ring([
    (43.3, -2.0),
    (43.3, -1.9),
    (43.2, -1.9),
  ]);
  // https://earth.google.com/earth/d/1yxJunwmJ8bOHVveoJZ_ProcCVO_VqYaz?usp=sharing
  final ringAroundAll = ring([
    (56.65398894416146, 14.28516468673617),
    (56.27411809280813, 6.939337946654436),
    (52.42582816187998, -1.988816029211967),
    (49.09018453730319, -6.148020252081531),
    (42.92138665921894, -6.397402529198644),
    (41.49883413234565, -1.91041351386849),
    (48.58429125105875, 1.196195056765141),
    (52.7379048959241, 7.132994722232744),
    (54.51275033599874, 11.0454979022267),
  ]);

  for (final (shape, restaurants) in [
    (GeoCircle(noma.location!.toGeoPoint(), 0.meters), [noma]),
    (GeoCircle(theFatDuck.location!.toGeoPoint(), 10.meters), [theFatDuck]),
    (GeoCircle(mugaritz.location!.toGeoPoint(), 10.meters), [mugaritz]),
    (GeoCircle(noma.location!.toGeoPoint(), 1000.kilometers), [noma, theFatDuck]),
    (GeoCircle(noma.location!.toGeoPoint(), 3000.miles), [noma, theFatDuck, mugaritz]),
    (GeoBox((55.6, 12.6).toGeoPoint(), (55.7, 12.7).toGeoPoint()), [noma]),
    (GeoBox((51.5, -0.8).toGeoPoint(), (51.6, -0.7).toGeoPoint()), [theFatDuck]),
    (GeoBox((43.2, -2.0).toGeoPoint(), (43.3, -1.9).toGeoPoint()), [mugaritz]),
    (GeoBox((51.5, -0.8).toGeoPoint(), (55.7, 12.7).toGeoPoint()), [noma, theFatDuck]),
    (GeoBox((43.2, -2.0).toGeoPoint(), (55.7, 12.7).toGeoPoint()), [noma, theFatDuck, mugaritz]),
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
      // TODO: This is temporary until C-API support GeoShapes
      expect(() => realm.query<Restaurant>('location geoWithin \$0', [shape]), throws<RealmException>('Property type'));
    });
  }

  test('GeoPoint', () {
    final p = GeoPoint(42, 12);
    final l = p.toLocation();

    expect(p.lat, l.latitude);
    expect(p.lng, l.longitude);
    expect(l.coordinates, [p.lng, p.lat]);
  });

  test('GeoPoint', () {
    final validPoints = <(double, double)>[
      (0.0, 0.0),
      (double.minPositive, 0),
    ];
    for (final (lat, lng) in validPoints) {
      final p = GeoPoint(lat, lng);
      expect(p.lat, lat);
      expect(p.lng, lng);
    }
  });

  test('GeoPoint invalid args throws', () {
    const latError = 'lat';
    const lngError = 'lng';
    final validPoints = <(double, double, String)>[
      (-90.1, 0, latError),
      (double.negativeInfinity, 0, latError),
      (90.1, 0, latError),
      (double.infinity, 0, latError),
      // lng violations
      (0, -180.1, lngError),
      (0, double.negativeInfinity, lngError),
      (0, 180.1, lngError),
      (0, double.infinity, lngError),
    ];
    for (final (lat, lng, error) in validPoints) {
      expect(() => GeoPoint(lat, lng), throwsA(isA<ArgumentError>().having((e) => e.name, 'name', contains(error))));
    }
  });

  test('GeoBox invalid args throws', () {});

  test('GeoCircle invalid args throws', () {});

  test('GeoPolygon invalid args throws', () {
    expect(() => GeoPolygon(ring([(1, 1)])), throws<ArgumentError>('Ring must have at least 3 different'));
    expect(() => GeoPolygon(ring([(1, 1), (2, 2)])), throws<ArgumentError>('Ring must have at least 3 different'));
    expect(() => GeoPolygon(ring([(1, 1), (2, 2), (3, 3)], close: false)), throws<ArgumentError>('first != last'));
    expect(() => GeoPolygon(ring([(1, 1), (2, 2), (3, 3), (4, 4)], close: false)), throws<ArgumentError>('first != last'));
  });

  test('GeoPoint.operator==', () {
    final p = GeoPoint(1, 1);
    expect(p, equals(p));
    expect(p, equals((p as Object))); // ignore: unnecessary_cast
    expect(p, equals(GeoPoint(1, 1)));
    expect(p, isNot(equals(GeoPoint(1, 2))));
    expect(p, isNot(equals(Object())));
  });

  test('GeoPoint.hashCode', () {
    final p = GeoPoint(1, 1);
    expect(p.hashCode, p.hashCode); // stable
    expect(p.hashCode, equals(GeoPoint(1, 1).hashCode));
    expect(p.hashCode, isNot(equals(GeoPoint(1, 2).hashCode)));
  });

  test('GeoPoint.toString', () {
    final p = GeoPoint(1, 1);
    expect(p.toString(), '[1.0, 1.0]'); // we don't use WKT for some reason
  });

  test('GeoBox.operator==', () {
    final b = GeoBox(GeoPoint(1, 1), GeoPoint(2, 2));
    expect(b, equals(b));
    expect(b, equals((b as Object))); // ignore: unnecessary_cast
    expect(b, equals(GeoBox(GeoPoint(1, 1), GeoPoint(2, 2))));
    expect(b, isNot(equals(GeoBox(GeoPoint(1, 2), GeoPoint(2, 2)))));
    expect(b, isNot(equals(GeoBox(GeoPoint(1, 1), GeoPoint(2, 3)))));
    expect(b, isNot(equals(Object())));
  });

  test('GeoBox.hashCode', () {
    final b = GeoBox(GeoPoint(1, 1), GeoPoint(2, 2));
    expect(b.hashCode, b.hashCode); // stable
    expect(b.hashCode, equals(GeoBox(GeoPoint(1, 1), GeoPoint(2, 2)).hashCode));
    expect(b.hashCode, isNot(equals(GeoBox(GeoPoint(1, 2), GeoPoint(2, 2))).hashCode));
    expect(b.hashCode, isNot(equals(GeoBox(GeoPoint(1, 1), GeoPoint(2, 3))).hashCode));
  });

  test('GeoBox.toString', () {
    final b = GeoBox(GeoPoint(1, 1), GeoPoint(2, 2));
    expect(b.toString(), 'geoBox([1.0, 1.0], [2.0, 2.0])'); // we don't use WKT for some reason
  });

  test('GeoCircle.operator==', () {
    final c = GeoCircle(GeoPoint(1, 1), 1.m);
    expect(c, equals(c));
    expect(c, equals((c as Object))); // ignore: unnecessary_cast
    expect(c, equals(GeoCircle(GeoPoint(1, 1), 1.m)));
    expect(c, isNot(equals(GeoCircle(GeoPoint(1, 2), 1.m))));
    expect(c, isNot(equals(GeoCircle(GeoPoint(1, 1), 2.m))));
    expect(c, isNot(equals(Object())));
  });

  test('GeoCircle.hashCode', () {
    final c = GeoCircle(GeoPoint(1, 1), 1.m);
    expect(c.hashCode, c.hashCode); // stable
    expect(c.hashCode, equals(GeoCircle(GeoPoint(1, 1), 1.m).hashCode));
    expect(c.hashCode, isNot(equals(GeoCircle(GeoPoint(1, 2), 1.m).hashCode)));
    expect(c.hashCode, isNot(equals(GeoCircle(GeoPoint(1, 1), 2.m).hashCode)));
  });

  test('GeoCircle.toString', () {
    final c = GeoCircle(GeoPoint(1, 1), 1.m);
    expect(c.toString(), 'geoCircle([1.0, 1.0], ${1.m.radians})'); // we don't use WKT for some reason
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
  });
}
