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
    // String pathSeparator = Platform.isWindows ? "\\" : "/";
    String binaryExt = Platform.isWindows ? ".dll" : Platform.isMacOS ? ".dylib" : ".so";
    // final realmPluginBinaryPath = "${File(realmBinaryPath).absolute.parent}${pathSeparator}realm_plugin$binaryExt";
    // print("realmBinaryPath ${File(realmBinaryPath)}");
    // print("realmPluginBinaryPath: $realmPluginBinaryPath");
    final realmPluginLib = DynamicLibrary.open("realm_plugin$binaryExt");
    final getDirNameFunc = realmPluginLib.lookupFunction<Pointer<Int8> Function(), Pointer<Int8> Function()>("realm_dart_get_app_directory_name");
    final m = getDirNameFunc();
    final dir = m.cast<Utf8>().toDartString();
    print("DIRECTORY NAME IS $dir");
  }

  return _library = realmLibrary;
}
