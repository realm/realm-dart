import 'dart:async';
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

import 'dart:io';

import 'package:realm_dart/realm.dart';
import 'package:test/test.dart';
import 'package:test/test.dart' as testing;

part 'realm_test.g.dart';

class _Car {
  @RealmProperty()
  String make;

  @RealmProperty()
  String model;
  
  @RealmProperty(defaultValue: "500", optional: true)
  int kilometers;
}

class _Person {
  @RealmProperty()
  String name;

  @RealmProperty()
  int age;

  @RealmProperty()
  List<_Car> cars;
}

class _ServicedCar {
  @RealmProperty(primaryKey: true)
  int id;

  @RealmProperty()
  _Car car;
}

String testName;

/**
 * Overrides other tests
 */
void test(String name, Function testFunction) {
  if (testName != null && !name.contains(testName)) {
    return;
  }

  testing.test(name, testFunction);
}


void getTestNameFilter(List<String> arguments) {
  if (arguments == null) {
    print("arguments is null");
    return;
  }
  
  int nameArgIndex = arguments.indexOf("--testname");
  if (arguments.length != 0) {
    if (nameArgIndex >= 0 && arguments.length > 1) {
      testName = arguments[nameArgIndex + 1];
      print("testName: ${testName}");
    }
  }
}

void main([List<String> arguments]) {
  getTestNameFilter(arguments);
  
  print("Current PID ${pid}");

  setUp(() {
    //Dart: this will clear everything else but deleting the file
    Realm.clearTestState();

    var currentDir = Directory.current;
    var files = currentDir.listSync();
    for (var file in files) {
      if (!(file is File) || (!file.path.endsWith(".realm"))) {
        continue;
      }

      file.deleteSync();

      var lockFile = new File("${file.path}.lock");
      lockFile.deleteSync();
    }
  });

  group('RealmClass tests', () {
    test('Realm should be created', () {
      var config = new Configuration();
      config.schema.add(Car);

      var realm = new Realm(config);
      expect(realm, isNotNull);
    });

    test('Realm get defaultPath', () {
      expect(Realm.defaultPath, isA<String>().having((path) => path, "Realm.defaultPath", contains(".realm")));
    });

    test('Realm get schemaVersion', () {
      var config = new Configuration();
      var realm = new Realm(config);
      expect(realm, isNotNull);

      double version = Realm.schemaVersion(Realm.defaultPath);
      expect(version, equals(0));
    });

     test('Realm exists', () {
      var config = new Configuration();
      bool exists = Realm.exists(Realm.defaultPath);
      expect(exists, isFalse);

      var realm = new Realm(config);
      expect(realm, isNotNull);

      exists = Realm.exists(Realm.defaultPath);
      expect(exists, isTrue);
    });

     test('Realm deleteFile', () {
      var config = new Configuration();
      var realm = new Realm(config);
      realm.close();
      File realmFile = new File(Realm.defaultPath);
      expect(realmFile.existsSync(), isTrue);

      Realm.deleteFile(Realm.defaultPath);
      expect(realmFile.existsSync(), isFalse);
    });
    
    test('Realm objects can be indexed', () {
      var config = new Configuration();
      config.schema.add(Car);

      var realm = new Realm(config);

      Car car = new Car()
        ..make = "Audi"
        ..model = "A4"
        ..kilometers = 245;
      realm.write(() {
        car = realm.create(car);
      });

      var objects = realm.objects<Car>();
      Car indexedCar = objects[0];

      expect(indexedCar, isA<Car>());
      expect(indexedCar.make, equals(car.make));
      expect(indexedCar.model, equals(car.model));
      expect(indexedCar.kilometers, equals(car.kilometers));
    });

    test('Realm objects is valid', () {
      var config = new Configuration();
      config.schema.add(Car);

      var realm = new Realm(config);

      Car car = new Car()
        ..make = "Audi"
        ..model = "A4"
        ..kilometers = 245;
      
      Car realmCar = null;
      realm.write(() {
        realmCar = realm.create(car);
      });

      expect(car, isA<Car>());
      expect(realmCar.isValid(), isTrue);
      expect(() => car.isValid(), throwsA(TypeMatcher<RealmException>()));
    });

    test('Realm add notifications', () {
      var config = new Configuration();
      //config.schema.add(Car);

      var realm = new Realm(config);
      int notificationCount = 0;
      String notificationName;

      realm.addListener(Event.change, (realm, name) {
        notificationCount++;
        notificationName = name;
      });

      realm.write(() => {});

      expect(notificationCount, equals(1));
      expect(notificationName, equals('change'));

      realm.write(() => {});

      expect(notificationCount, equals(2));
      expect(notificationName, equals('change'));
    });

      test('Realm remove notifications', () {
      var config = new Configuration();
      //config.schema.add(Car);

      var realm = new Realm(config);
      int notificationCount = 0;
      String notificationName;

      var callback = (realm, name) {
        notificationCount++;
        notificationName = name;
      };
      realm.addListener(Event.change, callback);

      realm.write(() => {});

      expect(notificationCount, equals(1));
      expect(notificationName, equals('change'));

      realm.removeListener(Event.change, callback);
      
      realm.write(() => {});

      expect(notificationCount, equals(1));
      expect(notificationName, equals('change'));
    });

    test('Realm test list properties', () {
      var config = new Configuration();
      config.schema.addAll([Car, Person]);

      var realm = new Realm(config);

      Person person = new Person()
        ..name = "CarOwner"
        ..age = 18
        ..cars = new List<Car>();

      var car1 = new Car()
        ..make = "Audi"
        ..model = "A4"
        ..kilometers = 245;

      var car2 = new Car()
        ..make = "VW"
        ..model = "Passat"
        ..kilometers = 200;

      person.cars.addAll([car1, car2]);

      realm.write(() {
        var createdPerson = realm.create(person);
        expect(createdPerson.name, equals(person.name));
        expect(createdPerson.age, equals(person.age));

        List<Car> cars = createdPerson.cars;
        expect(createdPerson.cars.length, equals(2));
        var sCar1 = cars[0];
        expect(sCar1.make, equals(car1.make));
        expect(sCar1.model, equals(car1.model));
        expect(sCar1.kilometers, equals(car1.kilometers));

        var sCar2 = cars[1];
        expect(sCar2.make, equals(car2.make));
        expect(sCar2.model, equals(car2.model));
        expect(sCar2.kilometers, equals(car2.kilometers));
      });
    });

    test('realm.close', () {
      var config = new Configuration();
      var realm = new Realm(config);
      expect(realm, isNotNull);

      realm.close();
      expect(realm.isClosed, isTrue);
    });

    test('realm.isInTransaction', () {
      var config = new Configuration();
      config.schema.add(Car);
      var realm = new Realm(config);
      expect(realm.isInTransaction, isFalse);
      realm.write(() {
        expect(realm.isInTransaction, isTrue);
      });
    });

    test('realm.delete', () {
      var config = new Configuration();
      config.schema.add(Car);

      var realm = new Realm(config);

      realm.write(() {
        realm.create(new Car()
          ..make = "Audi"
          ..model = "A4"
          ..kilometers = 245);

        realm.create(new Car()
          ..make = "Audi"
          ..model = "A6"
          ..kilometers = 245);

        realm.create(new Car()
          ..make = "Audi"
          ..model = "A8"
          ..kilometers = 245);

        realm.create(new Car()
          ..make = "Audi"
          ..model = "A10"
          ..kilometers = 245);

        var objects = realm.objects<Car>();
        expect(objects.length, equals(4));

        realm.delete(objects[0]);
        expect(objects.length, equals(3));

        List<Car> cars = [objects[0], objects[1]];
        realm.deleteMany(cars);
        expect(objects.length, equals(1));

        realm.deleteAll();
        expect(objects.length, equals(0));
      });
    });

    test('realm.find', () {
      var config = new Configuration();
      config.schema.addAll([Car, ServicedCar]);

      var realm = new Realm(config);

      var servicedCar = new ServicedCar()
        ..id = 1
        ..car = (new Car()
          ..make = "Audi"
          ..model = "A4"
          ..kilometers = 245);

      realm.write(() {
        realm.create(servicedCar);

        var foundCar = realm.find<ServicedCar>(1);
        expect(foundCar, isNotNull);
        expect(foundCar.id, equals(1));
        expect(foundCar.car, isNotNull);
        expect(foundCar.car.make, equals("Audi"));
        expect(foundCar.car.model, equals("A4"));
        expect(foundCar.car.kilometers, equals(245));
      });
    });
  });

  group('ResultsClass tests', () {
    test('Results.where', () {
      var config = new Configuration();
      config.schema.add(Car);

      var realm = new Realm(config);

      Car audi = new Car()
        ..make = "Audi"
        ..model = "A4"
        ..kilometers = 245;

      Car vw = new Car()
        ..make = "VW"
        ..model = "Passat"
        ..kilometers = 245;

      realm.write(() {
        realm.create(audi);
        realm.create(vw);
      });

      var objects = realm.objects<Car>().where("make =='Audi'");
      Car filteredCar = objects[0];
      expect(filteredCar, isA<Car>());
      expect(filteredCar.make, equals(audi.make));
      expect(filteredCar.model, equals(audi.model));
      expect(filteredCar.kilometers, equals(audi.kilometers));
    });

    test('Results.sort', () {
      var config = new Configuration();
      config.schema.add(Car);

      var realm = new Realm(config);
      realm.write(() {
        realm.create(new Car()
          ..make = "Audi"
          ..model = "A4"
          ..kilometers = 2);
        realm.create(new Car()
          ..make = "VW"
          ..model = "Passat"
          ..kilometers = 1);
      });

      var cars = realm.objects<Car>();
      expect(cars[0].make, "Audi");
      expect(cars[0].kilometers, 2);
      expect(cars[1].make, "VW");
      expect(cars[1].kilometers, 1);

      var reverseSortedCars = realm.objects<Car>().sort("kilometers");
      expect(reverseSortedCars[0].make, "VW");
      expect(reverseSortedCars[0].kilometers, 1);
      expect(reverseSortedCars[1].make, "Audi");
      expect(reverseSortedCars[1].kilometers, 2);
    });

    test('Results.sort reverse', () {
      var config = new Configuration();
      config.schema.add(Car);

      var realm = new Realm(config);
      realm.write(() {
        realm.create(new Car()
          ..make = "Audi"
          ..model = "A4"
          ..kilometers = 1);
        realm.create(new Car()
          ..make = "VW"
          ..model = "Passat"
          ..kilometers = 2);
      });

      var reverseSortedObjects = realm.objects<Car>().sort("kilometers", reverse: true);
      expect(reverseSortedObjects[0].kilometers, 2);
      expect(reverseSortedObjects[1].kilometers, 1);
    });

    test('Results enumerate', () {
      var config = new Configuration();
      config.schema.add(Car);

      var realm = new Realm(config);

      Car audi = new Car()
        ..make = "Audi"
        ..model = "A4"
        ..kilometers = 245;

      Car vw = new Car()
        ..make = "VW"
        ..model = "Passat"
        ..kilometers = 245;

      realm.write(() {
        realm.create(audi);
        realm.create(vw);
      });

      var cars = realm.objects<Car>();
      Car car = audi;
      for (var enumeratedCar in cars.asList()) {
        expect(enumeratedCar, isA<Car>());
        expect(enumeratedCar.make, equals(car.make));
        expect(enumeratedCar.model, equals(car.model));
        expect(enumeratedCar.kilometers, equals(car.kilometers));
        car = vw;
      }
    });

     test('Results isEmpty', () {
      var config = new Configuration();
      config.schema.add(Car);

      var realm = new Realm(config);
      expect(realm.objects<Car>().isEmpty(), isTrue);


      Car audi = new Car()
        ..make = "Audi"
        ..model = "A4"
        ..kilometers = 245;

      realm.write(() {
        realm.create(audi);
      });

      expect(realm.objects<Car>().isEmpty(), isFalse);
    });

     test('Results isValid', () {
      var config = new Configuration();
      config.schema.add(Car);

      var realm = new Realm(config);
      var cars = realm.objects<Car>();
      
      expect(cars.isValid, isTrue);

      realm.close();

      config = new Configuration()..schemaVersion = 1;
      config.schema.add(Car);
      realm = new Realm(config);
      expect(cars.isValid, isFalse);
    });

    test('Results indexOf', () {
      var config = new Configuration();
      config.schema.add(Car);

      var realm = new Realm(config);

      realm.write(() {
        Car car1 = realm.create(new Car()..make = "Audi"..model = "A4"..kilometers = 245);
        Car car2 = realm.create(new Car()..make = "VW"..model = "Passat"..kilometers = 245);

        var cars = realm.objects<Car>();
        expect(cars.indexOf(car1), 0);
        expect(cars.indexOf(car2), 1);
        realm.delete(car1);
        expect(cars.indexOf(car2), 0);
      });       
    });

    test('Results snapshot - new objects do not change snapshot', () {
      var config = new Configuration();
      config.schema.add(Car);

      var realm = new Realm(config);

      realm.write(() {
        Car car1 = realm.create(new Car()..make = "Audi"..model = "A4"..kilometers = 245);
        Car car2 = realm.create(new Car()..make = "VW"..model = "Passat"..kilometers = 245);

        var cars = realm.objects<Car>();
        var snapshot = cars.snapshot();
        expect(cars.length, 2);
        expect(snapshot.length, 2);

        // adding a new car
        Car car3 = realm.create(new Car()..make = "Audi"..model = "A1"..kilometers = 245);

        expect(cars.length, 3);
        expect(snapshot.length, 2);
      });
    });

    test('Results description', () {
      var config = new Configuration();
      config.schema.add(Car);

      var realm = new Realm(config);

      realm.write(() {
        realm.create(new Car()..make = "Audi"..model = "A4"..kilometers = 245);
        realm.create(new Car()..make = "VW"..model = "Passat"..kilometers = 245);

        var cars = realm.objects<Car>().where("make =='Audi'").sort("kilometers");
        expect(cars.description, 'make == "Audi" SORT(kilometers ASC)');
      });
    });

    test('Results.addListener', () async {
      var config = new Configuration();
      config.schema.add(Car);

      var realm = new Realm(config);
      realm.write(() {
        realm.create(new Car()..make = "Audi"..model = "A4"..kilometers = 245);
        realm.create(new Car()..make = "VW"..model = "Passat"..kilometers = 245);
      });

      String operation = "initial call";
      var listenerCalled = (String currentOperation) async {
        await Future.doWhile(() async {
          return operation == currentOperation;
        });
      };

      var cars = realm.objects<Car>();
      cars.addListener((collection, changes) {
        switch (operation) {
          case "initial call":
            expect(changes.insertions.length, 0);
            expect(changes.newModifications.length, 0);
            expect(changes.oldModifications.length, 0);
            expect(changes.deletions.length, 0);
            operation = "";
            break;
          case "create object":
            expect(changes.insertions.length, 1);
            expect(changes.newModifications.length, 0);
            expect(changes.oldModifications.length, 0);
            expect(changes.deletions.length, 0);
            operation = "";
            break;
          case "modify object":
            expect(changes.insertions.length, 0);
            expect(changes.newModifications.length, 1);
            expect(changes.oldModifications.length, 1);
            expect(changes.deletions.length, 0);
            operation = "";
            break;
          case "delete object":
            expect(changes.insertions.length, 0);
            expect(changes.newModifications.length, 0);
            expect(changes.oldModifications.length, 0);
            expect(changes.deletions.length, 1);
            operation = "";
            break;
          default: fail("The Results.addListener was invoked while the test was in unkown collection operation state '$operation'");
        }
      });

      // Notifications always contain the changes since the last time the callback was invoked
      // At first there will be no changes since there was no previous time the listener callback was invoked
      // The second notification will contain the changes since the first callback was invoked and so on..

      // Create object will rise the notification for initial call
      operation = "initial call";
      realm.write(() => {
        realm.create(new Car()..make = "Mercedes"..model = "S class"..kilometers = 245)
      });
      await listenerCalled("initial call");

      // Update object will rise the notification for `create object`
      operation = "create object";
      realm.write(() {
        realm.objects<Car>()[0].make = "Tesla";
      });
      await listenerCalled("create object");
      
      // Delete object will rise the notification for `update object`
      operation = "modify object";
      realm.write(() {
        realm.delete(realm.objects<Car>()[0]);
      });
      await listenerCalled("modify object");

      // This no-op will rise the notification for delete object
      operation = "delete object";
      realm.write(() { });
      await listenerCalled("delete object");
    });

    test('Results.removeListener', () async {
      var config = new Configuration();
      config.schema.add(Car);

      var realm = new Realm(config);

      String operation = "initial call";
      var listenerCalled = (String currentOperation) async {
        await Future.doWhile(() async {
          return operation == currentOperation;
        });
      };

      var cars = realm.objects<Car>();

      var listenerFailed = false;
      var listener = (collection, changes) {
        switch (operation) {
          case "initial call":
            expect(changes.insertions.length, 0);
            expect(changes.newModifications.length, 0);
            expect(changes.oldModifications.length, 0);
            expect(changes.deletions.length, 0);
            operation = "";
            break;
          default: listenerFailed = true;
        }
      };

      cars.addListener(listener);

      // This no-op will rise the notification for initial call
      operation = "initial call";
      realm.write(() => { });
      await listenerCalled("initial call");

      cars.removeListener(listener);

      var newListenerCalled = false;
      var newListenerCalledFuture = () async {
        await Future.doWhile(() async {
          return newListenerCalled == false;
        });
      };
      cars.addListener((collection, changes) {
        newListenerCalled = true;
      });

      // This will call every registered listener
      realm.write(() {
        realm.create(new Car()..make = "Mercedes"..model = "S class"..kilometers = 245);
      });
      await newListenerCalledFuture();
      // sanity check
      expect(newListenerCalled, true);

      // make a second realm operation to make sure it triggers all registered listeners
      newListenerCalled = false;
      realm.write(() {
        realm.deleteAll();
      });
      await newListenerCalledFuture();
      expect(newListenerCalled, true);

      expect(listenerFailed, false, reason: "The removed listener should not be called");
    });

    test('Results.removeAllListeners', () async {
      var config = new Configuration();
      config.schema.add(Car);

      var realm = new Realm(config);
      var cars = realm.objects<Car>();

      var listener1Called = false;
      var listener1CalledFuture = () async {
        await Future.doWhile(() async {
          return listener1Called == false;
        });
      };
      var listener1 = (collection, changes) {
        listener1Called = true;
      };

      var listener2Called = false;
      var listener2CalledFuture = () async {
        await Future.doWhile(() async {
          return listener2Called == false;
        });
      };
      var listener2 = (collection, changes) {
        listener2Called = true;
      };

      cars.addListener(listener1);
      cars.addListener(listener2);

      realm.write(() => { });
      realm.write(() => { });

      await listener1CalledFuture();
      await listener2CalledFuture();

      expect(listener1Called, true);
      expect(listener2Called, true);

      cars.removeAllListeners();

      listener1Called = false;
      listener2Called = false;
      
      realm.write(() => { 
        realm.create(new Car()
          ..make = "Mercedes"
          ..model = "S class"
          ..kilometers = 245)
      });
      realm.write(() => { realm.deleteAll() });

      expect(listener1Called, false, reason: "A removed listener1 should not be called");
      expect(listener2Called, false, reason: "A removed listener2 should not be called");
    });

  });
}
