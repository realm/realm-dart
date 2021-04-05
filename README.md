![Realm](https://github.com/realm/realm-dart/raw/master/logo.png)

[![License](https://img.shields.io/badge/License-Apache-blue.svg)](LICENSE)

Realm is a mobile database that runs directly inside phones, tablets or wearables.
This repository holds the source code for the Realm SDK for Flutter™ and Dart™.


# Developer Preview

**This project is in Developer Preview stage, All API's might change without warning and no guarantees are given about stability. Do not use it in production.**

## Getting Started

* Import Realm.
    ```dart
    import 'package:realm/realm.dart';
    ```

* Define a data model class `_Car`.
    ```dart
    class _Car {
    @RealmProperty(primaryKey: true)
    String make;

    @RealmProperty()
    String model;
    
    @RealmProperty(defaultValue: "500", optional: true)
    int kilometers;
    }
    ```

* Generate Generates RealmObject class `Car` from data model class `_Car`.

    ```
    flutter pub run build_runner build
    ```

* Open a Realm and add some objects.

    ```dart
    var config = Configuration();
    config.schema.add(Car);

    var realm = Realm(config);

    realm.write(() {
        var car = realm.create(Car()..make = "Tesla"..model = "Model Y"..kilometers = 42);
    });
    ```

* Query objects in Realm.

    ```dart
    var cars = realm.objects<Car>();
    Car myCar = objects[0];
    print("My car is ${myCar.make} ${myCar.model}");

    cars = realm.objects<Car>().where("make == 'Tesla'");
    ```

## Samples

For complete samples check the [Realm Flutter and Dart Samples](https://github.com/realm/realm-dart-samples).

## Documentation

For API documentation go to 
 * [Realm Flutter API Docs](https://pub.dev/documentation/realm/latest/)

 * [Realm Dart API Docs](https://pub.dev/documentation/realm_dart/latest/)

For complete Realm documentation consult the documentation of the [Realm SDKs](https://docs.mongodb.com/realm-legacy/docs).


## Limitations

* Realm Flutter Preview requires a custom engine based on Flutter 2.0 with minimum changes. This will not be required in future versions of the SDK. More information can be found [here](https://github.com/realm/realm-dart/tree/preview/runtime).

* Realm Dart Preview package `realm_dart` can not be used with the Dart SDK 2.12 shippied with Flutter 2.0 since Flutter downloads a custom version of Dart SDK instead of using the official Dart SDK build and this custom version has issues loading native binaries. Instead an official Dart SDK 2.12 installation is needed in PATH.

* The preview version of Realm SDK for Flutter and Dart allows working with a local only (on device) Realm database in Flutter and Dart desktop. Realm Sync functionality is not implemented.

* It provides the functionality for creating, retrieving, querying, sorting, filtering, updating Realm objects and supports change notifications.

* Flutter Hot Reload is available only when running on the Android x86 Emulator and iOS Simulator.

* Running on a real Android device always includes the libraries in release mode.

* New projects for iOS can not be created with `flutter create`. As a workaround modify the sample project `provider_shopper` in [Realm Flutter and Dart Samples](https://github.com/realm/realm-dart-samples).


# Realm Flutter SDK

## Environment setup for Realm Flutter

* Supported platforms are Flutter for iOS (simulator), Android Emulator and Android devices.

* Flutter 2.0.0 `stable ref: 60bd88d date:3/3/2021`

    This version be downloaded from [here](https://flutter.dev/docs/development/tools/sdk/releases)

    ```
    flutter --version
    ```
    ```
    Flutter 2.0.0 • channel stable • https://github.com/flutter/flutter.git
    Framework • revision 60bd88df91 (3 weeks ago) • 2021-03-03 09:13:17 -0800
    Engine • revision 40441def69
    Tools • Dart 2.12.0
    ```

## Usage

* Add `realm` package dependency in the `pubspec.yaml` of the Flutter application.
    ```yaml
    dependencies:
        realm: ^0.1.0+preview
    ```

* Enable generation of RealmObjects.

    * Add `build_runner` package to `dev_dependencies`.
        ```
        dev_dependencies:
          build_runner: ^1.10.0
        ```
    * Enable `realm_generator` by adding a `build.yaml` file to the application.
        ```yaml
        targets:
            $default:
                builders:
                    realm_generator|realm_object_builder:
                        enabled: true
                        generate_for:
                            - lib/*.dart 
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

    * Create a data model class

        ```dart
        class _Item {
            @RealmProperty(primaryKey: true)
            int id;

            @RealmProperty()
            String name;

            @RealmProperty(defaultValue: '42')
            int price;
        }
        ```
    * Run `build_runner` to generate RealmObject class `Item` from data model class `_Item`.

        ```
        flutter pub run build_runner build
        ```
        A new file `catalog.g.dart` will be created next to the `catalog.dart`.
        
        _*This file should be committed in source control_

    * Use the RealmObject class `Item` with Realm.

        ```dart
        // Create a Configuration object
        var config = Configuration();

        // Add RealmObjects to the configuration schema
        config.schema.add(Item);

        // Opean a Realm
        realm = Realm(config);

        // Open a write transaction
        realm.write(() {
            realm.create(Item()..id = 0..name = 'Item'..price = 20);
        });

        // Get objects from the realm

        // Get all objects
        var items = realm.objects<Item>();
        
        // Get object by index
        var item = items[5];
        
        // Get object by primary key
        var primaryKey = 0;
        var itemByKey = realm.find<Item>(primaryKey);
        
        // Filter and sort object
        var objects = realm.objects<Item>().where("name == 'Special Item'").sort("price");;
        ```

# Realm Dart SDK

## Environment setup for Realm Dart

* Supported platforms are Windows and Mac.

* Dart SDK 2.12 stable needs to be in the PATH env variable. 

   **Do not use the Dart SDK downloaded with Flutter 2.0 since it has issues and will not be able to run the `realm_dart` package correctly** 

   Download Dart SDK 2.12 stable from here  https://dart.dev/tools/sdk/archive unzip it **`and add the directory to the PATH before the Flutter path`**.

    * On Mac

    ```
    export /Users/<YOUR_PATH>/dart-sdk.2.12.0/bin:$PATH
    ```

    * On Windows

    ```
    set PATH=C:\<YOUR_PATH>\dartsdk-windows-x64-release-2.12.0\bin;%PATH% 
    ```

## Usage

* Add `realm_dart` package dependency in the `pubspec.yaml` of the Dart application.

    ```yaml
    dependencies:
        realm_dart: ^0.1.0+preview
    ```

* Install the `realm_dart` package into the application.

    ```
    pub run realm_dart install
    ``` 

* Enable generation of Realm schema objects.

    * Add `build_runner` package to `dev_dependencies`.

        ```
        dev_dependencies:
          build_runner: ^1.10.0
        ```
    * Enable realm_generator by adding a `build.yaml` file to the application.

        ```yaml
        targets:
            $default:
                builders:
                    realm_generator|realm_object_builder:
                        enabled: true
                        generate_for:
                            - bin/*.dart 
        ```
* Run the `build_runner` to generate RealmObjects classes from Realm data model classes.

    ```
    dart run build_runner build
    ```

## Usage

For usage see the Realm Flutter usage above


# Building the source

## Realm Flutter

### Build the native Android binary 

`/android> gradlew externalNativeBuildDebug`

## Realm Dart

### Buildign Realm Dart package for Windows

```
cmake.exe -A x64 -DCMAKE_CONFIGURATION_TYPES:STRING="Release" -S . -B out
cmake --build out --config Release
```

### Building Realm Dart package for Mac

```
cmake -G Ninja  -S . -B out
cmake --build out --config Release
```

### Versioning

Realm Flutter and Dart SDK packages follow [Semantic Versioning](https://semver.org/)
During the initial development the packages will be versioned according the scheme `0.major.minor+release stage` until the first stable version is reached then packages will be versioned with `major.minor.patch` scheme.

The first versions will follow `0.1.0+preview`, `0.1.1+preview` etc.
Then next release stage will pick up the next minor version `0.1.2+beta`, `0.1.3+beta`. This will ensure dependencies are updated on `pub get` with the new `beta` versions.
If an `alpha` version is released before `beta` and it needs to not be considered for `pub get` then it should be marked as `prerelease` with `-alpha` so  `0.1.2-alpha` etc. 
Updating the major version with every release stage is also possible - `0.2.0+beta`, `0.2.1+beta`.

##### The "Dart" name and logo and the "Flutter" name and logo are trademarks owned by Google. 
