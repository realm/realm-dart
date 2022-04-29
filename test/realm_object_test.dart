////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
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
import 'dart:math';
import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';

import 'test.dart';

part 'realm_object_test.g.dart';

const int maxInt = 9223372036854775807;
const int minInt = -9223372036854775808;

@RealmModel()
class _ObjectIdPrimaryKey {
  @PrimaryKey()
  late ObjectId id;
}

@RealmModel()
class _IntPrimaryKey {
  @PrimaryKey()
  late int id;
}

@RealmModel()
class _StringPrimaryKey {
  @PrimaryKey()
  late String id;
}

@RealmModel()
class _UuidPrimaryKey {
  @PrimaryKey()
  late Uuid id;
}

@RealmModel()
@MapTo('class with spaces')
class _RemappedFromAnotherFile {
  @MapTo("property with spaces")
  late $RemappedClass? linkToAnotherClass;
}

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  await setupTests(args);

  test('RealmObject get property', () {
    var config = Configuration([Car.schema]);
    var realm = getRealm(config);

    final car = Car('Tesla');
    realm.write(() {
      realm.add(car);
    });

    expect(car.make, equals('Tesla'));
  });

  test('RealmObject set property', () {
    var config = Configuration([Car.schema]);
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
    }, throws<RealmUnsupportedSetError>());
  });

  test('RealmObject set object type property (link)', () {
    var config = Configuration([Person.schema, Dog.schema]);
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
    var config = Configuration([Person.schema, Dog.schema]);
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
    var config = Configuration([Dog.schema, Person.schema]);
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
    var config = Configuration([Team.schema, Person.schema]);
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
    var config = Configuration([Team.schema, Person.schema]);
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

  test('RealmObject - write object property after realm is closed', () {
    var config = Configuration([Person.schema]);
    var realm = getRealm(config);

    final person = Person('Markos');

    realm.write(() => realm.add(person));
    realm.close();
    expect(() => realm.write(() => person.name = "Markos Sanches"), throws<RealmException>("Cannot access realm that has been closed"));
  });

  test('RealmObject write deleted object property', () {
    var config = Configuration([Person.schema]);
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
    var config = Configuration([Dog.schema, Person.schema]);
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
        expect(changes.properties, <String>[]);
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

  void testPrimaryKey<T extends RealmObject, K extends Object>(SchemaObject schema, T Function() createObject, K key) {
    test("$T primary key: $key", () {
      final pkProp = schema.properties.where((p) => p.primaryKey).single;
      final realm = Realm(Configuration([schema]));
      final obj = realm.write(() {
        return realm.add(createObject());
      });

      final foundObj = realm.find<T>(key);
      expect(foundObj, obj);

      final propValue = RealmObject.get<K>(obj, pkProp.name);
      expect(propValue, key);

      realm.close();
    });
  }

  final ints = [1, 0, -1, maxInt, minInt];
  for (final pk in ints) {
    testPrimaryKey(IntPrimaryKey.schema, () => IntPrimaryKey(pk), pk);
  }

  final strings = ["", "1", "abc", "null"];
  for (final pk in strings) {
    testPrimaryKey(StringPrimaryKey.schema, () => StringPrimaryKey(pk), pk);
  }

  final objectIds = [
    ObjectId.fromHexString('624d9e04bd013db290785d04'),
    ObjectId.fromHexString('000000000000000000000000'),
    ObjectId.fromHexString('ffffffffffffffffffffffff')
  ];

  for (final pk in objectIds) {
    testPrimaryKey(ObjectIdPrimaryKey.schema, () => ObjectIdPrimaryKey(pk), pk);
  }

  final uuids = [
    Uuid.fromString('0f1dea4d-074e-4c72-b505-e2e8a727602f'),
    Uuid.fromString('00000000-0000-0000-0000-000000000000'),
  ];
  for (final pk in uuids) {
    testPrimaryKey(UuidPrimaryKey.schema, () => UuidPrimaryKey(pk), pk);
  }

  test('Remapped property has correct names in Core', () {
    final config = Configuration([RemappedClass.schema]);
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

    // RemappedClass is mapped as `myRemappedClass`
    expect(json, contains('"table": "class_myRemappedClass"'));
  });

  test('Remapped class across different files works', () {
    final config = Configuration([RemappedClass.schema, RemappedFromAnotherFile.schema]);
    final realm = getRealm(config);
    final obj = realm.write(() {
      return realm.add(RemappedFromAnotherFile(linkToAnotherClass: RemappedClass("prop")));
    });

    final json = obj.toJson();

    // linkToAnotherClass is mapped as `property with spaces`
    // RemappedClass is mapped as `myRemappedClass`
    expect(json, contains('"property with spaces":{ "table": "class_myRemappedClass", "key": 0}'));
  });

  final dateZero = DateTime.utc(0);

  bool _canCoreRepresentDateInJson(DateTime date) {
    // Core has a bug where negative and zero dates are not serialized correctly to json.
    // https://jira.mongodb.org/browse/RCORE-1083
    if (date.compareTo(dateZero) < 0) {
      return Platform.isMacOS || Platform.isIOS;
    }

    // Very large dates are also buggy on Android and Windows
    if (date.compareTo(DateTime.utc(10000)) > 0) {
      return Platform.isMacOS || Platform.isIOS || Platform.isLinux;
    }

    return true;
  }

  void expectDateInJson(DateTime? date, String json, String propertyName) {
    if (date == null) {
      expect(json, contains('"$propertyName":null'));
    } else if (_canCoreRepresentDateInJson(date)) {
      expect(json, contains('"$propertyName":"${date.toRealmString()}"'));
    }
  }

  final dates = [
    DateTime.utc(1970).add(Duration(days: 100000000)),
    DateTime.utc(1970).subtract(Duration(days: 99999999)),
    DateTime.utc(2020, 1, 1, 12, 34, 56, 789, 999),
    DateTime.utc(2022),
  ];
  for (final date in dates) {
    test('Date roundtrips correctly: $date', () {
      final config = Configuration([AllTypes.schema]);
      final realm = getRealm(config);
      final obj = realm.write(() {
        return realm.add(AllTypes('', false, date, 0, ObjectId(), Uuid.v4(), 0));
      });

      final json = obj.toJson();
      expectDateInJson(date, json, 'dateProp');
      expectDateInJson(null, json, 'nullableDateProp');

      expect(obj.dateProp, equals(date));
      expect(obj.nullableDateProp, equals(null));
    });

    test('Nullable date roundtrips correctly: $date', () {
      final config = Configuration([AllTypes.schema]);
      final realm = getRealm(config);
      final obj = realm.write(() {
        return realm.add(AllTypes('', false, DateTime.utc(0), 0, ObjectId(), Uuid.v4(), 0, nullableDateProp: date));
      });

      final json = obj.toJson();
      expectDateInJson(DateTime.utc(0), json, 'dateProp');
      expectDateInJson(date, json, 'nullableDateProp');

      expect(obj.dateProp, equals(DateTime.utc(0)));
      expect(obj.nullableDateProp, equals(date));
    });
  }

  for (final list in [
    dates,
    <DateTime>{},
    [DateTime(0)]
  ]) {
    test('List of ${list.length} dates roundtrips correctly', () {
      final config = Configuration([AllCollections.schema]);
      final realm = getRealm(config);
      final obj = realm.write(() {
        return realm.add(AllCollections(dates: list));
      });

      final json = obj.toJson();
      for (var i = 0; i < list.length; i++) {
        final expectedDate = list.elementAt(i).toUtc();
        if (_canCoreRepresentDateInJson(expectedDate)) {
          expect(json, contains('"${expectedDate.toRealmString()}"'));
        }

        expect(obj.dates[i], equals(expectedDate));
      }
    });
  }

  test('Date converts to utc', () {
    final config = Configuration([AllTypes.schema]);
    final realm = getRealm(config);

    final date = DateTime.now();
    expect(date.isUtc, isFalse);

    final obj = realm.write(() {
      return realm.add(AllTypes('', false, date, 0, ObjectId(), Uuid.v4(), 0, nullableDateProp: date));
    });

    final json = obj.toJson();
    expectDateInJson(date, json, 'dateProp');
    expectDateInJson(date, json, 'nullableDateProp');

    expect(obj.dateProp.isUtc, isTrue);
    expect(obj.dateProp, equals(date.toUtc()));

    expect(obj.nullableDateProp?.isUtc, isTrue);
    expect(obj.nullableDateProp, equals(date.toUtc()));
  });

  test('Date can be used in queries', () {
    final config = Configuration([AllTypes.schema]);
    final realm = getRealm(config);

    final date = DateTime.now();

    realm.write(() {
      realm.add(AllTypes('abc', false, date, 0, ObjectId(), Uuid.v4(), 0, nullableDateProp: date));
      realm.add(AllTypes('cde', false, DateTime.now().add(Duration(seconds: 1)), 0, ObjectId(), Uuid.v4(), 0));
    });

    var results = realm.all<AllTypes>().query('dateProp = \$0', [date]);
    expect(results.length, equals(1));
    expect(results.first.stringProp, equals('abc'));

    results = realm.all<AllTypes>().query('nullableDateProp = \$0', [date]);
    expect(results.length, equals(1));
    expect(results.first.stringProp, equals('abc'));

    results = realm.all<AllTypes>().query('nullableDateProp = null');
    expect(results.length, equals(1));
    expect(results.first.stringProp, equals('cde'));
  });

  test('Date preserves precision', () {
    final config = Configuration([AllTypes.schema]);
    final realm = getRealm(config);

    final date1 = DateTime.now().toUtc();
    final date2 = date1.add(Duration(microseconds: 1));
    final date3 = date1.subtract(Duration(microseconds: 1));

    realm.write(() {
      realm.add(AllTypes('1', false, date1, 0, ObjectId(), Uuid.v4(), 0));
      realm.add(AllTypes('2', false, date2, 0, ObjectId(), Uuid.v4(), 0));
      realm.add(AllTypes('3', false, date3, 0, ObjectId(), Uuid.v4(), 0));
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
}
