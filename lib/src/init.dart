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
    }

    if (Platform.isLinux) {
      if (isFlutterPlatform) {
        return '${File(Platform.resolvedExecutable).parent.path}/lib/lib$binaryName.so';
      }

      return "binary/linux/lib$binaryName.so";
    }

    if (Platform.isMacOS) {
      if (isFlutterPlatform) {
        return "${File(Platform.resolvedExecutable).parent.absolute.path}/../Frameworks/realm.framework/Resources/lib$binaryName.dylib";
      }

      return "${Directory.current.path}/binary/macos/lib$binaryName.dylib";
    }

    if (Platform.isWindows) {
      if (isFlutterPlatform) {
        return "$binaryName.dll";
      }

      return "binary/windows/$binaryName.dll";
    }

    //ios links statically
    //if (Platform.isIOS) {
    //}

    throw Exception("Platform not implemented");
  }

  DynamicLibrary dlopenPlatformSpecific(String binaryName) {
    if (Platform.isIOS) {
      return DynamicLibrary.process();
    }

    String fullPath = _getBinaryPath(binaryName);
    return DynamicLibrary.open(fullPath);
  }

  DynamicLibrary realmLibrary;
  if (Platform.isAndroid || Platform.isWindows || Platform.isIOS || Platform.isLinux || Platform.isMacOS) {
    realmLibrary = dlopenPlatformSpecific(realmBinaryName);
  } else {
    throw Exception("Unsupported platform: ${Platform.operatingSystem}");
  }

  final initializeApi = realmLibrary.lookupFunction<IntPtr Function(Pointer<Void>), int Function(Pointer<Void>)>("realm_initializeDartApiDL");
  var initResult = initializeApi(NativeApi.initializeApiDLData);
  if (initResult != 0) {
    throw Exception("Realm initialization failed. Error: could not initialize Dart APIs");
  }

  _library = realmLibrary;
  return _library!;
}
