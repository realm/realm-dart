![Realm](https://github.com/realm/realm-dart/raw/master/logo.png)

[![License](https://img.shields.io/badge/License-Apache-blue.svg)](LICENSE)

Realm is a mobile database that runs directly inside phones, tablets or wearables.
This repository holds the source code for the Realm SDK for Flutter™ and Dart™.

**This project is in the Alpha stage. All API's might change without warning and no guarantees are given about stability. Do not use it in production.**

## Getting Started

* Import Realm in a dart file `app.dart`

    ```dart
    import 'package:realm/realm.dart';  // import realm package

    part 'app.g.dart'; // declare a part file.

    @RealmModel() // define a data model class named `_Car`.
    class _Car {
      late String make;

      late String model;

      int? kilometers = 500;
    }
    ```

* Generate RealmObject class `Car` from data model class `_Car`.

    ```
    flutter pub run realm generate
    ```

* Open a Realm and add some objects.

    ```dart
    var config = Configuration([Car.schema]);
    var realm = Realm(config);

    var car = Car("Tesla", "Model Y", kilometers: 5);
    realm.write(() {
      realm.add(car);
    });
    ```

* Query objects in Realm.

    ```dart
    var cars = realm.all<Car>();
    Car myCar = cars[0];
    print("My car is ${myCar.make} model ${myCar.model}");

    cars = realm.all<Car>().query("make == 'Tesla'");
    ```

* Get stream of result changes for a query.

    ```dart
    final cars = realm.all<Car>().query(r'make == $0', ['Tesla']);
    cars.changes.listen((changes) {
      print('Inserted indexes: ${changes.inserted}');
      print('Deleted indexes: ${changes.deleted}');
      print('Modified indexes: ${changes.modified}');
    });
    realm.write(() => realm.add(Car('VW', 'Polo', kilometers: 22000)));
    ```

## Samples

For complete samples check the [Realm Flutter and Dart Samples](https://github.com/realm/realm-dart-samples).

## Documentation

For API documentation go to
 * [Realm Flutter API Docs](https://pub.dev/documentation/realm/latest/)

 * [Realm Dart API Docs](https://pub.dev/documentation/realm_dart/latest/)

For a complete documentation go to [Realm Flutter and Dart SDK Docs](https://docs.mongodb.com/realm/sdk/flutter/).


## Limitations

* This version of Realm Flutter and Dart SDK allows working with a local only (on device) Realm database in Flutter and Dart desktop. Realm Sync functionality is not implemented.

* It provides the functionality for creating, retrieving, querying, sorting, filtering, updating Realm objects.

* Flutter Desktop on Linux is not supported yet.

* Migrations are not supported yet.

    If you change your data models often and receive a migration exception be sure to delete the old `default.realm` file in your application directory. It will get recreated with the new schema the next time the Realm is opened.

# Realm Flutter SDK

The Realm Flutter package name is `realm`

## Environment setup for Realm Flutter

* Supported platforms are Flutter (iOS, Android, Windows, MacOS) and Dart standalone (Windows, MacOS and Linux)

* Flutter ^3.0
* For Flutter Desktop environment setup check the guide [here](https://docs.flutter.dev/desktop)
* Cocoapods v1.11 or newer
* CMake 3.21 or newer

## Usage

**The full contents of `catalog.dart` is listed [after the usage](https://github.com/realm/realm-dart#full-contents-of-catalogdart)**

* Add `realm` package to a Flutter application.

    ```
    flutter pub add realm
    ```

* Import Realm in a dart file (ex. `catalog.dart`).

    ```dart
    import 'package:realm/realm.dart';
    ```

* Declare a part file `catalog.g.dart` in the begining of the `catalog.dart` dart file after all imports.

    ```dart
    import 'dart:io';

    part 'catalog.g.dart';
    ```

* Create a data model class.

    It should start with an underscore `_Item` and be annotated with `@RealmModel()`

    ```dart
    @RealmModel()
    class _Item {
        @PrimaryKey()
        late int id;

        late String name;

        int price = 42;
    }
    ```

* Generate RealmObject class `Item` from data model class `_Item`.

    _*On Flutter use `flutter pub run realm` to run `realm` package commands*_

    ```
    flutter pub run realm generate
    ```
    A new file `catalog.g.dart` will be created next to the `catalog.dart`.

    _*This file should be committed to source control_

* Use the RealmObject class `Item` with Realm.

    ```dart
    // Create a Configuration object
    var config = Configuration([Item.schema]);

    // Opean a Realm
    var realm = Realm(config);

    var myItem = Item(0, 'Pen', price: 4);

    // Open a write transaction
    realm.write(() {
        realm.add(myItem);
        var item = realm.add(Item(1, 'Pencil')..price = 20);
    });

    // Objects `myItem` and `item` are now managed and persisted in the realm

    // Read object properties from realm
    print(myItem.name);
    print(myItem.price);

    // Update object properties
    realm.write(() {
        myItem.price = 20;
        myItem.name = "Special Pencil";
    });

    // Get objects from the realm

    // Get all objects of type
    var items = realm.all<Item>();

    // Get object by index
    var item = items[1];

    // Get object by primary key
    var itemByKey = realm.find<Item>(0);

    // Filter and sort object
    var objects = realm.query<Item>("name == 'Special Pencil'");
    var name = 'Pen';
    objects = realm.query<Item>(r'name == $0', [name]]);

    // Close the realm
    realm.close();
    ```

## Full contents of `catalog.dart`

```dart
import 'package:realm/realm.dart';

part 'catalog.g.dart';

@RealmModel()
class _Item {
    @PrimaryKey()
    late int id;

    late String name;

    int price = 42;
}

// Create a Configuration object
var config = Configuration([Item.schema]);

// Opean a Realm
var realm = Realm(config);

var myItem = Item(0, 'Pen', price: 4);

// Open a write transaction
realm.write(() {
    realm.add(myItem);
    var item = realm.add(Item(1, 'Pencil')..price = 20);
});

// Objects `myItem` and `item` are now managed and persisted in the realm

// Read object properties from realm
print(myItem.name);
print(myItem.price);

// Update object properties
realm.write(() {
    myItem.price = 20;
    myItem.name = "Special Pencil";
});

// Get objects from the realm

// Get all objects of type
var items = realm.all<Item>();

// Get object by index
var item = items[1];

// Get object by primary key
var itemByKey = realm.find<Item>(0);

// Filter and sort object
var objects = realm.query<Item>("name == 'Special Pencil'");
var name = 'Pen';
objects = realm.query<Item>(r'name == $0', [name]]);

// Close the realm
realm.close();
```

# Realm Dart SDK

The Realm Dart package is `realm_dart`

## Environment setup for Realm Dart

* Supported platforms are Windows, Mac and Linux.

* Dart SDK ^2.17

## Usage

* Add `realm_dart` package to a Dart application.

    ```
    dart pub add realm_dart
    ```

* Install the `realm_dart` package into the application. This downloads and copies the required native binaries to the app directory.

    ```
    dart run realm_dart install
    ```

* Import realm_dart in a dart file (ex. `catalog.dart`).

    ```dart
    import 'package:realm_dart/realm.dart';
    ```

* To generate RealmObject classes with realm_dart use this command.

    _*On Dart use `dart run realm_dart` to run `realm_dart` package commands*_

    ```
    dart run realm_dart generate
    ```
    A new file `catalog.g.dart` will be created next to the `catalog.dart`.

    _*This file should be committed to source control_

* For more usage of Realm Dart see the Realm Flutter usage above.


# Building the source

## Building Realm Flutter

* Clone the repo
    ```
    git clone https://github.com/realm/realm-dart
    git submodule update --init --recursive
    ```

### Build Realm Flutter native binaries

* Android
    ```bash
    ./scripts/build-android.sh all
    scripts\build-android.bat all
    # Or for Android Emulator only
    ./scripts/build-android.sh x86
    scripts\build-android.bat x86
    ```

* iOS
    ```bash
    ./scripts/build-ios.sh
    # Or for iOS Simulator only
    ./scripts/build-ios.sh simulator
    ```

* Windows
    ```
    scripts\build.bat
    ```
* MacOS
    ```
    ./scripts/build-macos.sh
    ```

* Linux
    ```
    ./scripts/build-linux.sh
    ```

## Building Realm Dart

* Windows
    ```
    scripts\build.bat
    ```
* MacOS
    ```
    ./scripts/build-macos.sh
    ```
* Linux
    ```
    ./scripts/build-linux.sh
    ```

## Running tests

See [test/README.md](https://github.com/realm/realm-dart/master/test/README.md) for instructions on running tests.

## Versioning

Realm Flutter and Dart SDK packages follow [Semantic Versioning](https://semver.org/).
During the initial development the packages will be versioned according the scheme `0.major.minor+release stage` until the first stable version is reached then packages will be versioned with `major.minor.patch` scheme.

The first versions will follow `0.1.0+preview`, `0.1.1+preview` etc.
Then next release stages will pick up the next minor version `0.1.2+beta`, `0.1.3+beta`. This will ensure dependencies are updated on `dart pub get` with the new `alpha`, `beta` versions.
If an `alpha` version is released before `beta` and it needs to not be considered for `pub get` then it should be marked as `prerelease` with `-alpha` so  `0.1.2-alpha` etc.
Updating the major version with every release stage is also possible - `0.2.0+alpha`, `0.3.0+beta`, `0.3.1+beta`.


# Code of Conduct

This project adheres to the [MongoDB Code of Conduct](https://www.mongodb.com/community-code-of-conduct).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to [community-conduct@mongodb.com](mailto:community-conduct@mongodb.com).

# License

Realm Flutter and Dart SDKs and [Realm Core](https://github.com/realm/realm-core) are published under the Apache License 2.0.

**This product is not being made available to any person located in Cuba, Iran,
North Korea, Sudan, Syria or the Crimea region, or to any other person that is
not eligible to receive the product under U.S. law.**

##### The "Dart" name and logo and the "Flutter" name and logo are trademarks owned by Google.

<img style="width: 0px; height: 0px;" src="https://3eaz4mshcd.execute-api.us-east-1.amazonaws.com/prod?s=https://github.com/realm/realm-dart#README.md">
