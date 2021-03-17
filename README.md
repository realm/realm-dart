![Realm](logo.png)

[![License](https://img.shields.io/badge/License-Apache-blue.svg)](LICENSE)

Realm is a mobile database that runs directly inside phones, tablets or wearables.
This repository holds the source code for the Realm SDK for Flutter™ and Dart™

**This project is in experimental stage, it should not be used in production.**

The preview version of Realm SDK for Flutter and Dart allows working with a local Realm database in Dart standalone and Flutter. It provides the functionality for creating, retrieving, querying, sorting, filtering, updating Realm objects and supports change notifications.

This Realm SDK is implemented as a Dart library and a native code library which is loaded in the application by the user code. 

Flutter Hot Reload is available only when running on the Android x86 Emulator.

Running on a real Android device always includes the libraries in release mode.


# >>>>>> TODO: INSERT Realm Flutter Usage here


# Usage
* Add `realm_dart` package dependency in the pubspec.yaml of the Dart application
    ```
    dependencies:
        realm_dart: ^0.1.0-preview
    ```

* [Windows only] Install the `realm_dart` package into the application

    ```
    pub run realm_dart install
    ``` 

* Enable generation of Realm schema objects 

    * Add `build_runner` package to `dev_dependencies`
        ```
        dev_dependencies:
          build_runner: ^1.10.0
        ```
    * Enable realm_generator by adding a `build.yaml` file to the application
        ```
        targets:
            $default:
                builders:
                    realm_generator|realm_object_builder:
                        enabled: true
                        generate_for:
                            - bin/*.dart 
        ```
# >>>> TODO: Complete the usage of Realm and schema generation

* To generate Realm schema objects when needed 
    * Execute the `build_runner`
    ```
    pub run build_runner build
    ```
 
# Building the source

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

##### The "Dart" name and logo and the "Flutter" name and logo are trademarks owned by Google. 
