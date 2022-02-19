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

// ignore_for_file: unused_local_variable

import 'dart:io';
import 'package:test/test.dart' hide test, throws;
import 'test_base.dart';
import '../lib/realm.dart';
import 'test_model.dart';

Future<void> main([List<String>? args]) async {
  parseTestNameFromArguments(args);

  print("Current PID $pid");

  setupTests(Configuration.filesPath, (path) => {Configuration.defaultPath = path});

  test('Realm add object', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    realm.write(() {
      realm.add(Car(''));
    });

    realm.close();
  });

  test('Realm add multiple objects', () {
    final config = Configuration([Car.schema]);
    final realm = Realm(config);

    final cars = [
      Car('Mercedes'),
      Car('Volkswagen'),
      Car('Tesla'),
    ];

    realm.write(() {
      realm.addAll(cars);
    });

    final allCars = realm.all<Car>();
    expect(allCars, cars);

    realm.close();
  });

  test('Realm add object twice does not throw', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    realm.write(() {
      final car = Car('');
      realm.add(car);

      //second add of the same object does not throw and return the same object
      final car1 = realm.add(car);
      expect(car1, equals(car));
    });

    realm.close();
  });

  test('Realm adding not configured object throws exception', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    expect(() => realm.write(() => realm.add(Person(''))), throws<RealmException>("not configured"));
    realm.close();
  });

  test('Realm add returns the same object', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    final car = Car('');
    Car? addedCar;
    realm.write(() {
      addedCar = realm.add(car);
    });

    expect(addedCar == car, isTrue);

    realm.close();
  });

  test('Realm add object transaction rollbacks on exception', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    expect(() {
      realm.write(() {
        realm.add(Car("Tesla"));
        throw Exception("some exception while adding objects");
      });
    }, throws<Exception>("some exception while adding objects"));

    final car = realm.find<Car>("Telsa");
    expect(car, isNull);

    realm.close();
  });

  test('Realm adding objects with duplicate primary keys throws', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    final carOne = Car("Toyota");
    final carTwo = Car("Toyota");
    realm.write(() => realm.add(carOne));
    expect(() => realm.write(() => realm.add(carTwo)), throws<RealmException>());

    realm.close();
  });

  test('RealmObject get property', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    final car = Car('Tesla');
    realm.write(() {
      realm.add(car);
    });

    expect(car.make, equals('Tesla'));

    realm.close();
  });

  test('RealmObject set property', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

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

    realm.close();
  });

  test('RealmObject set object type property (link)', () {
    var config = Configuration([Person.schema, Dog.schema]);
    var realm = Realm(config);

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

    realm.close();
  });

  test('RealmObject set property null', () {
    var config = Configuration([Person.schema, Dog.schema]);
    var realm = Realm(config);

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

    realm.close();
  });

  test('Realm find object by primary key', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    realm.write(() => realm.add(Car("Opel")));

    final car = realm.find<Car>("Opel");
    expect(car, isNotNull);

    realm.close();
  });

  test('Realm find not configured object by primary key throws exception', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    expect(() => realm.find<Person>("Me"), throws<RealmException>("not configured"));

    realm.close();
  });

  test('Realm find object by primary key default value', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    realm.write(() => realm.add(Car('Tesla')));

    final car = realm.find<Car>("Tesla");
    expect(car, isNotNull);
    expect(car?.make, equals("Tesla"));

    realm.close();
  });

  test('Realm find non existing object by primary key returns null', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    realm.write(() => realm.add(Car("Opel")));

    final car = realm.find<Car>("NonExistingPrimaryKey");
    expect(car, isNull);

    realm.close();
  });

  test('Realm delete object', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    final car = Car("SomeNewNonExistingValue");
    realm.write(() => realm.add(car));

    final car1 = realm.find<Car>("SomeNewNonExistingValue");
    expect(car1, isNotNull);

    realm.write(() => realm.delete(car1!));

    var car2 = realm.find<Car>("SomeNewNonExistingValue");
    expect(car2, isNull);

    realm.close();
  });

  test('Equals', () {
    var config = Configuration([Dog.schema, Person.schema]);
    var realm = Realm(config);

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
    realm.close();
  });

  test('RealmObject isValid', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

    var team = Team("team one");
    expect(team.isValid, true);
    realm.write(() {
      realm.add(team);
    });
    expect(team.isValid, true);
    realm.close();
    expect(team.isValid, false);
  });

  test('Access deleted object', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

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
    realm.close();
  });

  test('Add object after realm is closed', () {
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    final car = Car('Tesla');

    realm.close();
    expect(() => realm.write(() => realm.add(car)), throws<RealmException>("Cannot access realm that has been closed"));
  });

  test('Edit object after realm is closed', () {
    var config = Configuration([Person.schema]);
    var realm = Realm(config);

    final person = Person('Markos');

    realm.write(() => realm.add(person));
    realm.close();
    expect(() => realm.write(() => person.name = "Markos Sanches"), throws<RealmException>("Cannot access realm that has been closed"));
  });

  test('Edit deleted object', () {
    var config = Configuration([Person.schema]);
    var realm = Realm(config);

    final person = Person('Markos');

    realm.write(() {
      realm.add(person);
      realm.delete(person);
    });
    expect(() => realm.write(() => person.name = "Markos Sanches"),
        throws<RealmException>("Accessing object of type Person which has been invalidated or deleted"));
    realm.close();
  });

  test('Realm adding objects graph', () {
    var studentMichele = Student(1)
      ..name = "Michele Ernesto"
      ..yearOfBirth = 2005;
    var studentLoreta = Student(2, name: "Loreta Salvator", yearOfBirth: 2006);
    var studentPeter = Student(3, name: "Peter Ivanov", yearOfBirth: 2007);

    var school131 = School("JHS 131", city: "NY");
    school131.students.addAll([studentMichele, studentLoreta, studentPeter]);

    var school131Branch1 = School("First branch 131A", city: "NY Bronx")
      ..branchOfSchool = school131
      ..students.addAll([studentMichele, studentLoreta]);

    studentMichele.school = school131Branch1;
    studentLoreta.school = school131Branch1;

    var school131Branch2 = School("Second branch 131B", city: "NY Bronx")
      ..branchOfSchool = school131
      ..students.add(studentPeter);

    studentPeter.school = school131Branch2;

    school131.branches.addAll([school131Branch1, school131Branch2]);

    var config = Configuration([School.schema, Student.schema]);
    var realm = Realm(config);

    realm.write(() => realm.add(school131));

    //Check schools
    var schools = realm.all<School>();
    expect(schools.length, 3);

    //Check students
    var students = realm.all<Student>();
    expect(students.length, 3);

    //Check branches
    var branches = realm.all<School>().query('branchOfSchool != nil');
    expect(branches.length, 2);
    expect(branches[0].students.length + branches[1].students.length, 3);

    //Check main schools
    var mainSchools = realm.all<School>().query('branchOfSchool = nil');
    expect(mainSchools.length, 1);
    expect(mainSchools[0].branches.length, 2);
    expect(mainSchools[0].students.length, 3);
    expect(mainSchools[0].branches[0].students.length + mainSchools[0].branches[1].students.length, 3);
    realm.close();
  });
}
