// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: unused_local_variable, avoid_relative_lib_imports

import 'dart:typed_data';
import 'package:realm_dart/realm.dart';

import 'test.dart';

part 'realm_object_test.realm.dart';

@RealmModel()
class _ObjectIdPrimaryKey {
  @PrimaryKey()
  late ObjectId id;
}

@RealmModel()
class _NullableObjectIdPrimaryKey {
  @PrimaryKey()
  late ObjectId? id;
}

@RealmModel()
class _IntPrimaryKey {
  @PrimaryKey()
  late int id;
}

@RealmModel()
class _NullableIntPrimaryKey {
  @PrimaryKey()
  int? id;
}

@RealmModel()
class _StringPrimaryKey {
  @PrimaryKey()
  late String id;
}

@RealmModel()
class _NullableStringPrimaryKey {
  @PrimaryKey()
  late String? id;
}

@RealmModel()
class _UuidPrimaryKey {
  @PrimaryKey()
  late Uuid id;
}

@RealmModel()
class _NullableUuidPrimaryKey {
  @PrimaryKey()
  late Uuid? id;
}

@RealmModel()
@MapTo('class with spaces')
class _RemappedFromAnotherFile {
  @MapTo("property with spaces")
  late $RemappedClass? linkToAnotherClass;
}

@RealmModel()
class _BoolValue {
  @PrimaryKey()
  late int key;

  late bool value;
}

@RealmModel()
class _TestNotificationObject {
  late String? stringProperty;

  late int? intProperty;

  @MapTo("_remappedIntProperty")
  late int? remappedIntProperty;

  late _TestNotificationObject? link;

  late _TestNotificationEmbeddedObject? embedded;

  late List<_TestNotificationObject> listLinks;

  late Set<_TestNotificationObject> setLinks;

  late Map<String, _TestNotificationObject?> mapLinks;

  @Backlink(#link)
  late Iterable<_TestNotificationObject> backlink;
}

@RealmModel(ObjectType.embeddedObject)
class _TestNotificationEmbeddedObject {
  late String? stringProperty;

  late int? intProperty;
}

void main() {
  setupTests();

  group("RealmObject keypath filtering", () {
    Future<void> verifyNotifications<T extends RealmObjectBase>(T obj, List<RealmObjectChanges<T>> changeList, List<String>? changedProperties,
        {bool isDeleted = false}) async {
      await Future<void>.delayed(Duration(milliseconds: 20));

      if (changedProperties == null) {
        expect(changeList, hasLength(0));
        return;
      }

      expect(changeList, hasLength(1));
      var changes = changeList[0];

      if (isDeleted) {
        expect(changes.isDeleted, isTrue);
        return;
      }

      expect(changes.isDeleted, isFalse);
      expect(changes.object, obj);
      expect(changes.properties, unorderedEquals(changedProperties));
      changeList.clear();
    }

    test('basic single keypath test', () async {
      var config = Configuration.local([Dog.schema, Person.schema]);
      var realm = getRealm(config);

      final dog = Dog("Mario");

      realm.write(() {
        realm.add(dog);
      });

      final externalChanges = <RealmObjectChanges<Dog>>[];
      final subscription = dog.changesFor(["age"]).listen((changes) {
        if (changes.properties.isNotEmpty) externalChanges.add(changes);
      });

      realm.write(() {
        dog.age = 2;
        dog.owner = Person("owner");
      });

      await verifyNotifications<Dog>(dog, externalChanges, ["age"]);
      subscription.cancel();
    });

    test('basic multiple keypaths test', () async {
      var config = Configuration.local([Dog.schema, Person.schema]);
      var realm = getRealm(config);

      final dog = Dog("Mario");

      realm.write(() {
        realm.add(dog);
      });

      final externalChanges = <RealmObjectChanges<Dog>>[];
      final subscription = dog.changesFor(["age", "owner"]).listen((changes) {
        if (changes.properties.isNotEmpty) externalChanges.add(changes);
      });

      realm.write(() {
        dog.age = 2;
        dog.owner = Person("owner");
      });

      await verifyNotifications<Dog>(dog, externalChanges, ["age", "owner"]);
      subscription.cancel();
    });

    test('empty or whitespace keypath', () async {
      var config = Configuration.local([Dog.schema, Person.schema]);
      var realm = getRealm(config);

      final dog = Dog("Mario");

      realm.write(() {
        realm.add(dog);
      });

      expect(() {
        dog.changesFor([""]);
      }, throws<RealmException>("None of the key paths provided can be empty or consisting only of white spaces"));

      expect(() {
        dog.changesFor(["age", " "]);
      }, throws<RealmException>("None of the key paths provided can be empty or consisting only of white spaces"));
    });

    test('unknown keypath', () async {
      var config = Configuration.local([Dog.schema, Person.schema]);
      var realm = getRealm(config);

      final dog = Dog("Mario");

      realm.write(() {
        realm.add(dog);
      });

      expect(() {
        dog.changesFor(["unknown"]);
      }, throws<RealmException>("Property 'unknown' in KeyPath 'unknown' is not a valid property in Dog."));

      expect(() {
        dog.changesFor(["age", "unknown"]);
      }, throws<RealmException>("Property 'unknown' in KeyPath 'unknown' is not a valid property in Dog."));
    });

    test('embedded', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema]);
      var realm = getRealm(config);

      final tno = TestNotificationObject();

      realm.write(() {
        realm.add(tno);
      });

      final externalChanges = <RealmObjectChanges<TestNotificationObject>>[];
      final subscription = tno.changesFor(["embedded"]).listen((changes) {
        if (changes.properties.isNotEmpty) externalChanges.add(changes);
      });

      // Property change
      realm.write(() {
        tno.embedded = TestNotificationEmbeddedObject();
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["embedded"]);

      // Nested property change -- should not raise
      realm.write(() {
        tno.embedded?.stringProperty = "NewVal";
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, null);

      subscription.cancel();
    });

    test('nested property on embedded', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema]);
      var realm = getRealm(config);

      final tno = TestNotificationObject();

      realm.write(() {
        realm.add(tno);
      });

      final externalChanges = <RealmObjectChanges<TestNotificationObject>>[];
      final subscription = tno.changesFor(["embedded.stringProperty"]).listen((changes) {
        if (changes.properties.isNotEmpty) externalChanges.add(changes);
      });

      // Property change
      realm.write(() {
        tno.embedded = TestNotificationEmbeddedObject();
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["embedded"]);

      // Nested property change in keypath -- should raise
      realm.write(() {
        tno.embedded?.stringProperty = "NewVal";
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["embedded"]);

      // Nested property change not on keypath -- should not raise
      realm.write(() {
        tno.embedded?.intProperty = 23;
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, null);

      subscription.cancel();
    });

    test('link', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema]);
      var realm = getRealm(config);

      final tno = TestNotificationObject();

      realm.write(() {
        realm.add(tno);
      });

      final externalChanges = <RealmObjectChanges<TestNotificationObject>>[];
      final subscription = tno.changesFor(["link"]).listen((changes) {
        if (changes.properties.isNotEmpty) externalChanges.add(changes);
      });

      // Property change
      realm.write(() {
        tno.link = TestNotificationObject();
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["link"]);

      // Nested property change -- should not raise
      realm.write(() {
        tno.link?.stringProperty = "NewVal";
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, null);

      subscription.cancel();
    });

    test('nested property on link', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema]);
      var realm = getRealm(config);

      final tno = TestNotificationObject();

      realm.write(() {
        realm.add(tno);
      });

      final externalChanges = <RealmObjectChanges<TestNotificationObject>>[];
      final subscription = tno.changesFor(["link.stringProperty"]).listen((changes) {
        if (changes.properties.isNotEmpty) externalChanges.add(changes);
      });

      // Top level property change
      realm.write(() {
        tno.link = TestNotificationObject();
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["link"]);

      // Nested property on keypath -- should raise
      realm.write(() {
        tno.link?.stringProperty = "NewVal";
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["link"]);

      // Nested property not on keypath -- should not raise
      realm.write(() {
        tno.link?.intProperty = 23;
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, null);

      subscription.cancel();
    });

    test('mappedProperty', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema]);
      var realm = getRealm(config);

      final tno = TestNotificationObject();

      realm.write(() {
        realm.add(tno);
      });

      final externalChanges = <RealmObjectChanges<TestNotificationObject>>[];
      final subscription = tno.changesFor(["remappedIntProperty"]).listen((changes) {
        if (changes.properties.isNotEmpty) externalChanges.add(changes);
      });

      realm.write(() {
        tno.remappedIntProperty = 23;
        tno.stringProperty = "newVal";
      });

      // This fails because it's raising a notification for "_remappedIntProperty"
      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["remappedIntProperty"]);

      subscription.cancel();
    });

    test('collection top level', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema]);
      var realm = getRealm(config);

      final tno = TestNotificationObject();

      realm.write(() {
        realm.add(tno);
      });

      final externalChanges = <RealmObjectChanges<TestNotificationObject>>[];
      final subscription = tno.changesFor(["listLinks", "setLinks", "mapLinks"]).listen((changes) {
        if (changes.properties.isNotEmpty) externalChanges.add(changes);
      });

      // Collection changes -- should raise
      realm.write(() {
        tno.listLinks.add(TestNotificationObject());
        tno.setLinks.add(TestNotificationObject());
        tno.mapLinks["test"] = TestNotificationObject();
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["listLinks", "setLinks", "mapLinks"]);

      // Nested properties -- should not raise
      realm.write(() {
        tno.listLinks[0].stringProperty = "newVal";
        tno.setLinks.elementAt(0).stringProperty = "newVal";
        tno.mapLinks["test"]?.stringProperty = "newVal";
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, null);

      subscription.cancel();
    });

    test('collection nested', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema]);
      var realm = getRealm(config);

      final tno = TestNotificationObject();

      realm.write(() {
        realm.add(tno);
      });

      final externalChanges = <RealmObjectChanges<TestNotificationObject>>[];
      final subscription = tno.changesFor(["listLinks.stringProperty", "setLinks.stringProperty", "mapLinks.stringProperty"]).listen((changes) {
        if (changes.properties.isNotEmpty) externalChanges.add(changes);
      });

      // Collection changes -- should raise
      realm.write(() {
        tno.listLinks.add(TestNotificationObject());
        tno.setLinks.add(TestNotificationObject());
        tno.mapLinks["test"] = TestNotificationObject();
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["listLinks", "setLinks", "mapLinks"]);

      // Nested properties -- should raise
      realm.write(() {
        tno.listLinks[0].stringProperty = "newVal";
        tno.setLinks.elementAt(0).stringProperty = "newVal";
        tno.mapLinks["test"]?.stringProperty = "newVal";
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["listLinks", "setLinks", "mapLinks"]);

      subscription.cancel();
    });

    test('backlink', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema]);
      var realm = getRealm(config);

      final tno = TestNotificationObject();

      realm.write(() {
        realm.add(tno);
      });

      final externalChanges = <RealmObjectChanges<TestNotificationObject>>[];
      final subscription = tno.changesFor(["backlink"]).listen((changes) {
        if (changes.properties.isNotEmpty) externalChanges.add(changes);
      });

      realm.write(() {
        realm.add(TestNotificationObject(link: tno));
      });

      expect(tno.backlink.length, 1);

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["backlink"]);

      subscription.cancel();
    }, skip: "Needs to be re-enabled when https://github.com/realm/realm-dart/issues/1631 is investigated");

    test('null gives default subscriptions', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema]);
      var realm = getRealm(config);

      final tno = TestNotificationObject();

      realm.write(() {
        realm.add(tno);
      });

      final externalChanges = <RealmObjectChanges<TestNotificationObject>>[];
      final subscription = tno.changesFor(null).listen((changes) {
        if (changes.properties.isNotEmpty) externalChanges.add(changes);
      });

      realm.write(() {
        tno.stringProperty = "test";
        tno.intProperty = 23;
        tno.link = TestNotificationObject();
        tno.listLinks.add(TestNotificationObject());
        tno.setLinks.add(TestNotificationObject());
        tno.mapLinks["test"] = TestNotificationObject();
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["listLinks", "setLinks", "mapLinks", "stringProperty", "intProperty", "link"]);

      realm.write(() {
        tno.link?.stringProperty = "test";
        tno.listLinks[0].stringProperty = "newVal";
        tno.setLinks.elementAt(0).stringProperty = "newVal";
        tno.mapLinks["test"]?.stringProperty = "newVal";
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, null);

      subscription.cancel();
    });

    //TODO Remove skip when https://github.com/realm/realm-core/issues/7805 is solved
    test('empty list gives no subscriptions', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema]);
      var realm = getRealm(config);

      final tno = TestNotificationObject();

      realm.write(() {
        realm.add(tno);
      });

      final externalChanges = <RealmObjectChanges<TestNotificationObject>>[];
      final subscription = tno.changesFor([]).listen((changes) {
        if (changes.properties.isNotEmpty) externalChanges.add(changes);
      });

      realm.write(() {
        tno.stringProperty = "test";
        tno.intProperty = 23;
        tno.link = TestNotificationObject();
        tno.listLinks.add(TestNotificationObject());
        tno.setLinks.add(TestNotificationObject());
        tno.mapLinks["test"] = TestNotificationObject();
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, null);

      realm.write(() {
        tno.link?.stringProperty = "test";
        tno.listLinks[0].stringProperty = "newVal";
        tno.setLinks.elementAt(0).stringProperty = "newVal";
        tno.mapLinks["test"]?.stringProperty = "newVal";
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, null);

      subscription.cancel();
    }, skip: true);

    test('wildcard', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema]);
      var realm = getRealm(config);

      final tno = TestNotificationObject();

      realm.write(() {
        realm.add(tno);
      });

      final externalChanges = <RealmObjectChanges<TestNotificationObject>>[];
      final subscription = tno.changesFor(["*"]).listen((changes) {
        if (changes.properties.isNotEmpty) externalChanges.add(changes);
      });

      realm.write(() {
        tno.stringProperty = "test";
        tno.intProperty = 23;
        tno.link = TestNotificationObject();
        tno.listLinks.add(TestNotificationObject());
        tno.setLinks.add(TestNotificationObject());
        tno.mapLinks["test"] = TestNotificationObject();
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["listLinks", "setLinks", "mapLinks", "stringProperty", "intProperty", "link"]);

      // Deeper than the top level wildcard - should not raise
      realm.write(() {
        tno.listLinks[0].stringProperty = "newVal";
        tno.setLinks.elementAt(0).stringProperty = "newVal";
        tno.mapLinks["test"]?.stringProperty = "newVal";
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, null);

      subscription.cancel();
    });

    test('nested wildcard', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema]);
      var realm = getRealm(config);

      final tno = TestNotificationObject();

      realm.write(() {
        realm.add(tno);
      });

      final externalChanges = <RealmObjectChanges<TestNotificationObject>>[];
      final subscription = tno.changesFor(["*.*"]).listen((changes) {
        if (changes.properties.isNotEmpty) externalChanges.add(changes);
      });

      realm.write(() {
        tno.stringProperty = "test";
        tno.intProperty = 23;
        tno.link = TestNotificationObject();
        tno.listLinks.add(TestNotificationObject());
        tno.setLinks.add(TestNotificationObject());
        tno.mapLinks["test"] = TestNotificationObject();
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["listLinks", "setLinks", "mapLinks", "stringProperty", "intProperty", "link"]);

      realm.write(() {
        tno.link?.stringProperty = "test";
        tno.listLinks[0].stringProperty = "newVal";
        tno.setLinks.elementAt(0).stringProperty = "newVal";
        tno.mapLinks["test"]?.stringProperty = "newVal";

        tno.link?.link = TestNotificationObject();
        tno.link?.link?.link = TestNotificationObject();

        tno.listLinks[0].link = TestNotificationObject();
        tno.setLinks.elementAt(0).link = TestNotificationObject();
        tno.mapLinks["test"]?.link = TestNotificationObject();
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["listLinks", "setLinks", "mapLinks", "link"]);

      realm.write(() {
        tno.link?.link?.link?.stringProperty = "test";
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, null);

      subscription.cancel();
    });

    test('test nested wildcard', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema]);
      var realm = getRealm(config);

      final tno = TestNotificationObject();

      realm.write(() {
        realm.add(tno);
      });

      final externalChanges = <RealmObjectChanges<TestNotificationObject>>[];
      final subscription = tno.changesFor(["*.*"]).listen((changes) {
        if (changes.properties.isNotEmpty) externalChanges.add(changes);
      });

      realm.write(() {
        tno.link = TestNotificationObject();
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["link"]);

      realm.write(() {
        tno.link?.link = TestNotificationObject();
        tno.link?.link?.link = TestNotificationObject();
        tno.link?.link?.link?.link = TestNotificationObject();
        tno.link?.link?.link?.link?.link = TestNotificationObject();
        tno.link?.link?.link?.link?.link?.link = TestNotificationObject();
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["link"]);

      realm.write(() {
        tno.link?.link?.link?.link?.link?.link?.stringProperty = "test";
      });

      await verifyNotifications<TestNotificationObject>(tno, externalChanges, null);

      subscription.cancel();
    });

    test('subscribing multiple times merges keypaths', () async {
      var config = Configuration.local([TestNotificationObject.schema, TestNotificationEmbeddedObject.schema]);
      var realm = getRealm(config);

      final tno = TestNotificationObject();

      realm.write(() {
        realm.add(tno);
      });

      final externalChanges = <RealmObjectChanges<TestNotificationObject>>[];
      final subscription = tno.changesFor(["intProperty"]).listen((changes) {
        if (changes.properties.isNotEmpty) externalChanges.add(changes);
      });

      final externalChanges2 = <RealmObjectChanges<TestNotificationObject>>[];
      final subscription2 = tno.changesFor(["stringProperty"]).listen((changes) {
        if (changes.properties.isNotEmpty) externalChanges2.add(changes);
      });

      realm.write(() {
        tno.intProperty = 23;
        tno.stringProperty = "test";
        tno.link = TestNotificationObject();
      });

      // Both of these fails because both "intProperty and "stringProperty" are reported as changed
      await verifyNotifications<TestNotificationObject>(tno, externalChanges, ["intProperty", "stringProperty"]);

      subscription.cancel();
      subscription2.cancel();
    });
  });

  test('RealmObject get property', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final car = Car('Tesla');
    realm.write(() {
      realm.add(car);
    });

    expect(car.make, equals('Tesla'));
  });

  test('RealmObject set property', () {
    var config = Configuration.local([Car.schema]);
    var realm = getRealm(config);

    final car = Car('Tesla');
    realm.write(() {
      realm.add(car);
    });

    expect(car.make, equals('Tesla'));

    expect(() {
      realm.write(() {
        car.make = "Audi";
      });
    }, throws<RealmException>("Primary key cannot be changed (original value: 'Tesla', supplied value: 'Audi'"));

    // If we don't change the PK, setting it is a no-op
    expect(() {
      realm.write(() {
        car.make = 'Tesla';
      });
    }, returnsNormally);
  });

  test('RealmObject set object type property (link)', () {
    var config = Configuration.local([Person.schema, Dog.schema]);
    var realm = getRealm(config);

    final dog = Dog(
      "MyDog",
      owner: Person("MyOwner"),
    );
    realm.write(() {
      realm.add(dog);
    });

    expect(dog.name, 'MyDog');
    expect(dog.owner, isNotNull);
    expect(dog.owner!.name, 'MyOwner');
  });

  test('RealmObject set property null', () {
    var config = Configuration.local([Person.schema, Dog.schema]);
    var realm = getRealm(config);

    final dog = Dog(
      "MyDog",
      owner: Person("MyOwner"),
      age: 5,
    );
    realm.write(() {
      realm.add(dog);
    });

    expect(dog.name, 'MyDog');
    expect(dog.age, 5);
    expect(dog.owner, isNotNull);
    expect(dog.owner!.name, 'MyOwner');

    realm.write(() {
      dog.age = null;
    });

    expect(dog.age, null);

    realm.write(() {
      dog.owner = null;
    });

    expect(dog.owner, null);
  });

  test('RealmObject.operator==', () {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);

    final person = Person('Kasper');
    final dog = Dog('Fido', owner: person);
    expect(person, person);
    expect(person, isNot(1));
    expect(person, isNot(dog));
    realm.write(() {
      realm
        ..add(person)
        ..add(dog);
    });
    expect(person, person);
    expect(person, isNot(1));
    expect(person, isNot(dog));
    final read = realm.query<Person>("name == 'Kasper'");

    expect(read, [person]);
  });

  test('RealmObject isValid', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    var team = Team("team one");
    expect(team.isValid, true);
    realm.write(() {
      realm.add(team);
    });
    expect(team.isValid, true);
    realm.close();
    expect(team.isValid, false);
  });

  test('RealmObject read deleted object properties', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    var team = Team("TeamOne");
    realm.write(() => realm.add(team));
    var teams = realm.all<Team>();
    var teamBeforeDelete = teams[0];
    realm.write(() => realm.delete(team));
    expect(team.isValid, false);
    expect(teamBeforeDelete.isValid, false);
    expect(team, teamBeforeDelete);
    expect(() => team.name, throws<RealmException>("Accessing object of type Team which has been invalidated or deleted"));
    expect(() => teamBeforeDelete.name, throws<RealmException>("Accessing object of type Team which has been invalidated or deleted"));
  });

  test('RealmObject write deleted object property', () {
    var config = Configuration.local([Person.schema]);
    var realm = getRealm(config);

    final person = Person('Markos');

    realm.write(() {
      realm.add(person);
    });

    realm.write(() {
      realm.delete(person);
    });

    expect(() => realm.write(() => person.name = "Markos Sanches"),
        throws<RealmException>("Accessing object of type Person which has been invalidated or deleted"));
  });

  test('RealmObject notifications', () async {
    var config = Configuration.local([Dog.schema, Person.schema]);
    var realm = getRealm(config);

    final dog = Dog("Lassy");

    //unmanaged objects can not be listened to
    expect(() => dog.changes, throws<RealmStateError>());

    realm.write(() {
      realm.add(dog);
    });

    var callNum = 0;
    final subscription = dog.changes.listen((changes) {
      if (callNum == 0) {
        callNum++;
        expect(changes.isDeleted, false);
        expect(changes.object, dog);
        expect(changes.properties.isEmpty, true);
      } else if (callNum == 1) {
        //object is modified
        callNum++;
        expect(changes.isDeleted, false);
        expect(changes.object, dog);
        expect(changes.properties, ["age", "owner"]);
      } else {
        //object is deleted
        callNum++;
        expect(changes.isDeleted, true);
        expect(changes.object, dog);
        expect(changes.properties.isEmpty, true);
      }
    });

    await Future<void>.delayed(Duration(milliseconds: 20));
    realm.write(() {
      dog.age = 2;
      dog.owner = Person("owner");
    });

    await Future<void>.delayed(Duration(milliseconds: 20));
    realm.write(() {
      realm.delete(dog);
    });

    await Future<void>.delayed(Duration(milliseconds: 20));
    subscription.cancel();

    await Future<void>.delayed(Duration(milliseconds: 20));
  });

  void testPrimaryKey<T extends RealmObject, K extends Object>(SchemaObject schema, T Function() createObject, K? key) {
    test("$T primary key: $key", () {
      final pkProp = schema.where((p) => p.primaryKey).single;
      final realm = Realm(Configuration.local([schema]));
      final obj = realm.write(() {
        return realm.add(createObject());
      });

      final foundObj = realm.find<T>(key);
      expect(foundObj, obj);

      final propValue = RealmObjectBase.get<K>(obj, pkProp.name);
      expect(propValue, key);

      realm.close();
    });
  }

  final ints = [1, 0, -1, maxInt, jsMaxInt, minInt, jsMinInt];
  for (final pk in ints) {
    testPrimaryKey(IntPrimaryKey.schema, () => IntPrimaryKey(pk), pk);
  }

  for (final pk in [null, ...ints]) {
    testPrimaryKey(NullableIntPrimaryKey.schema, () => NullableIntPrimaryKey(pk), pk);
  }

  final strings = ["", "1", "abc", "null"];
  for (final pk in strings) {
    testPrimaryKey(StringPrimaryKey.schema, () => StringPrimaryKey(pk), pk);
  }

  for (final pk in [null, ...strings]) {
    testPrimaryKey(NullableStringPrimaryKey.schema, () => NullableStringPrimaryKey(pk), pk);
  }

  final objectIds = [
    ObjectId.fromHexString('624d9e04bd013db290785d04'),
    ObjectId.fromHexString('000000000000000000000000'),
    ObjectId.fromHexString('ffffffffffffffffffffffff')
  ];

  for (final pk in objectIds) {
    testPrimaryKey(ObjectIdPrimaryKey.schema, () => ObjectIdPrimaryKey(pk), pk);
  }

  for (final pk in [null, ...objectIds]) {
    testPrimaryKey(NullableObjectIdPrimaryKey.schema, () => NullableObjectIdPrimaryKey(pk), pk);
  }

  final uuids = [
    Uuid.fromString('0f1dea4d-074e-4c72-b505-e2e8a727602f'),
    Uuid.fromString('00000000-0000-0000-0000-000000000000'),
  ];

  for (final pk in uuids) {
    testPrimaryKey(UuidPrimaryKey.schema, () => UuidPrimaryKey(pk), pk);
  }

  for (final pk in [null, ...uuids]) {
    testPrimaryKey(NullableUuidPrimaryKey.schema, () => NullableUuidPrimaryKey(pk), pk);
  }

  test('Remapped property has correct names in Core', () {
    final config = Configuration.local([RemappedClass.schema]);
    final realm = getRealm(config);

    final obj = realm.write(() {
      final obj = realm.add(RemappedClass("some value"));
      obj.listProperty.add(obj);
      return obj;
    });

    final json = obj.toJson();

    // remappedProperty is mapped as `primitive_property`
    expect(json, contains('"primitive_property":"some value"'));

    // listProperty is mapped as `list-with-dashes`
    expect(json, contains('"list-with-dashes":'));
  });

  test('Remapped class across different files works', () {
    final config = Configuration.local([RemappedClass.schema, RemappedFromAnotherFile.schema]);
    final realm = getRealm(config);
    final obj = realm.write(() {
      return realm.add(RemappedFromAnotherFile(linkToAnotherClass: RemappedClass("prop")));
    });

    final json = obj.toJson();

    // linkToAnotherClass is mapped as `property with spaces`
    expect(json, contains('"property with spaces":0'));
  });

  test('RealmObject read/write bool value with json', () {
    var config = Configuration.local([BoolValue.schema]);
    var realm = getRealm(config);

    realm.write(() {
      realm.add(BoolValue(1, true));
      realm.add(BoolValue(2, false));
    });

    expect(realm.find<BoolValue>(1)!.toJson().replaceAll('"', '').contains("value:true"), isTrue);
    expect(realm.find<BoolValue>(2)!.toJson().replaceAll('"', '').contains("value:false"), isTrue);
  });

  final epochZero = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  void expectDateInJson(DateTime? date, String json, String propertyName) {
    if (date == null) {
      expect(json, contains('"$propertyName":null'));
    } else {
      expect(json, contains('"$propertyName":"${date.toCoreTimestampString()}"'));
    }
  }

  final dates = [
    // BUG: Realm represent timestamps as 64 bit seconds offset from epoch (1970)
    // and a 32 bit nano-seconds component. Hence realm can represent offsets from
    // epoch up to (1 << 63)s / 86400s/day = 9223372036854689408 days, yet realm-core
    // cannot serialize:
    //
    //DateTime.utc(1970).add(Duration(days: 100000000)),
    //DateTime.utc(1970).subtract(Duration(days: 99999999)),
    //
    // See https://github.com/realm/realm-core/issues/6892
    DateTime.utc(1970).add(Duration(days: 999999)),
    DateTime.utc(1970).subtract(Duration(days: 999999)),
    DateTime.utc(2020, 1, 1, 12, 34, 56, 789, 999),
    DateTime.utc(2022),
    DateTime.utc(1930, 1, 1, 12, 34, 56, 123, 456),
  ];
  for (final date in dates) {
    test('Date roundtrips correctly: $date', () {
      final config = Configuration.local([AllTypes.schema]);
      final realm = getRealm(config);
      final obj = realm.write(() {
        return realm.add(AllTypes('', false, date, 0, ObjectId(), Uuid.v4(), 0, Decimal128.one, Uint8List(16)));
      });

      final json = obj.toJson();
      expectDateInJson(date, json, 'dateProp');

      expect(obj.dateProp, equals(date));
    });
  }

  for (final list in [
    dates,
    <DateTime>{},
    [DateTime(0)]
  ]) {
    test('List of ${list.length} dates roundtrips correctly', () {
      final config = Configuration.local([AllCollections.schema]);
      final realm = getRealm(config);
      final obj = realm.write(() {
        return realm.add(AllCollections(dateList: list));
      });

      final json = obj.toJson();
      for (var i = 0; i < list.length; i++) {
        final expectedDate = list.elementAt(i).toUtc();
        expect(json, contains('"${expectedDate.toCoreTimestampString()}"'));
        expect(obj.dateList[i], equals(expectedDate));
      }
    });
  }

  test('Date converts to utc', () {
    final config = Configuration.local([AllTypes.schema]);
    final realm = getRealm(config);

    final date = DateTime.now();
    expect(date.isUtc, isFalse);

    final obj = realm.write(() {
      return realm.add(AllTypes('', false, date, 0, ObjectId(), Uuid.v4(), 0, Decimal128.one, Uint8List(16)));
    });

    final json = obj.toJson();
    expectDateInJson(date, json, 'dateProp');

    expect(obj.dateProp.isUtc, isTrue);
    expect(obj.dateProp, equals(date.toUtc()));
  });

  test('Date can be used in queries', () {
    final config = Configuration.local([AllTypes.schema]);
    final realm = getRealm(config);

    final date = DateTime.now();

    realm.write(() {
      realm.add(AllTypes('abc', false, date, 0, ObjectId(), Uuid.v4(), 0, Decimal128.one, Uint8List(16)));
      realm.add(AllTypes('cde', false, DateTime.now().add(Duration(seconds: 1)), 0, ObjectId(), Uuid.v4(), 0, Decimal128.one, Uint8List(16)));
    });

    var results = realm.all<AllTypes>().query('dateProp = \$0', [date]);
    expect(results.length, equals(1));
    expect(results.first.stringProp, equals('abc'));
  });

  test('Date preserves precision', () {
    final config = Configuration.local([AllTypes.schema]);
    final realm = getRealm(config);

    final date1 = DateTime.now().toUtc();
    final date2 = date1.add(Duration(microseconds: 1));
    final date3 = date1.subtract(Duration(microseconds: 1));

    realm.write(() {
      realm.add(AllTypes('1', false, date1, 0, ObjectId(), Uuid.v4(), 0, Decimal128.one, Uint8List(16)));
      realm.add(AllTypes('2', false, date2, 0, ObjectId(), Uuid.v4(), 0, Decimal128.one, Uint8List(16)));
      realm.add(AllTypes('3', false, date3, 0, ObjectId(), Uuid.v4(), 0, Decimal128.one, Uint8List(16)));
    });

    final lessThan1 = realm.all<AllTypes>().query('dateProp < \$0', [date1]);
    expect(lessThan1.single.stringProp, equals('3'));
    expect(lessThan1.single.dateProp, equals(date3));

    final moreThan1 = realm.all<AllTypes>().query('dateProp > \$0', [date1]);
    expect(moreThan1.single.stringProp, equals('2'));
    expect(moreThan1.single.dateProp, equals(date2));

    final equals1 = realm.all<AllTypes>().query('dateProp = \$0', [date1]);
    expect(equals1.single.stringProp, equals('1'));
    expect(equals1.single.dateProp, equals(date1));
  });

  test('get/set all property types', () {
    final config = Configuration.local([AllTypes.schema]);
    final realm = getRealm(config);

    var date = DateTime.now().toUtc();
    var objectId = ObjectId();
    var uuid = Uuid.v4();

    final object = realm.write(() {
      return realm.add(AllTypes('cde', false, date, 0.1, objectId, uuid, 4, Decimal128.ten, Uint8List.fromList([1, 2]), nullableBinaryProp: null));
    });

    expect(object.stringProp, 'cde');
    expect(object.boolProp, false);
    expect(object.dateProp, date);
    expect(object.doubleProp, 0.1);
    expect(object.objectIdProp, objectId);
    expect(object.uuidProp, uuid);
    expect(object.intProp, 4);
    expect(object.decimalProp, Decimal128.ten);
    expect(object.binaryProp, Uint8List.fromList([1, 2]));
    expect(object.nullableBinaryProp, null);

    date = DateTime.now().add(Duration(days: 1)).toUtc();
    objectId = ObjectId();
    uuid = Uuid.v4();
    realm.write(() {
      object.stringProp = "abc";
      object.boolProp = true;
      object.dateProp = date;
      object.doubleProp = 1.1;
      object.objectIdProp = objectId;
      object.uuidProp = uuid;
      object.intProp = 5;
      object.decimalProp = Decimal128.one;
      object.binaryProp = Uint8List.fromList([3, 4]);
      object.nullableBinaryProp = Uint8List.fromList([5, 6]);
    });

    expect(object.stringProp, 'abc');
    expect(object.boolProp, true);
    expect(object.dateProp, date);
    expect(object.doubleProp, 1.1);
    expect(object.objectIdProp, objectId);
    expect(object.uuidProp, uuid);
    expect(object.intProp, 5);
    expect(object.decimalProp, Decimal128.one);
    expect(object.binaryProp, Uint8List.fromList([3, 4]));
    expect(object.nullableBinaryProp, Uint8List.fromList([5, 6]));
  });

  test('RealmObject.freeze when typed returns typed frozen object', () {
    final config = Configuration.local([Person.schema, Team.schema]);
    final realm = getRealm(config);

    final liveTeam = realm.write(() {
      return realm.add(Team('team', players: [Person('Peter')], scores: [123]));
    });
    final frozenTeam = freezeObject(liveTeam);

    expect(frozenTeam.isFrozen, true);
    expect(frozenTeam.realm.isFrozen, true);
    expect(frozenTeam.players.isFrozen, true);
    expect(frozenTeam.players.single.isFrozen, true);

    realm.write(() {
      liveTeam.players.add(Person('George'));
    });

    expect(frozenTeam.players.length, 1);
    expect(liveTeam.players.length, 2);
  });

  test('FrozenObject.changes throws', () {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    final peter = realm.write(() => realm.add(Person('Peter')));
    final frozenPeter = freezeObject(peter);

    expect(() => frozenPeter.changes, throws<RealmStateError>('Object is frozen and cannot emit changes'));
  });

  test('RealmObject.freeze when generic returns generic frozen object', () {
    final config = Configuration.local([Person.schema, Team.schema]);
    final realm = getRealm(config);

    // Cast to the base type to ensure we're not using the generated freeze() method.
    RealmObject liveTeam = realm.write(() {
      return realm.add(Team('team', players: [Person('Peter')], scores: [123]));
    });

    final frozenTeam = freezeObject(liveTeam);
    expect(frozenTeam.runtimeType, Team);

    final frozenPlayers = frozenTeam.dynamic.getList<RealmObject>('players');
    expect(frozenPlayers.isFrozen, true);
    expect(frozenPlayers.single.isFrozen, true);
    expect(frozenTeam.dynamic.get('name'), 'team');
  });

  test('RealmObject.freeze when dynamic works', () {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    realm.write(() => realm.add(Person('Peter')));

    dynamic peter = realm.dynamic.all('Person').single;
    dynamic frozenPeter = freezeDynamic(peter);
    expect(frozenPeter.runtimeType.toString(), '_ConcreteRealmObject');
    expect(frozenPeter.isFrozen, true);
    expect(frozenPeter.name, 'Peter');

    realm.write(() {
      peter.name = 'Peter II';
    });

    expect(frozenPeter.name, 'Peter');
  });

  test('RealmObject.freeze when unmanaged throws', () {
    final person = Person('Peter');
    expect(() => freezeObject(person), throws<RealmStateError>("Can't freeze unmanaged objects"));
  });

  test('RealmObject.freeze when frozen returns same object', () {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    final liveObject = realm.write(() => realm.add(Person('Peter')));

    final frozenObject = freezeObject(liveObject);
    final deepFrozenObject = freezeObject(frozenObject);

    expect(identical(frozenObject, deepFrozenObject), true);

    final anotherFrozenObject = freezeObject(liveObject);
    expect(identical(frozenObject, anotherFrozenObject), false);
  });

  test('Update primary key on unmanaged object', () {
    final obj = StringPrimaryKey('abc');
    obj.id = 'cde';

    expect(obj.id, 'cde');

    final realm = getRealm(Configuration.local([StringPrimaryKey.schema]));
    realm.write(() {
      realm.add(obj);
    });

    expect(realm.find<StringPrimaryKey>('cde'), isNotNull);
    expect(realm.find<StringPrimaryKey>('abc'), isNull);

    realm.write(() {
      expect(() => obj.id = 'cde', returnsNormally);
      expect(() => obj.id = 'abc', throws<RealmException>('Primary key cannot be changed'));
    });
  });

  test('RealmObject.changes - await for with yield ', () async {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    final person = realm.write(() => realm.add(Person('Peter')));

    final wait = const Duration(seconds: 1);

    Stream<bool> trueWaitFalse() async* {
      yield true;
      await Future<void>.delayed(wait);
      yield false; // nothing has happened in the meantime
    }

    // ignore: prefer_function_declarations_over_variables
    final awaitForWithYield = () async* {
      await for (final c in person.changes) {
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

  test('RealmObject read deleted object properties', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    var team = Team("TeamOne");
    realm.write(() => realm.add(team));
    var teams = realm.all<Team>();
    var teamBeforeDelete = teams[0];
    realm.write(() => realm.delete(team));
    expect(team.isValid, false);
    expect(teamBeforeDelete.isValid, false);
    expect(team, teamBeforeDelete);
    expect(() => team.name, throws<RealmException>("Accessing object of type Team which has been invalidated or deleted"));
    expect(() => teamBeforeDelete.name, throws<RealmException>("Accessing object of type Team which has been invalidated or deleted"));
  });

  test('RealmObject.hashCode changes after adding to Realm', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final team = Team("TeamOne");

    final unmanagedHash = team.hashCode;

    realm.write(() => realm.add(team));

    final managedHash = team.hashCode;

    expect(managedHash, isNot(unmanagedHash));
    expect(managedHash, equals(team.hashCode));
  });

  test('RealmObject.hashCode is different for different objects', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final a = Team("a");
    final b = Team("b");

    expect(a.hashCode, isNot(b.hashCode));

    realm.write(() {
      realm.add(a);
      realm.add(b);
    });

    expect(a.hashCode, isNot(b.hashCode));
  });

  test('RealmObject.hashCode is same for equal objects', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final team = Team("TeamOne");

    realm.write(() {
      realm.add(team);
    });

    final teamAgain = realm.all<Team>().first;

    expect(team.hashCode, equals(teamAgain.hashCode));
  });

  test('RealmObject.hashCode remains stable after deletion', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final team = Team("TeamOne");

    realm.write(() {
      realm.add(team);
    });

    final teamAgain = realm.all<Team>().first;

    final managedHash = team.hashCode;

    realm.write(() => realm.delete(team));

    expect(team.hashCode, equals(managedHash)); // Object that was just deleted shouldn't change its hash code
    expect(teamAgain.hashCode, equals(managedHash)); // Object that didn't hash its hash code and its row got deleted should still have the same hash code
  });

  test("RealmObject when added to set doesn't have duplicates", () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    realm.write(() {
      realm.add(Team("TeamOne"));
    });

    final setOne = realm.all<Team>().toSet();
    final setTwo = realm.all<Team>().toSet();

    expect(setOne.difference(setTwo).length, 0);
  });
}
