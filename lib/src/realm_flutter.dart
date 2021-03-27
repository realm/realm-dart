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

import 'dart:ffi';
import 'dart:io';

//This should be exactly identical to realm_dart.dart without the "import 'dart-ext:realm_dart_extension'";
import 'realm_class.dart';

export 'realm_class.dart';
//hide Results, Helpers, DynamicObject;

const bool IsFlutterPlatform = true;

var _initialized = false;
/// Initializes Realm library
/// 
/// This function must be called in the main() funciton of the application before Realm is used
/// ```dart
/// void main() {
///   initRealm();
///   runApp(MyApp());
/// }
/// ```
void initRealm() {
  if (_initialized) {
    return;
  }

  String _platformPath(String name, {String path}) {
    if (path == null) path = "";
    if (Platform.isLinux || Platform.isAndroid) return path + "lib" + name + ".so";
    if (Platform.isMacOS) return path + "lib" + name + ".dylib";
    if (Platform.isWindows) return path + name + ".dll";
    if (Platform.isIOS) return path + "/" + name;
    throw Exception("Platform not implemented");
  }

  DynamicLibrary dlopenPlatformSpecific(String name, {String path}) {
    String fullPath = _platformPath(name, path: path);
    return DynamicLibrary.open(fullPath);
  }

  DynamicLibrary realmLibrary;
  if (Platform.isIOS) {
    //in release load from the binary
    try {
      realmLibrary = dlopenPlatformSpecific("realm", path: "Flutter.framework");
    }
    catch (e) {
      //in dev mode load from the process
      print("Loading realm library in dev mode");
      realmLibrary = DynamicLibrary.process();
    }
  }
  else if (Platform.isAndroid) {
    realmLibrary = dlopenPlatformSpecific("realm_flutter");
  }
  else {
    throw Exception("Unsupported platform: ${Platform.operatingSystem}");
  }


  print("Finding the Realm initialization functions");
  final initializeApi = realmLibrary.lookupFunction<IntPtr Function(Pointer<Void>), int Function(Pointer<Void>)>("Dart_InitializeApiDL");
  if (initializeApi == null) {
    print("Realm initialization function not found");
    throw Exception("Realm initialization function not found");
  }

  print("calling Realm initialization");
  var initResult = initializeApi(NativeApi.initializeApiDLData);
  if(initResult == 0) {
      print("Realm initialization success");
  }

  _initialized = true;
}