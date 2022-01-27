![Realm](https://github.com/realm/realm-dart/raw/master/logo.png)

[![License](https://img.shields.io/badge/License-Apache-blue.svg)](LICENSE)

Realm is a mobile database that runs directly inside phones, tablets or wearables.
This repository holds the source code for the Realm SDK for Flutter™ and Dart™.

## Getting Started

To use the Realm SDK for Flutter add the [realm](https://pub.dev/packages/realm) package to your `pubspec.yaml` dependencies.

To use the Realm SDK for Dart add the [realm_dart](https://pub.dev/packages/realm_dart) package to your `pubspec.yaml` dependencies.


* Import Realm.
    ```dart
    import 'package:realm/realm.dart';
    ```

* Define a data model class `_Car`.
    ```dart
    @RealmModel()
    class _Car {
      late String make;

      late String model;
    
      int? kilometers = 500;
    }
    ```

* Generate RealmObject class `Car` from data model class `_Car`.

    ```
    dart run realm generate
    ```

* Open a Realm and add some objects.

    ```dart
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    var car = Car("Telsa", "Model Y", kilometers: 5);
    realm.write(() {
      realm.add(car);
    }
    ```

* Query objects in Realm.

    ```dart
    var cars = realm.all<Car>();
    Car myCar = cars[0];
    print("My car is ${myCar.make} model ${myCar.model}");

    cars = realm.all<Car>().query("make == 'Tesla'");
    ```

<img style="width: 0px; height: 0px;" src="https://3eaz4mshcd.execute-api.us-east-1.amazonaws.com/prod?s=https://github.com/realm/realm-dart#README.md">

## Documentation

For API documentation go to 
 * [Realm Flutter API Docs](https://pub.dev/documentation/realm/latest/)

 * [Realm Dart API Docs](https://pub.dev/documentation/realm_dart/latest/)

For a complete documentation go to [Realm Flutter and Dart SDK Docs](https://docs.mongodb.com/realm/sdk/flutter/).


##### The "Dart" name and logo and the "Flutter" name and logo are trademarks owned by Google.