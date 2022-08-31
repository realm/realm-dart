import 'dart:ffi';
import 'dart:io';
import 'package:dylib/dylib.dart';

import 'cli/metrics/metrics_command.dart';
import 'cli/metrics/options.dart';
import 'cli/common/target_os_type.dart';

import '../realm.dart' as realm show isFlutterPlatform;
import '../realm.dart' show realmBinaryName;

DynamicLibrary? _library;

void _debugWrite(String message) {
  assert(() {
    print(message);
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

    String libPath = resolveDylibPath(
      binaryName, // foo.dll, libfoo.so, libfoo.dylib...
      dartDefine: 'LIB${binaryName.toUpperCase()}_PATH',
      environmentVariable: 'LIB${binaryName.toUpperCase()}_PATH',
    );
    if(FileSystemEntityType.notFound == FileSystemEntity.typeSync(libPath)) {
      libPath = resolveDylibPath(
        binaryName, // foo.dll, libfoo.so, libfoo.dylib...
        path: "binary/linux",
        dartDefine: 'LIB${binaryName.toUpperCase()}_PATH',
        environmentVariable: 'LIB${binaryName.toUpperCase()}_PATH',
      );
    }
    return libPath;
  } else if (Platform.isMacOS) {
    if (isFlutterPlatform) {
      return "${File(Platform.resolvedExecutable).parent.absolute.path}/../Frameworks/realm.framework/Resources/lib$binaryName.dylib";
    }

    String libPath = resolveDylibPath(
      binaryName, // foo.dll, libfoo.so, libfoo.dylib...
      dartDefine: 'LIB${binaryName.toUpperCase()}_PATH',
      environmentVariable: 'LIB${binaryName.toUpperCase()}_PATH',
    );
    if(FileSystemEntityType.notFound == FileSystemEntity.typeSync(libPath)) {
      libPath = resolveDylibPath(
        binaryName, // foo.dll, libfoo.so, libfoo.dylib...
        path: "${Directory.current.path}/binary/macos",
        dartDefine: 'LIB${binaryName.toUpperCase()}_PATH',
        environmentVariable: 'LIB${binaryName.toUpperCase()}_PATH',
      );
    }
    return libPath;
  } else if (Platform.isIOS) {
    return "${File(Platform.resolvedExecutable).parent.absolute.path}/Frameworks/realm_dart.framework/realm_dart";
  } else if (Platform.isWindows) {
    if (isFlutterPlatform) {
      return "$binaryName.dll";
    }

    String libPath = resolveDylibPath(
      binaryName, // foo.dll, libfoo.so, libfoo.dylib...
      dartDefine: 'LIB${binaryName.toUpperCase()}_PATH',
      environmentVariable: 'LIB${binaryName.toUpperCase()}_PATH',
    );
    if(FileSystemEntityType.notFound == FileSystemEntity.typeSync(libPath)) {
      libPath = resolveDylibPath(
        binaryName, // foo.dll, libfoo.so, libfoo.dylib...
        path: "binary/windows",
        dartDefine: 'LIB${binaryName.toUpperCase()}_PATH',
        environmentVariable: 'LIB${binaryName.toUpperCase()}_PATH',
      );
    }
    return libPath;
  }

  throw UnsupportedError("Platform ${Platform.operatingSystem} is not supported");
}

bool get isFlutterPlatform => realm.isFlutterPlatform;

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

  final realmBinaryPath = _getBinaryPath(realmBinaryName);
  final realmLibrary = DynamicLibrary.open(realmBinaryPath);

  final initializeApi = realmLibrary.lookupFunction<IntPtr Function(Pointer<Void>), int Function(Pointer<Void>)>("realm_dart_initializeDartApiDL");
  var initResult = initializeApi(NativeApi.initializeApiDLData);
  if (initResult != 0) {
    throw AssertionError("Realm initialization failed. Error: could not initialize Dart APIs");
  }

  return _library = realmLibrary;
}
