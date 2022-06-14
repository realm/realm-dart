////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 Realm Inc.
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

// ignore_for_file: unused_local_variable, avoid_relative_lib_imports

import 'dart:io';
import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';

import 'test.dart';

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  await setupTests(args);

  _assertSchemaExists(Realm realm, SchemaObject expected) {
    final foundSchema = realm.schema.singleWhere((e) => e.name == expected.name);
    expect(foundSchema.properties.length, expected.properties.length);

    for (final prop in foundSchema.properties) {
      final expectedProp = expected.properties.singleWhere((e) => e.name == prop.name);
      expect(prop.collectionType, expectedProp.collectionType);
      expect(prop.linkTarget, expectedProp.linkTarget);
      expect(prop.optional, expectedProp.optional);
      expect(prop.primaryKey, expectedProp.primaryKey);
      expect(prop.propertyType, expectedProp.propertyType);
    }
  }

  test('schema is read from disk', () {
    final config = Configuration.local([Car.schema, Dog.schema, Person.schema, AllTypes.schema, LinksClass.schema]);
    getRealm(config).close();

    final dynamicConfig = Configuration.local([]);
    final realm = getRealm(dynamicConfig);

    expect(realm.schema.length, 5);

    _assertSchemaExists(realm, Car.schema);
    _assertSchemaExists(realm, Dog.schema);
    _assertSchemaExists(realm, Person.schema);
    _assertSchemaExists(realm, AllTypes.schema);
    _assertSchemaExists(realm, LinksClass.schema);
  });

  test('dynamic is always the same', () {
    final config = Configuration.local([Car.schema]);
    final realm = getRealm(config);

    final dynamic1 = realm.dynamic;
    final dynamic2 = realm.dynamic;

    expect(dynamic1, same(dynamic2));
  });

  for (var isDynamic in [true, false]) {
    Realm getDynamicRealm(Realm original) {
      if (isDynamic) {
        original.close();
        return getRealm(Configuration.local([]));
      }

      return original;
    }

    test('dynamic.all (dynamic=$isDynamic) returns empty collection', () {
      final config = Configuration.local([Car.schema]);
      final staticRealm = getRealm(config);

      final realm = getDynamicRealm(staticRealm);
      final allCars = realm.dynamic.all(Car.schema.name);
      expect(allCars.length, 0);
    });

    test('dynamic.all (dynamic=$isDynamic) returns non-empty collection', () {
      final config = Configuration.local([Car.schema]);
      final staticRealm = getRealm(config);
      staticRealm.write(() {
        staticRealm.add(Car('Honda'));
      });

      final realm = getDynamicRealm(staticRealm);
      final allCars = realm.dynamic.all(Car.schema.name);
      expect(allCars.length, 1);

      final car = allCars[0];
      expect(RealmObject.get<String>(car, 'make'), 'Honda');
    });

    test('dynamic.all (dynamic=$isDynamic) throws for non-existent type', () {
      final config = Configuration.local([Car.schema]);
      final staticRealm = getRealm(config);

      final dynamicRealm = getDynamicRealm(staticRealm);

      expect(() => dynamicRealm.dynamic.all('i-dont-exist'), throws<RealmError>("Object type i-dont-exist not configured in the current Realm's schema"));
    });

    test('dynamic.all (dynamic=$isDynamic) can follow links', () {
      final config = Configuration.local([LinksClass.schema]);
      final staticRealm = getRealm(config);

      final id1 = Uuid.v4();
      final id2 = Uuid.v4();
      final id3 = Uuid.v4();

      staticRealm.write(() {
        final obj1 = staticRealm.add(LinksClass(id1));
        final obj2 = staticRealm.add(LinksClass(id2));
        final obj3 = staticRealm.add(LinksClass(id3));

        obj1.link = obj2;
        obj2.link = obj3;

        obj1.list.addAll([obj1, obj2, obj3]);
      });

      final dynamicRealm = getDynamicRealm(staticRealm);

      final objects = dynamicRealm.dynamic.all(LinksClass.schema.name);
      final obj1 = objects.singleWhere((o) => RealmObject.get<Uuid>(o, 'id') as Uuid == id1);
      final obj2 = objects.singleWhere((o) => RealmObject.get<Uuid>(o, 'id') as Uuid == id2);
      final obj3 = objects.singleWhere((o) => RealmObject.get<Uuid>(o, 'id') as Uuid == id3);

      expect(RealmObject.get<RealmObject>(obj1, 'link'), obj2);
      expect(RealmObject.get<RealmObject>(obj2, 'link'), obj3);

      final list = RealmObject.get<RealmObject>(obj1, 'list') as List<RealmObject>;

      expect(list[0], obj1);
      expect(list[1], obj2);
      expect(list[2], obj3);
    });

    test('dynamic.all (dynamic=$isDynamic) can be filtered', () {
      final config = Configuration.local([Car.schema]);
      final staticRealm = getRealm(config);

      staticRealm.write(() {
        staticRealm.add(Car('Honda'));
        staticRealm.add(Car('Hyundai'));
        staticRealm.add(Car('Suzuki'));
        staticRealm.add(Car('Toyota'));
      });

      final dynamicRealm = getDynamicRealm(staticRealm);

      final carsWithH = dynamicRealm.dynamic.all(Car.schema.name).query('make BEGINSWITH "H"');
      expect(carsWithH.length, 2);
    });

    test('dynamic.find (dynamic=$isDynamic) can find by primary key', () {
      final config = Configuration.local([Car.schema]);
      final staticRealm = getRealm(config);

      staticRealm.write(() {
        staticRealm.add(Car('Honda'));
        staticRealm.add(Car('Hyundai'));
      });

      final dynamicRealm = getDynamicRealm(staticRealm);

      final car = dynamicRealm.dynamic.find(Car.schema.name, 'Honda');
      expect(car, isNotNull);
      expect(RealmObject.get<String>(car!, 'make'), 'Honda');

      final nonExistent = dynamicRealm.dynamic.find(Car.schema.name, 'i-dont-exist');
      expect(nonExistent, isNull);
    });

    test('dynamic.find (dynamic=$isDynamic) fails to find non-existent type', () {
      final config = Configuration.local([Car.schema]);
      final staticRealm = getRealm(config);

      final dynamicRealm = getDynamicRealm(staticRealm);

      expect(() => dynamicRealm.dynamic.find('i-dont-exist', 'i-dont-exist'),
          throws<RealmError>("Object type i-dont-exist not configured in the current Realm's schema"));
    });
  }
}
