![Realm](https://github.com/realm/realm-dart/raw/main/logo.png)

[![License](https://img.shields.io/badge/License-Apache-blue.svg)](LICENSE)

## A simple command-line application using Realm Dart SDK

### Setup 
Run these commands to setup the application

*  Get all dependencies
    ```
    dart pub get
    ```

* Install the `realm_dart` package into the application. This downloads and copies the required native binaries to the app directory.
    ```
    dart run realm_dart install
    ```

* To generate RealmObject classes with realm_dart use this command.
    
    _*On Dart use `dart run realm_dart` to run `realm_dart` package commands*_

    ```
    dart run realm_dart generate
    ```
    A new file `bin/myapp.g.dart` will be created next to the `bin/myapp.dart`.
    
*  Run the application
    ```
    dart run
    ```

##### The "Dart" name and logo and the "Flutter" name and logo are trademarks owned by Google. 

