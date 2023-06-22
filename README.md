![Realm](https://github.com/realm/realm-dart/raw/main/logo.png)

[![License](https://img.shields.io/badge/License-Apache-blue.svg)](LICENSE)
[![Realm Dart CI](https://github.com/realm/realm-dart/actions/workflows/ci.yml/badge.svg)](https://github.com/realm/realm-dart/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/realm/realm-dart/badge.svg?branch=main)](https://coveralls.io/github/realm/realm-dart?branch=main)

Realm is a mobile database that runs directly inside phones, tablets or wearables.
This repository holds the source code for the Realm SDK for Flutter™ and Dart™.

## Features

* **Mobile-first:** Realm is the first database built from the ground up to run directly inside phones, tablets, and wearables.
* **Simple:** Realm’s object-oriented data model is simple to learn, doesn’t need an ORM, and the [API](https://pub.dev/documentation/realm/latest/) lets you write less code to get apps up & running in minutes.
* **Modern:** Realm supports latest Dart and Flutter versions and is build with sound null-safety.
* **Fast:** Realm is faster than even raw SQLite on common operations while maintaining an extremely rich feature set.
* **[Device Sync](https://www.mongodb.com/atlas/app-services/device-sync)**: Makes it simple to keep data in sync across users, devices, and your backend in real-time. Get started for free with [a template application](https://github.com/mongodb/template-app-dart-flutter-todo) and [create the cloud backend](https://mongodb.com/realm/register?utm_medium=github_atlas_CTA&utm_source=realm_dart_github).

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
    dart run realm generate
    ```

* Open a Realm and add some objects.

    ```dart
    var config = Configuration.local([Car.schema]);
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

Use [realm](https://pub.dev/packages/realm) package for Flutter and [realm_dart](https://pub.dev/packages/realm_dart) package for Dart applications.

For complete documentation of the SDKs, go to the [Realm SDK documentation](https://docs.mongodb.com/realm/sdk/flutter/).

If you are using the Realm SDK for the first time, refer to the [Quick Start documentation](https://www.mongodb.com/docs/realm/sdk/flutter/quick-start/).

To learn more about using Realm with Atlas App Services and Device Sync, refer to the following Realm SDK documentation:

- [App Services Overview](https://www.mongodb.com/docs/realm/sdk/flutter/app-services/)
- [Device Sync Overview](https://www.mongodb.com/docs/realm/sdk/flutter/sync/)

# Realm Flutter SDK

Realm Flutter package is published to [realm](https://pub.dev/packages/realm).

## Environment setup for Realm Flutter

* Realm Flutter supports the platforms iOS, Android, Windows, MacOS and Linux.

* Flutter 3.0.3 or newer.
* For Flutter Desktop environment setup, see [Desktop support for Flutter](https://docs.flutter.dev/desktop).
* Cocoapods v1.11 or newer.
* CMake 3.21 or newer.

## Usage

**The full contents of `catalog.dart` is listed [after the usage](https://github.com/realm/realm-dart#full-contents-of-catalogdart)**

* Add `realm` package to a Flutter application.

    ```
    flutter pub add realm
    ```
* For running Flutter widget and unit tests run the following command to install the required native binaries.

    ```
    dart run realm install
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

    _*On Flutter use `dart run realm` to run `realm` package commands*_

    ```
    dart run realm generate
    ```
    A new file `catalog.g.dart` will be created next to the `catalog.dart`.

    _*The generated file should be committed to source control_

* Use the RealmObject class `Item` with Realm.

    ```dart
    // Create a Configuration object
    var config = Configuration.local([Item.schema]);

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
    objects = realm.query<Item>(r'name == $0', [name]);

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
var config = Configuration.local([Item.schema]);

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
objects = realm.query<Item>(r'name == $0', [name]);

// Close the realm
realm.close();
```

# Realm Dart Standalone SDK

Realm Dart package is published to [realm_dart](https://pub.dev/packages/realm_dart).

## Environment setup for Realm Dart

* Realm Dart supports the platforms Windows, Mac and Linux.

* Dart SDK 2.17.5 or newer.

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

    _*The generated file should be committed to source control_

* The usage of the Realm Dart SDK is the same like the Realm Flutter above.

# Sync data with Realm Flutter and Dart using Device Sync

This section is about how to use the Realm with [Device Sync](https://www.mongodb.com/docs/realm/sdk/flutter/sync/) and how to connect to [Atlas App Services](https://www.mongodb.com/docs/realm/sdk/flutter/app-services/).

### I. Set up Atlas App Services
  1. Create an account on [cloud.mongodb.com](https://cloud.mongodb.com). Follow the instructions: [Register a new Atlas Account](https://www.mongodb.com/docs/atlas/tutorial/create-atlas-account/#register-a-new-service-account).
  1. Create a new App following the instructions here: [Create an App with Atlas App Services UI](https://www.mongodb.com/docs/atlas/app-services/manage-apps/create/create-with-realm-ui).
  1. Read [Authentication Providers](https://www.mongodb.com/docs/atlas/app-services/authentication/providers/) to see how to configure the appropriate authentication provider type.
  1. Go to the **Device Sync** menu and [Enable Flexible Sync](https://www.mongodb.com/docs/atlas/app-services/sync/configure/enable-sync/#enable-flexible-sync).
  1. [Find and Copy the App ID](https://www.mongodb.com/docs/atlas/app-services/reference/find-your-project-or-app-id/) of your new application.

### II. Use Device Sync with the Realm

1. Initialize the App Services `App` client and authenticate a user.

   ``` dart
   String appId = "<Atlas App ID>";
   final appConfig = AppConfiguration(appId);
   final app = App(appConfig);
   final user = await app.logIn(Credentials.anonymous());
   ```
1. Open a synced realm.

   ``` dart
   final config = Configuration.flexibleSync(user, [Task.schema]);
   final realm = Realm(config);
   ```

1. Add a sync subscription and write data.

   Only data matching the query in the subscription will be synced to the server and only data matching the subscription will be downloaded to the local device realm file.
   
   ``` dart
   realm.subscriptions.update((mutableSubscriptions) {
   mutableSubscriptions.add(realm.query<Task>(r'status == $0 AND progressMinutes == $1', ["completed", 100]));
   });
   await realm.subscriptions.waitForSynchronization();
   realm.write(() {
     realm.add(Task(ObjectId(), "Send an email", "completed", 4));
     realm.add(Task(ObjectId(), "Create a meeting", "completed", 100));
     realm.add(Task(ObjectId(), "Call the manager", "init", 2));
   });
   realm.close();
   ```

To learn more about how to sync data with Realm using Device Sync, refer to the [Quick Start with Sync documentation](https://www.mongodb.com/docs/realm/sdk/flutter/quick-start/#sync-realm-with-mongodb-atlas).

# Building the source

See [CONTRIBUTING.md](https://github.com/realm/realm-dart/blob/main/CONTRIBUTING.md#building-the-source) for instructions about building the source.

# Code of Conduct

This project adheres to the [MongoDB Code of Conduct](https://www.mongodb.com/community-code-of-conduct).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to [community-conduct@mongodb.com](mailto:community-conduct@mongodb.com).

# License

Realm Flutter and Dart SDKs and [Realm Core](https://github.com/realm/realm-core) are published under the Apache License 2.0.

##### The "Dart" name and logo and the "Flutter" name and logo are trademarks owned by Google.

<img style="width: 0px; height: 0px;" src="https://3eaz4mshcd.execute-api.us-east-1.amazonaws.com/prod?s=https://github.com/realm/realm-dart#README.md">
