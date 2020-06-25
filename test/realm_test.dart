import 'dart:io';

import 'package:realm/realm.dart';
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
  int nameArgIndex = arguments.indexOf("--testname");
  if (arguments.length != 0) {
    if (nameArgIndex >= 0 && arguments.length > 1) {
      testName = arguments[nameArgIndex + 1];
    }
  }
}

void main(List<String> arguments) {
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

    test('Realm objects can be indexed', () {
      var config = new Configuration();
      config.schema.add(Car);

      var realm = new Realm(config);

      Car car = new Car()
        ..make = "Audi"
        ..model = "A4"
        ..kilometers = 245;
      realm.write(() {
        realm.create(car);
      });

      var objects = realm.objects<Car>();
      Car indexedCar = objects[0];

      expect(indexedCar, isA<Car>());
      expect(indexedCar.make, equals(car.make));
      expect(indexedCar.model, equals(car.model));
      expect(indexedCar.kilometers, equals(car.kilometers));
    });

    test('Realm notifications', () {
      var config = new Configuration();
      //config.schema.add(Car);

      var realm = new Realm(config);
      int notificationCount = 0;
      String notificationName;

      realm.addListener('change', (realm, name) {
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

        var objects = realm.objects<Car>();
        expect(objects.length, equals(3));

        realm.delete(objects[0]);
        expect(objects.length, equals(2));

        List<Car> cars = [objects[0], objects[1]];
        realm.deleteMany(cars);
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
    test('results.where', () {
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

    test('results.sort', () {
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
        realm.create(vw);
        realm.create(audi);
      });

      var objects = realm.objects<Car>();
      Car firstCar = objects[0];
      Car secondCar = objects[1];

      expect(firstCar.make, equals(vw.make));
      expect(secondCar.make, equals(audi.make));

      var sortedObjects = objects.sort("make");
      firstCar = sortedObjects[0];
      secondCar = sortedObjects[1];

      expect(firstCar.make, equals(audi.make));
      expect(secondCar.make, equals(vw.make));
    });

    test('results enumerate', () {
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
  });
}
