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

import 'dart:io';

import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';

import 'test.dart';

part 'realm_set_test.g.dart';

@RealmModel()
class _TestRealmSets {
  @PrimaryKey()
  late int key;

  late Set<bool> boolSet;
  // late Set<int> intSet;
  // late Set<String> stringSet;
  // late Set<double> doubleSet;
}

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  test('RealmSet create', () {
    var config = Configuration.local([TestRealmSets.schema]);
    var realm = getRealm(config);

    final testSet = TestRealmSets(1);
    realm.write(() {
      realm.add(testSet);
    });

    expect(testSet.key, equals(1));
    expect(testSet.boolSet, isNotNull);
  });

  test('RealmSet contains', () {
    var config = Configuration.local([TestRealmSets.schema]);
    var realm = getRealm(config);

    final testSet = TestRealmSets(1);
    realm.write(() {
      realm.add(testSet);
    });

    expect(testSet.boolSet.contains(true), false);
  });

  test('RealmSet add', () {
    var config = Configuration.local([TestRealmSets.schema]);
    var realm = getRealm(config);

    final testSet = TestRealmSets(1);
    realm.write(() {
      realm.add(testSet);
      testSet.boolSet.add(true);
    });

    expect(testSet.boolSet.contains(true), true);
  });

  test('RealmSet remove', () {
    var config = Configuration.local([TestRealmSets.schema]);
    var realm = getRealm(config);

    final testSet = TestRealmSets(1);
    realm.write(() {
      realm.add(testSet);
    });

    realm.write(() {
      testSet.boolSet.add(true);
    });
    expect(testSet.boolSet.length, 1);

    realm.write(() {
      expect(testSet.boolSet.remove(true), true);
    });

    expect(testSet.boolSet.length, 0);
  });

  test('RealmSet length', () {
    var config = Configuration.local([TestRealmSets.schema]);
    var realm = getRealm(config);

    final testSet = TestRealmSets(1);
    realm.write(() {
      realm.add(testSet);
    });

    expect(testSet.boolSet.length, 0);

    realm.write(() {
      testSet.boolSet.add(true);
    });

    expect(testSet.boolSet.length, 1);

    realm.write(() {
      testSet.boolSet.add(false);
    });

    expect(testSet.boolSet.length, 2);
  });

  test('RealmSet elementAt', () {
    var config = Configuration.local([TestRealmSets.schema]);
    var realm = getRealm(config);

    final testSet = TestRealmSets(1);
    realm.write(() {
      realm.add(testSet);
      testSet.boolSet.add(true);
      testSet.boolSet.add(false);
    });

    //depends on order of insertion
    expect(testSet.boolSet.elementAt(0), false);
    expect(testSet.boolSet.elementAt(1), true);
  });

  test('RealmSet lookup', () {
    var config = Configuration.local([TestRealmSets.schema]);
    var realm = getRealm(config);

    final testSet = TestRealmSets(1);
    realm.write(() {
      realm.add(testSet);
    });

    expect(testSet.boolSet.lookup(true), null);

    realm.write(() {
      testSet.boolSet.add(true);
    });

    expect(testSet.boolSet.lookup(true), true);
  });

  test('RealmSet clear', () {
    var config = Configuration.local([TestRealmSets.schema]);
    var realm = getRealm(config);

    final testSet = TestRealmSets(1);
    realm.write(() {
      realm.add(testSet);
      testSet.boolSet.add(true);
      testSet.boolSet.add(false);
    });

    expect(testSet.boolSet.length, 2);

    realm.write(() {
      testSet.boolSet.clear();
    });

    expect(testSet.boolSet.length, 0);
  });
}
