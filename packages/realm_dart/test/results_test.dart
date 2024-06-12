// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: unused_local_variable

import 'dart:typed_data';
import 'package:test/test.dart' hide test, throws;

import 'package:realm_dart/realm.dart';
import 'test.dart';

part 'results_test.realm.dart';

@RealmModel()
class _TestNotificationObject {
  late String? stringProperty;

  late int? intProperty;

  @MapTo("_remappedIntProperty")
  late int? remappedIntProperty;

  late _TestNotificationObject? link;

  late List<_TestNotificationObject> list;

  late Set<_TestNotificationObject> set;

  late Map<String, _TestNotificationObject?> map;

  late _TestNotificationDifferentType? linkDifferentType;

  late List<_TestNotificationDifferentType> listDifferentType;

  late Set<_TestNotificationDifferentType> setDifferentType;

  late Map<String, _TestNotificationDifferentType?> mapDifferentType;

  late _TestNotificationEmbeddedObject? embedded;

  @Backlink(#link)
  late Iterable<_TestNotificationObject> backlink;
}

@RealmModel(ObjectType.embeddedObject)
class _TestNotificationEmbeddedObject {
  late String? stringProperty;

  late int? intProperty;
}

@RealmModel()
class _TestNotificationDifferentType {
  late String? stringProperty;

  late int? intProperty;

  late _TestNotificationDifferentType? link;
}

void main() {
  setupTests();

  group('Results notifications with keypaths', () {
    Future<void> verifyNotifications<T extends RealmObjectBase>(List<RealmResultsChanges<T>> changeList,
        {List<int>? expectedInserted,
        List<int>? expectedModified,
        List<int>? expectedDeleted,
        List<int>? expectedMoved,
        bool expectedIsCleared = false,
        bool expectedNotifications = true}) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));

      if (!expectedNotifications) {
        expect(changeList.length, 0);
        return;
      }

      expect(changeList.length, 1);
      final changes = changeList[0];

      expect(changes.inserted, expectedInserted ?? []);
      expect(changes.modified, expectedModified ?? []);
      expect(changes.deleted, expectedDeleted ?? []);
      expect(changes.moved, expectedMoved ?? []);
      expect(changes.isCleared, expectedIsCleared);

      changeList.clear();
    }

    bool isFirstNotification<T extends RealmObjectBase>(RealmResultsChanges<T> changes) {
      return changes.inserted.isEmpty &&
          changes.modified.isEmpty &&
          changes.deleted.isEmpty &&
          changes.newModified.isEmpty &&
          changes.moved.isEmpty &&
          !changes.isCleared;
    }

    test('throws on invalid keypath', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema, TestNotificationDifferentType.schema]);
      var realm = getRealm(config);

      expect(() {
        realm.all<TestNotificationObject>().changesFor(["stringProperty", "inv"]).listen((changes) {});
      }, throws<RealmException>("Property 'inv' in KeyPath 'inv' is not a valid property in TestNotificationObject"));

      expect(() {
        realm.all<TestNotificationObject>().changesFor(["stringProperty", "link.inv2"]).listen((changes) {});
      }, throws<RealmException>("Property 'inv2' in KeyPath 'link.inv2' is not a valid property in TestNotificationObject"));
    });

    test('throws on empty or whitespace keypath', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema, TestNotificationDifferentType.schema]);
      var realm = getRealm(config);

      expect(() {
        realm.all<TestNotificationObject>().changesFor(["stringProperty", ""]).listen((changes) {});
      }, throws<RealmException>("A key path cannot be empty or consisting only of white spaces"));

      expect(() {
        realm.all<TestNotificationObject>().changesFor(["stringProperty", "  "]).listen((changes) {});
      }, throws<RealmException>("A key path cannot be empty or consisting only of white spaces"));
    });

    test('throws on empty or whitespace keypath', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema, TestNotificationDifferentType.schema]);
      var realm = getRealm(config);

      expect(() {
        realm.all<TestNotificationObject>().changesFor(["stringProperty", ""]).listen((changes) {});
      }, throws<RealmException>("A key path cannot be empty or consisting only of white spaces"));

      expect(() {
        realm.all<TestNotificationObject>().changesFor(["stringProperty", "  "]).listen((changes) {});
      }, throws<RealmException>("A key path cannot be empty or consisting only of white spaces"));
    });

    test('null keypaths behaves like default', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema, TestNotificationDifferentType.schema]);
      var realm = getRealm(config);

      final externalChanges = <RealmResultsChanges<TestNotificationObject>>[];
      final subscription = realm.all<TestNotificationObject>().changesFor(null).listen((changes) {
        if (!isFirstNotification(changes)) externalChanges.add(changes);
      });

      final tno = TestNotificationObject();
      realm.write(() {
        realm.add(tno);
      });
      await verifyNotifications(externalChanges, expectedInserted: [0]);

      realm.write(() {
        tno.stringProperty = "testString";
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.embedded = TestNotificationEmbeddedObject();
        tno.linkDifferentType = TestNotificationDifferentType();
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.linkDifferentType?.stringProperty = "test";
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      subscription.cancel();
    });

    //TODO Not sure why this one doesn't pass
    test('empty keypath raises only shallow notifications', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema, TestNotificationDifferentType.schema]);
      var realm = getRealm(config);

      final externalChanges = <RealmResultsChanges<TestNotificationObject>>[];
      final subscription = realm.all<TestNotificationObject>().changesFor([]).listen((changes) {
        if (!isFirstNotification(changes)) externalChanges.add(changes);
      });

      final tno = TestNotificationObject();
      realm.write(() {
        realm.add(tno);
      });
      await verifyNotifications(externalChanges, expectedInserted: [0]);

      realm.write(() {
        tno.stringProperty = "testString";
        tno.intProperty = 23;
        tno.remappedIntProperty = 25;
        tno.embedded = TestNotificationEmbeddedObject();
        tno.linkDifferentType = TestNotificationDifferentType();
        tno.listDifferentType.add(TestNotificationDifferentType());
        tno.setDifferentType.add(TestNotificationDifferentType());
        tno.mapDifferentType["test"] = TestNotificationDifferentType();
      });
      await verifyNotifications(externalChanges, expectedNotifications: false);

      subscription.cancel();
    }, skip: true);

    test('multiple keypaths', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema, TestNotificationDifferentType.schema]);
      var realm = getRealm(config);

      final externalChanges = <RealmResultsChanges<TestNotificationObject>>[];
      final subscription = realm.all<TestNotificationObject>().changesFor(["stringProperty", "intProperty"]).listen((changes) {
        if (!isFirstNotification(changes)) externalChanges.add(changes);
      });

      final tno = TestNotificationObject();
      realm.write(() {
        realm.add(tno);
      });
      await verifyNotifications(externalChanges, expectedInserted: [0]);

      realm.write(() {
        tno.stringProperty = "testString";
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.intProperty = 23;
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.remappedIntProperty = 25;
        tno.embedded = TestNotificationEmbeddedObject();
      });
      await verifyNotifications(externalChanges, expectedNotifications: false);

      subscription.cancel();
    });

    test('scalar top level property', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema, TestNotificationDifferentType.schema]);
      var realm = getRealm(config);

      final externalChanges = <RealmResultsChanges<TestNotificationObject>>[];
      final subscription = realm.all<TestNotificationObject>().changesFor(["stringProperty"]).listen((changes) {
        if (!isFirstNotification(changes)) externalChanges.add(changes);
      });

      final tno = TestNotificationObject();
      realm.write(() {
        realm.add(tno);
      });
      await verifyNotifications(externalChanges, expectedInserted: [0]);

      realm.write(() {
        tno.stringProperty = "testString";
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.intProperty = 23;
        tno.remappedIntProperty = 25;
        tno.embedded = TestNotificationEmbeddedObject();
        tno.linkDifferentType = TestNotificationDifferentType();
        tno.listDifferentType.add(TestNotificationDifferentType());
      });
      await verifyNotifications(externalChanges, expectedNotifications: false);

      subscription.cancel();
    });

    test('nested property on link', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema, TestNotificationDifferentType.schema]);
      var realm = getRealm(config);

      final externalChanges = <RealmResultsChanges<TestNotificationObject>>[];
      final subscription = realm.all<TestNotificationObject>().changesFor(["linkDifferentType.intProperty"]).listen((changes) {
        if (!isFirstNotification(changes)) externalChanges.add(changes);
      });

      final tno = TestNotificationObject();
      realm.write(() {
        realm.add(tno);
      });
      await verifyNotifications(externalChanges, expectedInserted: [0]);

      realm.write(() {
        tno.linkDifferentType = TestNotificationDifferentType();
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.linkDifferentType?.intProperty = 23;
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.linkDifferentType?.stringProperty = "test";

        tno.intProperty = 23;
        tno.embedded = TestNotificationEmbeddedObject();
        tno.listDifferentType.add(TestNotificationDifferentType());
      });
      await verifyNotifications(externalChanges, expectedNotifications: false);

      subscription.cancel();
    });

    test('nested property on collection', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema, TestNotificationDifferentType.schema]);
      var realm = getRealm(config);

      final externalChanges = <RealmResultsChanges<TestNotificationObject>>[];
      final subscription = realm.all<TestNotificationObject>().changesFor(["listDifferentType.intProperty"]).listen((changes) {
        if (!isFirstNotification(changes)) externalChanges.add(changes);
      });

      final tno = TestNotificationObject();
      realm.write(() {
        realm.add(tno);
      });
      await verifyNotifications(externalChanges, expectedInserted: [0]);

      realm.write(() {
        tno.listDifferentType.add(TestNotificationDifferentType());
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.listDifferentType[0].intProperty = 23;
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.listDifferentType[0].stringProperty = "23";

        tno.intProperty = 23;
        tno.embedded = TestNotificationEmbeddedObject();
      });
      await verifyNotifications(externalChanges, expectedNotifications: false);

      subscription.cancel();
    });

    test('collection top level property', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema, TestNotificationDifferentType.schema]);
      var realm = getRealm(config);

      final externalChanges = <RealmResultsChanges<TestNotificationObject>>[];
      final subscription = realm.all<TestNotificationObject>().changesFor(["listDifferentType"]).listen((changes) {
        if (!isFirstNotification(changes)) externalChanges.add(changes);
      });

      final tno = TestNotificationObject();
      realm.write(() {
        realm.add(tno);
      });
      await verifyNotifications(externalChanges, expectedInserted: [0]);

      realm.write(() {
        tno.listDifferentType.add(TestNotificationDifferentType());
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.listDifferentType[0].stringProperty = "34";
        tno.listDifferentType[0].intProperty = 23;
        tno.intProperty = 23;
        tno.linkDifferentType = TestNotificationDifferentType();
      });
      await verifyNotifications(externalChanges, expectedNotifications: false);

      subscription.cancel();
    });

    test('wildcard top level', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema, TestNotificationDifferentType.schema]);
      var realm = getRealm(config);

      final externalChanges = <RealmResultsChanges<TestNotificationObject>>[];
      final subscription = realm.all<TestNotificationObject>().changesFor(["*"]).listen((changes) {
        if (!isFirstNotification(changes)) externalChanges.add(changes);
      });

      final tno = TestNotificationObject();
      realm.write(() {
        realm.add(tno);
      });
      await verifyNotifications(externalChanges, expectedInserted: [0]);

      realm.write(() {
        tno.listDifferentType.add(TestNotificationDifferentType());
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.mapDifferentType["test"] = TestNotificationDifferentType();
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.linkDifferentType = TestNotificationDifferentType();
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.intProperty = 23;
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      // No notifications deeper than one level
      realm.write(() {
        tno.listDifferentType[0].stringProperty = "34";
        tno.mapDifferentType["test"]?.intProperty = 23;
        tno.linkDifferentType?.intProperty = 21;
      });
      await verifyNotifications(externalChanges, expectedNotifications: false);

      subscription.cancel();
    });

    test('wildcard nested', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema, TestNotificationDifferentType.schema]);
      var realm = getRealm(config);

      final externalChanges = <RealmResultsChanges<TestNotificationObject>>[];
      final subscription = realm.all<TestNotificationObject>().changesFor(["*.*"]).listen((changes) {
        if (!isFirstNotification(changes)) externalChanges.add(changes);
      });

      final tno = TestNotificationObject();
      realm.write(() {
        realm.add(tno);
      });
      await verifyNotifications(externalChanges, expectedInserted: [0]);

      realm.write(() {
        tno.listDifferentType.add(TestNotificationDifferentType());
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.mapDifferentType["test"] = TestNotificationDifferentType();
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.linkDifferentType = TestNotificationDifferentType();
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.intProperty = 23;
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.listDifferentType[0].stringProperty = "34";
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.linkDifferentType?.intProperty = 21;
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.linkDifferentType?.link = TestNotificationDifferentType();
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      // No notifications deeper than two levels
      realm.write(() {
        tno.linkDifferentType?.link?.intProperty = 24;
      });
      await verifyNotifications(externalChanges, expectedNotifications: false);

      subscription.cancel();
    });

    test('wildcard nested on top level property', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema, TestNotificationDifferentType.schema]);
      var realm = getRealm(config);

      final externalChanges = <RealmResultsChanges<TestNotificationObject>>[];
      final subscription = realm.all<TestNotificationObject>().changesFor(["linkDifferentType.*"]).listen((changes) {
        if (!isFirstNotification(changes)) externalChanges.add(changes);
      });

      final tno = TestNotificationObject();
      realm.write(() {
        realm.add(tno);
      });
      await verifyNotifications(externalChanges, expectedInserted: [0]);

      realm.write(() {
        tno.linkDifferentType = TestNotificationDifferentType();
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.linkDifferentType?.link = TestNotificationDifferentType();
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      // No notifications deeper than one level on linkDifferentType
      // No notifications for other keypaths
      realm.write(() {
        tno.linkDifferentType?.link?.intProperty = 23;

        tno.listDifferentType.add(TestNotificationDifferentType());
        tno.intProperty = 23;
      });
      await verifyNotifications(externalChanges, expectedNotifications: false);

      subscription.cancel();
    });

    test('nested property on wildcard', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema, TestNotificationDifferentType.schema]);
      var realm = getRealm(config);

      final externalChanges = <RealmResultsChanges<TestNotificationObject>>[];
      final subscription = realm.all<TestNotificationObject>().changesFor(["*.intProperty"]).listen((changes) {
        if (!isFirstNotification(changes)) externalChanges.add(changes);
      });

      final tno = TestNotificationObject();
      realm.write(() {
        realm.add(tno);
      });
      await verifyNotifications(externalChanges, expectedInserted: [0]);

      realm.write(() {
        tno.linkDifferentType = TestNotificationDifferentType();
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.linkDifferentType?.intProperty = 23;
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.listDifferentType.add(TestNotificationDifferentType());
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.listDifferentType[0].intProperty = 23;
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.mapDifferentType["test"] = TestNotificationDifferentType();
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      realm.write(() {
        tno.mapDifferentType["test"]?.intProperty = 22;
      });
      await verifyNotifications(externalChanges, expectedModified: [0]);

      // No notifications not on keypath
      realm.write(() {
        tno.linkDifferentType?.link?.stringProperty = "23";
        tno.listDifferentType[0].stringProperty = "22";
        tno.mapDifferentType["test"]?.stringProperty = "22";
      });
      await verifyNotifications(externalChanges, expectedNotifications: false);

      subscription.cancel();
    });
  });

  test('Results all should not return null', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final cars = realm.all<Car>();
    expect(cars, isNotNull);
  });

  test('Results length after deletedMany', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    var cars = realm.all<Car>();
    expect(cars.length, 0);

    final carOne = Car("Toyota 1");
    final carTwo = Car("Toyota 2");
    final carThree = Car("Renault");
    realm.write(() => realm.addAll([carOne, carTwo, carThree]));

    expect(cars.length, 3);

    final filteredCars = realm.query<Car>('make BEGINSWITH "Toyot"');
    expect(filteredCars.length, 2);

    realm.write(() => realm.deleteMany(filteredCars));
    expect(filteredCars.length, 0);

    expect(cars.length, 1);
  });

  test('Results length', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    var cars = realm.all<Car>();
    expect(cars.length, 0);

    final carOne = Car("Toyota");
    final carTwo = Car("Toyota 1");
    realm.write(() => realm.addAll([carOne, carTwo]));

    expect(cars.length, 2);

    final filteredCars = realm.query<Car>('make == "Toyota"');
    expect(filteredCars.length, 1);
  });

  test('Results isEmpty', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    var cars = realm.all<Car>();
    expect(cars.isEmpty, true);

    final car = Car("Opel");
    realm.write(() => realm.add(car));

    expect(cars.isEmpty, false);

    realm.write(() => realm.delete(car));

    expect(cars.isEmpty, true);
  });

  test('Results from query isEmpty', () {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);

    final dogOne = Dog("Pupu", age: 1);
    final dogTwo = Dog("Ostin", age: 2);

    realm.write(() => realm.addAll([dogOne, dogTwo]));

    var dogs = realm.query<Dog>('age == 0');
    expect(dogs.isEmpty, true);

    dogs = realm.query<Dog>('age == 1');
    expect(dogs.isEmpty, false);

    realm.write(() => realm.deleteMany(dogs));
    expect(dogs.isEmpty, true);

    dogs = realm.all<Dog>();
    expect(dogs.isEmpty, false);
  });

  test('Results get by index', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final car = Car('');
    realm.write(() => realm.add(car));

    final cars = realm.all<Car>();
    expect(cars[0].make, car.make);
  });

  test('Results requested wrong index throws', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final cars = realm.all<Car>();

    expect(() => cars[0], throws<RangeError>());
  });

  test('Results iteration test', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    //Create two teams
    realm.write(() {
      realm.add(Team("team One"));
      realm.add(Team("team Two"));
    });

    //Reload teams from realm and ensure they exist
    var teams = realm.all<Team>();
    expect(teams.length, 2);

    //Iterate through teams and add realm objects to a list
    List<Team> list = [];
    for (Team team in teams) {
      list.add(team);
    }

    //Ensure list size is the same like teams collection size
    expect(list.length, teams.length);
  });

  test('Results snapshot iteration test', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    //Create two teams
    realm.write(() {
      realm.add(Team("team One"));
      realm.add(Team("team Two"));
    });

    //Reload teams from realm and ensure they exist
    var teams = realm.all<Team>();
    expect(teams.length, 2);

    //Adding new teams to real while iterating through them.
    //Iterator use a snapshot of results collection and ignores newly added teams.
    List<Team> list = [];
    for (Team team in teams) {
      list.add(team);
      realm.write(() {
        realm.add(Team("new team"));
      });
    }
    //Ensure list size is the same like teams collection size was at the beginnig
    expect(list.length, 2);

    //Ensure teams collection is increased
    expect(teams.length, 4);

    //Iterating teams again will create a snapshot with the newly added items
    list.clear();
    for (Team team in teams) {
      list.add(team);
    }
    expect(list.length, teams.length);
  });

  test('Results query', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    realm.write(() => realm
      ..add(Car("Audi"))
      ..add(Car("Tesla")));
    final cars = realm.all<Car>().query('make == "Tesla"');
    expect(cars.length, 1);
    expect(cars[0].make, "Tesla");
  });

  test('Results query with parameter', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    realm.write(() => realm
      ..add(Car("Audi"))
      ..add(Car("Tesla")));
    final cars = realm.all<Car>().query(r'make == $0', ['Tesla']);
    expect(cars.length, 1);
    expect(cars[0].make, "Tesla");
  });

  test('Results query with multiple parameters', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    final p1 = Person('p1');
    final p2 = Person('p2');
    final t1 = Team("A1", players: [p1]); // match
    final t2 = Team("A2", players: [p2]); // correct prefix, but wrong player
    final t3 = Team("B1", players: [p1, p2]); // wrong prefix, but correct player

    realm.write(() => realm.addAll([t1, t2, t3]));

    expect(t1.players, [p1]);
    expect(t2.players, [p2]);
    expect(t3.players, [p1, p2]);

    final filteredTeams = realm.all<Team>().query(r'$0 IN players AND name BEGINSWITH $1', [p1, 'A']);
    expect(filteredTeams.length, 1);
    expect(filteredTeams, [t1]);
  });

  test('Query results with no arguments throws', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    realm.write(() => realm.add(Car("Audi")));
    expect(() => realm.all<Car>().query(r'make == $0'), throws<RealmException>("no arguments are provided"));
  });

  test('Results query with wrong argument types (int for string) throws', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    realm.write(() => realm.add(Car("Audi")));
    expect(() => realm.all<Car>().query(r'make == $0', [1]), throws<RealmException>("Cannot compare argument"));
  });

  test('Results query with wrong argument types (bool for int) throws ', () {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);
    realm.write(() => realm.add(Dog("Foxi")));
    expect(() => realm.all<Dog>().query(r'age == $0', [true]), throws<RealmException>("Cannot compare argument"));
  });

  test('Results sort', () {
    var config = Configuration.local([Person.schema]);
    var realm = getRealm(config);

    realm.write(() => realm.addAll([
          Person("Michael"),
          Person("Sebastian"),
          Person("Kimi"),
        ]));

    final result = realm.query<Person>('TRUEPREDICATE SORT(name ASC)');
    final resultNames = result.map((p) => p.name).toList();
    final sortedNames = [...resultNames]..sort();
    expect(resultNames, sortedNames);
  });

  test('Results sort order is preserved', () {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);

    final dog1 = Dog("Bella", age: 1);
    final dog2 = Dog("Fido", age: 2);
    final dog3 = Dog("Oliver", age: 3);

    realm.write(() => realm.addAll([dog1, dog2, dog3]));
    var result = realm.query<Dog>('TRUEPREDICATE SORT(name ASC)');
    final snapshot = result.toList();

    expect(result, orderedEquals(snapshot));
    expect(result.map((d) => d.name), snapshot.map((d) => d.name));
    result = realm.query<Dog>('TRUEPREDICATE SORT(name ASC)'); // redoing query won't change that
    expect(result, orderedEquals(snapshot));
    expect(result.map((d) => d.name), snapshot.map((d) => d.name));

    realm.write(() => realm.delete(dog1));
    expect(() => snapshot[0].name, throws<RealmException>());
    snapshot.removeAt(0); // remove dead object

    expect(result, orderedEquals(snapshot));
    expect(result.map((d) => d.name), snapshot.map((d) => d.name));

    realm.write(() => realm.add(Dog("Bella", age: 4)));

    expect(result, isNot(orderedEquals(snapshot)));
    expect(result, containsAllInOrder(snapshot));
  });

  test('Results - get query length after realm is closed throws', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    var team = Team("TeamOne");
    realm.write(() => realm.add(team));
    final teams = realm.query<Team>('name BEGINSWITH "Team"');
    realm.close();
    expect(() => teams.length, throws<RealmException>("Access to invalidated Results objects"));
  });

  test('Results - query with null', () {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);

    var ben = Person('Ben');
    final fido = Dog('Fido', owner: ben);
    final laika = Dog('Laika'); // no owner;
    realm.write(() {
      realm.addAll([fido, laika]);
    });
    expect(realm.query<Dog>(r'owner = $0', [ben]), [fido]);
    expect(realm.query<Dog>(r'owner = $0', [null]), [laika]);
  });

  test('Results access after realm closed throws', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    var team = Team("TeamOne");
    realm.write(() => realm.add(team));
    var teams = realm.all<Team>();
    realm.close();
    expect(() => teams[0], throws<RealmException>("Access to invalidated Results objects"));
  });

  test('Realm deleteMany from results', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    //Create two teams
    realm.write(() {
      realm.add(Team("Ferrari"));
      realm.add(Team("Maserati"));
    });

    //Ensule teams exist in realm
    var teams = realm.all<Team>();
    expect(teams.length, 2);

    //Delete all objects in realmResults from realm
    realm.write(() => realm.deleteMany(teams));
    expect(teams.length, 0);

    //Reload teams from realm and ensure they are deleted
    teams = realm.all<Team>();
    expect(teams.length, 0);
  });

  test('Results notifications', () async {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);

    realm.write(() {
      realm.add(Dog("Fido"));
      realm.add(Dog("Fido1"));
      realm.add(Dog("Fido2"));
    });

    var firstCall = true;
    final subscription = realm.all<Dog>().changes.listen((changes) {
      if (firstCall) {
        firstCall = false;
        expect(changes.inserted.isEmpty, true);
        expect(changes.modified.isEmpty, true);
        expect(changes.deleted.isEmpty, true);
        expect(changes.newModified.isEmpty, true);
        expect(changes.moved.isEmpty, true);
      } else {
        expect(changes.inserted, [3]); //new object at index 3
        expect(changes.modified, [0]); //object at index 0 changed
        expect(changes.deleted.isEmpty, true);
        expect(changes.newModified, [0]);
        expect(changes.moved.isEmpty, true);
      }
    });

    await Future<void>.delayed(const Duration(milliseconds: 20));
    realm.write(() {
      realm.all<Dog>().first.age = 2;
      realm.add(Dog("Fido4"));
    });

    await Future<void>.delayed(const Duration(milliseconds: 20));
    subscription.cancel();

    await Future<void>.delayed(const Duration(milliseconds: 20));
  });

  test('Results notifications can be paused', () async {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);

    realm.write(() {
      realm.add(Dog("Lassy"));
    });

    var callbackCalled = false;
    final subscription = realm.all<Dog>().changes.listen((changes) {
      callbackCalled = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(callbackCalled, true);

    subscription.pause();
    callbackCalled = false;
    realm.write(() {
      realm.add(Dog("Lassy1"));
    });

    expect(callbackCalled, false);

    await Future<void>.delayed(const Duration(milliseconds: 20));
    await subscription.cancel();

    await Future<void>.delayed(const Duration(milliseconds: 20));
  });

  test('Results notifications can be resumed', () async {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);

    var callbackCalled = false;
    final subscription = realm.all<Dog>().changes.listen((changes) {
      callbackCalled = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(callbackCalled, true);

    subscription.pause();
    callbackCalled = false;
    realm.write(() {
      realm.add(Dog("Lassy"));
    });
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(callbackCalled, false);

    subscription.resume();
    callbackCalled = false;
    realm.write(() {
      realm.add(Dog("Lassy1"));
    });
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(callbackCalled, true);

    await subscription.cancel();
    await Future<void>.delayed(const Duration(milliseconds: 20));
  });

  test('Results notifications can leak', () async {
    final config = Configuration.local([Dog.schema, Person.schema]);
    final realm = getRealm(config);

    final leak = realm.all<Dog>().changes.listen((data) {});
    await Future<void>.delayed(const Duration(milliseconds: 20));
  });

  test('Results.freeze freezes query', () {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    realm.write(() {
      realm.add(Person('Peter'));
    });

    final livePeople = realm.all<Person>();
    final frozenPeople = freezeResults(livePeople);

    expect(frozenPeople.length, 1);
    expect(frozenPeople.isFrozen, true);
    expect(frozenPeople.realm.isFrozen, true);
    expect(frozenPeople.single.isFrozen, true);

    realm.write(() {
      livePeople.single.name = 'Peter II';
      realm.add(Person('George'));
    });

    expect(livePeople.length, 2);
    expect(livePeople.first.name, 'Peter II');
    expect(frozenPeople.length, 1);
    expect(frozenPeople.single.name, 'Peter');
  });

  test("FrozenResults.changes throws", () {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    final frozenPeople = freezeResults(realm.all<Person>());

    expect(() => frozenPeople.changes, throws<RealmStateError>('Results are frozen and cannot emit changes'));
  });

  test('Results.freeze when frozen returns same object', () {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    final people = realm.all<Person>();

    final frozenPeople = freezeResults(people);
    final deepFrozenPeople = freezeResults(frozenPeople);

    expect(identical(frozenPeople, deepFrozenPeople), true);

    final frozenPeopleAgain = freezeResults(people);
    expect(identical(frozenPeople, frozenPeopleAgain), false);
  });

  test('Results.query', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];

    final team = Team('Class of 92', players: [alice, bob]);

    realm.write(() {
      realm.addAll(players);
      return realm.add(team);
    });

    expect(realm.all<Person>(), [alice, bob, carol, dan]);
    expect(realm.query<Person>('FALSEPREDICATE').query('TRUEPREDICATE'), isEmpty);
    expect(realm.query<Person>('FALSEPREDICATE').query('TRUEPREDICATE'), isNot(realm.all<Person>()));
    expect(realm.query<Person>("name CONTAINS 'a'"), [carol, dan]); // Alice is capital 'a'
    expect(realm.query<Person>("name CONTAINS 'l'"), [alice, carol]);
    expect(realm.query<Person>("name CONTAINS 'a'").query("name CONTAINS 'l'"), isNot([alice, carol]));
    expect(realm.query<Person>("name CONTAINS 'a'").query("name CONTAINS 'l'"), [carol]);
  });

  test('Results of primitives', () {
    var config = Configuration.local([Player.schema, Game.schema]);
    var realm = getRealm(config);

    final scores = [-1, null, 0, 1];
    final alice = Player('Alice', scoresByRound: scores);
    realm.write(() => realm.add(alice));

    expect(alice.scoresByRound, scores);
    expect(alice.scoresByRound.asResults(), scores);
  });

  test('Results of primitives notifications', () {
    var config = Configuration.local([Player.schema, Game.schema]);
    var realm = getRealm(config);

    final scores = [-1, null, 0, 1];
    final alice = Player('Alice', scoresByRound: scores);
    realm.write(() => realm.add(alice));

    final results = alice.scoresByRound.asResults();
    expectLater(
        results.changes,
        emitsInOrder(<Matcher>[
          isA<RealmResultsChanges>().having((ch) => ch.inserted, 'inserted', <int>[]),
          isA<RealmResultsChanges>().having((ch) => ch.inserted, 'inserted', [4]),
          isA<RealmResultsChanges>() //
              .having((ch) => ch.inserted, 'inserted', [0]) //
              .having((ch) => ch.deleted, 'deleted', [1]),
          isA<RealmResultsChanges>().having((ch) => ch.deleted, 'deleted', [2, 4]),
        ]));

    realm.write(() => alice.scoresByRound.add(2));
    realm.write(() {
      alice.scoresByRound.insert(0, 3);
      alice.scoresByRound.remove(null);
    });
    realm.write(() {
      alice.scoresByRound.removeAt(2);
      alice.scoresByRound.removeAt(3); // index 4 in old list
    });
  });

  test('List.asResults().query', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');

    final team = realm.write(() {
      return realm.add(Team('Class of 92', players: [alice, bob, carol, dan]));
    });

    final playersAsResults = team.players.asResults();

    expect(playersAsResults, [alice, bob, carol, dan]);
    expect(playersAsResults.query('FALSEPREDICATE').query('TRUEPREDICATE'), isEmpty);
    expect(playersAsResults.query('FALSEPREDICATE').query('TRUEPREDICATE'), isNot(realm.all<Person>()));
    expect(playersAsResults.query("name CONTAINS 'a'"), [carol, dan]); // Alice is capital 'a'
    expect(playersAsResults.query("name CONTAINS 'l'"), [alice, carol]);
    expect(playersAsResults.query("name CONTAINS 'a'").query("name CONTAINS 'l'"), isNot([alice, carol]));
    expect(playersAsResults.query("name CONTAINS 'a'").query("name CONTAINS 'l'"), [carol]);

    expect(() => realm.write(() => realm.deleteMany(playersAsResults.query("name CONTAINS 'a'"))), returnsNormally);
    expect(team.players, [alice, bob]); // Alice is capital 'a'
  });

  test('Results.query with remapped property', () {
    final config = Configuration.local([RemappedClass.schema]);
    final realm = getRealm(config);

    realm.write(() {
      realm.add(RemappedClass('Peter'));
      realm.add(RemappedClass('George'));
    });

    final queryByModelName = realm.query<RemappedClass>('remappedProperty = "Peter"');
    expect(queryByModelName.single.remappedProperty, 'Peter');

    final queryByInternalName = realm.query<RemappedClass>('primitive_property = "Peter"');
    expect(queryByInternalName.single.remappedProperty, 'Peter');
  });

  test('RealmResults.changes - await for with yield ', () async {
    final config = Configuration.local([Dog.schema, Person.schema]);
    final realm = getRealm(config);

    final wait = const Duration(seconds: 1);

    Stream<bool> trueWaitFalse() async* {
      yield true;
      await Future<void>.delayed(wait);
      yield false; // nothing has happened in the meantime
    }

    // ignore: prefer_function_declarations_over_variables
    final awaitForWithYield = () async* {
      await for (final c in realm.all<Dog>().changes) {
        yield c;
      }
    };

    int count = 0;
    await for (final c in awaitForWithYield().map((_) => trueWaitFalse()).switchLatest()) {
      if (!c) break; // saw false after waiting
      ++count; // saw true due to new event from changes
      if (count > 1) fail('Should only receive one event');
    }
  });

  test('RealmResults.isValid', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');

    final team = realm.write(() {
      return realm.add(Team('Class of 92', players: [alice, bob, carol, dan]));
    });

    final players = team.players;
    final playersAsResults = team.players.asResults();

    expect(players.isValid, isTrue);
    expect(playersAsResults.isValid, isTrue);
    expect(playersAsResults, [alice, bob, carol, dan]);

    realm.write(() => realm.delete(team));

    expect(team.isValid, isFalse); // dead object
    expect(players.isValid, isFalse); // parent is dead
    expect(() => players.isEmpty, throwsException); // illegal to access properties on dead object
    expect(playersAsResults.isValid, isTrue); // Results are still valid..
    expect(playersAsResults, isEmpty); // .. but obviously empty
    expect(() => playersAsResults.freeze(), returnsNormally);
    final frozeResults = playersAsResults.freeze();
    expect(frozeResults.isFrozen, isTrue);
    expect(frozeResults, isEmpty);
  });

  test('query by condition on decimal128', () {
    final config = Configuration.local([ObjectWithDecimal.schema]);
    final realm = getRealm(config);

    final small = Decimal128.fromInt(1);
    final big = Decimal128.fromInt(1 << 62) * Decimal128.fromInt(1 << 62);

    realm.write(() => realm.addAll([
          ObjectWithDecimal(small),
          ObjectWithDecimal(big),
        ]));

    expect(realm.query<ObjectWithDecimal>(r'decimal < $0', [small]), isEmpty);
    expect(realm.query<ObjectWithDecimal>(r'decimal < $0', [big]).map((e) => e.decimal), [small]);
    expect(realm.query<ObjectWithDecimal>(r'decimal <= $0', [big]).map((e) => e.decimal), [small, big]);
    expect(realm.query<ObjectWithDecimal>(r'decimal == $0', [small]).map((e) => e.decimal), [small]);
    expect(realm.query<ObjectWithDecimal>(r'decimal == $0', [big]).map((e) => e.decimal), [big]);
    expect(realm.query<ObjectWithDecimal>(r'decimal > $0', [big]), isEmpty);
    expect(realm.query<ObjectWithDecimal>(r'decimal > $0', [small]).map((e) => e.decimal), [big]);
    expect(realm.query<ObjectWithDecimal>(r'decimal >= $0', [small]).map((e) => e.decimal), [small, big]);
  });

  test('Query parser works with long query string with OR/AND', () async {
    final config = Configuration.local([Product.schema]);
    final realm = getRealm(config);
    List<String> list = [];
    for (var i = 0; i <= 1500; i++) {
      list.add("_id == oid(${ObjectId()})");
    }
    final ids = list.join(" OR ");
    final result = realm.query<Product>(ids);
    expect(result.length, 0);
  });

  test('Query parser works with IN clause and large set of items ', () async {
    final config = Configuration.local([Product.schema]);
    final realm = getRealm(config);
    List<String> list = [];
    for (var i = 0; i < 1500; i++) {
      list.add("oid(${ObjectId()})");
    }
    final ids = "_id IN {${list.join(",")}}";
    final items = realm.query<Product>(ids);
    expect(items.length, 0);
  });

  test('RealmResults.first throws on empty', () async {
    final config = Configuration.local([Dog.schema, Person.schema]);
    final realm = getRealm(config);

    final empty = Iterable<int>.empty();
    // To illustrate the behavior of Iterable.single on a regular iterable
    expect(() => empty.first, throws<StateError>('No element'));

    expect(() => realm.all<Dog>().first, throws<StateError>('No element'));
    expect(() => realm.all<Dog>().first, throws<RealmStateError>('No element'));
  });

  test('RealmResults.last throws on empty', () async {
    final config = Configuration.local([Dog.schema, Person.schema]);
    final realm = getRealm(config);

    final empty = Iterable<int>.empty();
    // To illustrate the behavior of Iterable.single on a regular iterable
    expect(() => empty.last, throws<StateError>('No element'));

    expect(() => realm.all<Dog>().last, throws<StateError>('No element'));
    expect(() => realm.all<Dog>().last, throws<RealmStateError>('No element'));
  });

  test('RealmResult.single throws on empty', () {
    final config = Configuration.local([Dog.schema, Person.schema]);
    final realm = getRealm(config);

    final empty = Iterable<int>.empty();
    // To illustrate the behavior of Iterable.single on a regular iterable
    expect(() => empty.single, throws<StateError>('No element'));

    expect(() => realm.all<Dog>().single, throws<StateError>('No element'));
    expect(() => realm.all<Dog>().single, throws<RealmStateError>('No element'));
  });

  test('RealmResult.single throws on two items', () {
    final config = Configuration.local([Dog.schema, Person.schema]);
    final realm = getRealm(config);

    final twoItems = [1, 2];
    // To illustrate the behavior of Iterable.single on a regular list
    expect(() => twoItems.single, throws<StateError>('Too many elements'));

    realm.write(() => realm.addAll([Dog('Fido'), Dog('Spot')]));
    expect(() => realm.all<Dog>().single, throws<StateError>('Too many elements'));
    expect(() => realm.all<Dog>().single, throws<RealmStateError>('Too many elements'));
  });

  test('Query with argument lists of different types and null', () {
    final id_1 = ObjectId();
    final id_2 = ObjectId();
    final uid_1 = Uuid.v4();
    final uid_2 = Uuid.v4();
    final date_1 = DateTime.now().add(const Duration(days: 1));
    final date_2 = DateTime.now().add(const Duration(days: 2));
    final text_1 = generateRandomUnicodeString();

    final config = Configuration.local([AllTypes.schema]);
    Realm realm = getRealm(config);
    realm.write(() => realm.addAll([
          AllTypes(text_1, false, DateTime.now(), 1.1, id_1, uid_1, 1, Decimal128.one, Uint8List.fromList([1, 2])),
          AllTypes('text2', true, date_1, 2.2, id_2, uid_2, 2, Decimal128.ten, Uint8List(16)),
          AllTypes('text3', true, date_2, 3.3, ObjectId(), Uuid.v4(), 3, Decimal128.infinity, Uint8List.fromList([3, 4])),
        ]));

    void queryWithListArg(String propName, Object? argument, {int expected = 0}) {
      final results = realm.query<AllTypes>("$propName IN \$0", [argument]);
      expect(results.length, expected);
    }

    queryWithListArg("stringProp", [null, text_1, 'text3'], expected: 2);
    queryWithListArg("nullableStringProp", [null, 'text2'], expected: 3);

    queryWithListArg("boolProp", [false, true, null], expected: 3);
    queryWithListArg("nullableBoolProp", [null], expected: 3);

    queryWithListArg("dateProp", [date_1, null, date_2], expected: 2);
    queryWithListArg("nullableDateProp", [null], expected: 3);

    queryWithListArg("doubleProp", [1.1, null, 3.3], expected: 2);
    queryWithListArg("nullableDoubleProp", [null], expected: 3);

    queryWithListArg("objectIdProp", [id_1, id_2, null], expected: 2);
    queryWithListArg("nullableObjectIdProp", [null], expected: 3);

    queryWithListArg("uuidProp", [uid_1, uid_2, null], expected: 2);
    queryWithListArg("nullableUuidProp", [null], expected: 3);

    queryWithListArg("intProp", [1, 2, null], expected: 2);
    queryWithListArg("nullableIntProp", [null], expected: 3);

    queryWithListArg("decimalProp", [Decimal128.one, null], expected: 1);
    queryWithListArg("nullableDecimalProp", [null], expected: 3);

    queryWithListArg(
        "binaryProp",
        [
          Uint8List.fromList([1, 2]),
          null,
          Uint8List(16)
        ],
        expected: 2);

    queryWithListArg("nullableBinaryProp", [null], expected: 3);
  });

  test('Query with list, sets and iterable arguments', () {
    final config = Configuration.local([Person.schema]);
    Realm realm = getRealm(config);
    realm.write(() => realm.addAll([
          Person('Ani'),
          Person('Teddy'),
          Person('Poly'),
        ]));

    final listOfNames = ['Ani', 'Teddy'];
    var result = realm.query<Person>(r'name IN $0', [listOfNames]);
    expect(result.length, 2);

    final setOfNames = {'Poly', 'Teddy'};
    result = realm.query<Person>(r'name IN $0', [setOfNames]);
    expect(result.length, 2);

    final iterableNames = result.map((e) => e.name);
    result = realm.query<Person>(r'name IN $0', [iterableNames]);
    expect(result.length, 2);

    result = realm.query<Person>(r'name IN $0 || name IN $1 || name IN $2', [listOfNames, setOfNames, iterableNames]);
    expect(result.length, 3);
  });

  test('Query with ANY, ALL and NONE operators with iterable arguments', () {
    final config = Configuration.local([School.schema, Student.schema]);
    final realm = getRealm(config);

    realm.write(() => realm.addAll([
          School('primary school 1', branches: [
            School('131', city: "NY city"),
            School('144', city: "Garden city"),
            School('128'),
          ]),
          School('secondary school 1', students: [
            Student(1, name: 'NP'),
            Student(2, name: 'KR'),
          ]),
        ]));

    var result = realm.query<School>(r'ANY $0 IN branches.city', [
      ["NY city"]
    ]);
    expect(result.length, 1);
    expect(result.first.name, 'primary school 1');

    result = realm.query<School>(r'ALL $0 IN branches.city', [
      ["NY city", "Garden city", null]
    ]);
    expect(result.length, 1);
    expect(result.first.name, 'primary school 1');

    result = realm.query<School>(r'students.@count > $0 && NONE $1 IN students.name', [
      0,
      {'Non-existing name', null}
    ]);
    expect(result.length, 1);
    expect(result.first.name, 'secondary school 1');
  });

  test('RealmResults.skip', () {
    final config = Configuration.local([Task.schema]);
    final realm = getRealm(config);
    const max = 10;
    realm.write(() {
      realm.addAll(List.generate(max, (_) => Task(ObjectId())));
    });

    final results = realm.all<Task>();
    for (var i = 0; i < max; i++) {
      expect(results.skip(i).length, max - i);
      for (var j = 0; j < max - i; j++) {
        expect(results.skip(i)[j], results[i + j]);
        expect(results.skip(i).skip(j)[0], results[i + j]); // chained skip
      }
      expect(
        () => results.skip(max + i + 1),
        throwsA(isA<RangeError>().having((e) => e.invalidValue, 'count', max + i + 1)),
      );
      expect(
        () => results.skip(-i - 1),
        throwsA(isA<RangeError>().having((e) => e.invalidValue, 'count', -i - 1)),
      );
    }
  });

  test('_RealmResultsIterator', () {
    // behavior of normal iterator
    final list = [1];
    final it = list.iterator;
    // you are not supposed to call current before first moveNext
    expect(() => it.current, throwsA(isA<TypeError>()));
    expect(it.moveNext(), isTrue);
    expect(it.moveNext(), isFalse);
    // you are not supposed to call current, if moveNext return false
    expect(() => it.current, throwsA(isA<TypeError>()));

    // behavior of _RealmResultsIterator
    final config = Configuration.local([Task.schema]);
    final realm = getRealm(config);
    realm.write(() {
      realm.add(Task(ObjectId()));
    });
    final results = realm.all<Task>();
    expect(results.length, 1);
    final rit = results.iterator;

    // you are not supposed to call current before first moveNext
    expect(() => rit.current, throwsA(isA<RangeError>()));
    expect(rit.moveNext(), isTrue);
    expect(rit.moveNext(), isFalse);
    // you are not supposed to call current, if moveNext return false
    expect(() => rit.current, throwsA(isA<RangeError>()));
  });

  test('RealmResults.indexOf', () {
    final config = Configuration.local([Task.schema]);
    final realm = getRealm(config);
    const max = 10;
    realm.write(() {
      realm.addAll(List.generate(max, (_) => Task(ObjectId())));
    });

    final results = realm.all<Task>();
    expect(() => results.indexOf(Task(ObjectId())), throws<RealmStateError>());
    int i = 0;
    for (final t in results) {
      expect(results.indexOf(t), i++);
    }
  });

  test('RealmResults.contains', () {
    final config = Configuration.local([Task.schema]);
    final realm = getRealm(config);
    const max = 10;
    final tasks = List.generate(max, (_) => Task(ObjectId()));
    realm.write(() {
      realm.addAll(tasks);
    });

    final all = realm.all<Task>();
    final none = realm.query<Task>('FALSEPREDICATE');

    expect(() => all.contains(Task(ObjectId())), throws<RealmStateError>());
    // ignore: unnecessary_cast, iterable_contains_unrelated_type
    expect(() => (all as Iterable<Task>).contains(1), throwsA(isA<TypeError>()));

    int i = 0;
    for (final t in all) {
      expect(all.contains(t), isTrue);
      expect(none.contains(t), isFalse);
    }

    for (int i = 0; i < max; i++) {
      for (var j = 0; j < max - i; j++) {
        expect(all.skip(i).contains(tasks[i + j]), true);
        expect(all.skip(i + j + 1).contains(tasks[i + j]), false);
      }
    }
  });

  test('RealmResults.skip().take()', () {
    final config = Configuration.local([Task.schema]);
    final realm = getRealm(config);
    const max = 10;
    realm.write(() {
      realm.addAll(List.generate(max, (_) => Task(ObjectId())));
    });

    final results = realm.all<Task>();

    expect(results.skip(2), results.toList().sublist(2));
    expect(results.skip(2).take(3), [results[2], results[3], results[4]]);
  });
}
