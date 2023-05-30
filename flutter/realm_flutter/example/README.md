![Realm](https://github.com/realm/realm-dart/raw/master/logo.png)

[![License](https://img.shields.io/badge/License-Apache-blue.svg)](LICENSE)

# realm_example

Demonstrates how to use the Realm SDK for Flutter™

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Setup 
Run these commands to setup the application

*  Get all dependencies
    ```
    flutter pub get
    ```

* For running Flutter widget and unit tests run the following command to install the required native binaries.

    ```
    dart run realm install
    ```

* To generate RealmObject classes with realm_dart use this command.
    
    _*On Dart use `dart run realm` to run `realm` package commands*_

    ```
    dart run realm generate
    ```
    A new file `lib/main.g.dart` will be created next to the `lib/main.dart`.
    
*  Run the application
    ```
    flutter run
    ```

##### The "Dart" name and logo and the "Flutter" name and logo are trademarks owned by Google. 