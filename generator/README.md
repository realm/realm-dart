![Realm](https://github.com/realm/realm-dart/raw/master/logo.png)

[![License](https://img.shields.io/badge/License-Apache-blue.svg)](LICENSE)

**This project is in the Alpha stage. All API's might change without warning and no guarantees are given about stability. Do not use it in production.**

# Description

Dart code generator that generates `RealmObject` classes based on `Realm` data model classes using naming conventions.

This package is part of the official Realm Flutter and Realm Dart SDKs https://github.com/realm/realm-dart

# Usage

* Add a dependency to [realm](https://pub.dev/packages/realm) package or [realm_dart](https://pub.dev/packages/realm_dart) package to your application.

To generate RealmObjects

* Run `flutter pub run realm generate` for Flutter projects

* Run `dart run realm_dart generate` for Dart projects

# Conventions

* Every Dart class annotated with `@RealmModel()` and named with an underscore like ` _ClassName`, is considered a Realm data model class and the code generator will generate a `RealmObject` class that can be used with Realm Flutter™ and Realm Dart™. 

* The Dart file containg Realm schema classes needs to have a part defintion name in the format

  `part "filename.g.dart"`.

  For example: In file `cars.dart ` there should be a part definition `part "cars.g.dart"`

* The underscore in the class name is requried. `class _Car`.

* Every field that references another `RealmObject` must use the schema class name of that RealmObject. For example:
  ```dart
  class _Car {
    late _Car secondCar;
  }
  ```

* The generator will infer the `Realm` type from the Dart type of every property of the class.

# Example  

Filename: `cars.dart`

```Dart
part "cars.g.dart"

@RealmModel()
class _Car {
  late String make; //required field
  late String? model; //optional field
  String kilometers = 500; //default value
  late _Car? secondCar; //Object relationship 1:1
  final List<_Car> allOtherCars; //Object relationship 1:Many
}
```

# Debugging

* On first use .dart_tool/build/entrypoint/build.dart needs to be generated with pub run build_runer build

* Use a terminal to launch a debuggee with command

  ```
  dart run --observe --pause-isolates-on-start  --enable-vm-service:5858/127.0.0.1  --disable-service-auth-codes .dart_tool/build/entrypoint/build.dart build
  ```

##### The "Dart" name and logo and the "Flutter" name and logo are trademarks owned by Google.