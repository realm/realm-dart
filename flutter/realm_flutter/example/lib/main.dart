import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
// import 'package:realm_flutter/realm_flutter.dart';
import 'package:realm_flutter/realm.dart';

import 'dart:ffi';
import 'dart:io';

part 'main.g.dart';

class _Car {
  @RealmProperty()
  String make;
}

String _platformPath(String name, {String path}) {
  if (path == null) path = "";
  if (Platform.isLinux || Platform.isAndroid)
    return path + "lib" + name + ".so";
  if (Platform.isMacOS) return path + "lib" + name + ".dylib";
  if (Platform.isWindows) return path + name + ".dll";
  throw Exception("Platform not implemented");
}

DynamicLibrary dlopenPlatformSpecific(String name, {String path}) {
  if (Platform.isIOS) {
    final DynamicLibrary nativelib = DynamicLibrary.process();
    return nativelib;
  }

  String fullPath = _platformPath(name, path: path);
  return DynamicLibrary.open(fullPath);
}

void main() {
  print("Loading realm_flutter library");
  final testLibrary = dlopenPlatformSpecific("realm_flutter");
  print("finding the function");
  final initializeApi = testLibrary.lookupFunction<
    IntPtr Function(Pointer<Void>),
    int Function(Pointer<Void>)>("Dart_InitializeApiDL");

  print(initializeApi(NativeApi.initializeApiDLData) == 0);
  print("Running the app");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    print("initState");
    var config = new Configuration();
    config.schema.add(Car);

    var realm = new Realm(config);

    realm.write(() {
      print("realm write callback");
      var car = realm.create(new Car()..make = "Audi");
      print("The car is ${car.make}");
      // car.make = "VW";
      // print("The car is ${car.make}");
    });

    var objects = realm.objects<Car>();
    var indexedCar = objects[0];
    print("The indexedCar is ${indexedCar.make}");

    super.initState();
    //initPlatformState();
  }

  // // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initPlatformState() async {
  //   String platformVersion;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     platformVersion = await RealmFlutter.platformVersion;
  //   } on PlatformException {
  //     platformVersion = 'Failed to get platform version.';
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   setState(() {
  //     _platformVersion = platformVersion;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
