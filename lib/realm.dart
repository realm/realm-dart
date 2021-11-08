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

//dart.library.cli is available only on dart desktop
import 'src/realm_flutter.dart' if (dart.library.cli) 'src/realm_dart.dart';

export 'src/realm_flutter.dart' if (dart.library.cli) 'src/realm_dart.dart';

var _initialized = false;

/// Initializes Realm library for Flutter
///
/// This method must be called in the main() method of the application before Realm is used
/// ```dart
/// void main() {
///   initRealm();
///   runApp(MyApp());
/// }
/// ```
///
void initRealm() {
  if (_initialized) {
    return;
  }

  String _platformPath(String name, {String? path}) {
    if (path == null) {
      path = '';
    }

    if (Platform.isAndroid) {
      return path + "lib" + name + ".so";
    }

    if (Platform.isLinux) {
      if (path.isEmpty) {
        path = 'binary/linux/';
      }
      return path + "lib" + name + ".so";
    }

    if (Platform.isMacOS) {
      if (path.isEmpty) {
        Directory sourceDir = new File.fromUri(Platform.script).parent;
        path = sourceDir.path + "/";
      }

      return path + "lib" + name + ".dylib";
    }

    if (Platform.isWindows) {
      if (path.isEmpty) {
        path = 'binary/windows/';
      }

      return path + name + ".dll";
    }

    if (Platform.isIOS) {
      return path + "/" + name;
    }

    throw Exception("Platform not implemented");
  }

  DynamicLibrary dlopenPlatformSpecific(String name, {String? path}) {
    if (Platform.isIOS) {
      return DynamicLibrary.process();
    }

    String fullPath = _platformPath(name, path: path);
    return DynamicLibrary.open(fullPath);
  }

  DynamicLibrary realmLibrary;
  if (Platform.isAndroid || Platform.isWindows || Platform.isIOS || Platform.isLinux || Platform.isMacOS) {
    realmLibrary = dlopenPlatformSpecific(RealmBinaryName);
  } else {
    throw Exception("Unsupported platform: ${Platform.operatingSystem}");
  }

  setRealmLib(realmLibrary);

  final initializeApi = realmLibrary.lookupFunction<IntPtr Function(Pointer<Void>), int Function(Pointer<Void>)>("realm_initializeDartApiDL");
  var initResult = initializeApi(NativeApi.initializeApiDLData);
  if (initResult != 0) {
    throw Exception("Realm initialization failed. Error: could not initialize Dart APIs");
  }

  _initialized = true;
}
