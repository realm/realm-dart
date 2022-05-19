import 'dart:ffi';
import 'dart:io';

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

  final realmLibrary = DynamicLibrary.open(_getBinaryPath(realmBinaryName));

  final initializeApi = realmLibrary.lookupFunction<IntPtr Function(Pointer<Void>), int Function(Pointer<Void>)>("realm_dart_initializeDartApiDL");
  var initResult = initializeApi(NativeApi.initializeApiDLData);
  if (initResult != 0) {
    throw Exception("Realm initialization failed. Error: could not initialize Dart APIs");
  }

  return _library = realmLibrary;
}
