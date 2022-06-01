import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'cli/metrics/metrics_command.dart';
import 'cli/metrics/options.dart';
import 'cli/common/target_os_type.dart';

import '../realm.dart' show isFlutterPlatform;
import '../realm.dart' show realmBinaryName;

DynamicLibrary? _library;

void _debugWrite(String message) {
  assert(() {
    print(message);
    return true;
  }());
}

/// @nodoc
// Initializes Realm library
DynamicLibrary initRealm() {
  if (_library != null) {
    return _library!;
  }

  if (!isFlutterPlatform) {
    assert(() {
      try {
        uploadMetrics(Options(
          targetOsType: Platform.operatingSystem.asTargetOsType,
          targetOsVersion: Platform.operatingSystemVersion,
        ));
      } catch (_) {} // ignore: avoid_catching_errors
      return true;
    }());
  }

  String _getBinaryPath(String binaryName) {
    if (Platform.isAndroid) {
      return "lib$binaryName.so";
    } else if (Platform.isLinux) {
      if (isFlutterPlatform) {
        return '${File(Platform.resolvedExecutable).parent.path}/lib/lib$binaryName.so';
      }

      return "binary/linux/lib$binaryName.so";
    } else if (Platform.isMacOS) {
      if (isFlutterPlatform) {
        return "${File(Platform.resolvedExecutable).parent.absolute.path}/../Frameworks/realm.framework/Resources/lib$binaryName.dylib";
      }

      return "${Directory.current.path}/binary/macos/lib$binaryName.dylib";
    } else if (Platform.isIOS) {
      return "${File(Platform.resolvedExecutable).parent.absolute.path}/Frameworks/realm_dart.framework/realm_dart";
    } else if (Platform.isWindows) {
      if (isFlutterPlatform) {
        return "$binaryName.dll";
      }

      return "binary/windows/$binaryName.dll";
    }

    throw Exception("Platform ${Platform.operatingSystem} not implemented");
  }

  var realmBinaryPath = _getBinaryPath(realmBinaryName);
  final realmLibrary = DynamicLibrary.open(realmBinaryPath);

  final initializeApi = realmLibrary.lookupFunction<IntPtr Function(Pointer<Void>), int Function(Pointer<Void>)>("realm_dart_initializeDartApiDL");
  var initResult = initializeApi(NativeApi.initializeApiDLData);
  if (initResult != 0) {
    throw Exception("Realm initialization failed. Error: could not initialize Dart APIs");
  }

  if (isFlutterPlatform && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    const String libName = 'realm_plugin';
    String binaryExt = Platform.isWindows ? ".dll" : Platform.isMacOS ? ".dylib" : ".so";
    String binaryNamePrefix = Platform.isWindows ? "" : "lib";
    final realmPluginLib = Platform.isMacOS == false ? DynamicLibrary.open("$binaryNamePrefix$libName$binaryExt") : DynamicLibrary.open('realm.framework/realm');
    final getDirNameFunc = realmPluginLib.lookupFunction<Pointer<Int8> Function(), Pointer<Int8> Function()>("realm_dart_get_app_directory_name");
    final dirNamePtr = getDirNameFunc();
    final dirName = dirNamePtr.cast<Utf8>().toDartString();
    print("DIRECTORY NAME: $dirName");
  }

  return _library = realmLibrary;
}
