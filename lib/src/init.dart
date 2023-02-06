import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../realm.dart' as realm show isFlutterPlatform;
import '../realm.dart' show realmBinaryName;
import 'cli/common/target_os_type.dart';
import 'cli/metrics/metrics_command.dart';
import 'cli/metrics/options.dart';
import 'native/realm_core.dart';

DynamicLibrary? _library;

void _debugWrite(String message) {
  assert(() {
    print(message);
    return true;
  }());
}

String _getBinaryPath(String libName) {
  if (Platform.isAndroid) {
    return libName;
  }
  if (Platform.isLinux) {
    return '$_exeDirName/lib/$libName';
  }
  if (Platform.isMacOS) {
    return '$_exeDirName/../Frameworks/realm.framework/Resources/$libName';
  }
  if (Platform.isIOS) {
    return '$_exeDirName/Frameworks/realm_dart.framework/$libName';
  }
  if (Platform.isWindows) {
    return libName;
  }
  _platformNotSupported();
}

bool get isFlutterPlatform => realm.isFlutterPlatform;

String _getLibName(String stem) {
  if (Platform.isMacOS) return 'lib$stem.dylib';
  if (Platform.isIOS) return stem;
  if (Platform.isWindows) return '$stem.dll';
  if (Platform.isAndroid || Platform.isLinux) return 'lib$stem.so';
  _platformNotSupported(); // we don't support Fuchsia yet
}

String? _getNearestProjectRoot(String dir) {
  while (dir != p.dirname(dir)) {
    if (File(p.join(dir, 'pubspec.yaml')).existsSync()) return dir;
    dir = p.dirname(dir);
  }
  return null;
}

Never _platformNotSupported() => throw UnsupportedError('Platform ${Platform.operatingSystem} is not supported');

String get _exeDirName => p.dirname(Platform.resolvedExecutable);

DynamicLibrary _openRealmLib() {
  final libName = _getLibName(realmBinaryName);
  final root = _getNearestProjectRoot(Platform.script.path) ?? _getNearestProjectRoot(p.current);

  // Try to open lib from various candidate paths
  LoadRealmLibraryError? ex;
  for (final open in [
    () => _open(libName), // just ask OS..
    () => _open(p.join(_exeDirName, libName)), // try finding it next to the executable
    if (root != null) () => _open(p.join(root, 'binary', Platform.operatingSystem, libName)), // try finding it relative to project
    () => _open(_getBinaryPath(libName)), // find it where it is installed by plugin
  ]) {
    try {
      return open();
    } on Error catch (e) {
      ex ??= LoadRealmLibraryError();
      ex.add(e);
    }
  }
  throw ex!; // rethrow first
}

DynamicLibrary _open(String lib) => DynamicLibrary.open(lib);

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

  final realmLibrary = _openRealmLib();

  final initializeApi = realmLibrary.lookupFunction<IntPtr Function(Pointer<Void>), int Function(Pointer<Void>)>('realm_dart_initializeDartApiDL');
  var initResult = initializeApi(NativeApi.initializeApiDLData);
  if (initResult != 0) {
    throw AssertionError('Realm initialization failed. Error: could not initialize Dart APIs');
  }

  return _library = realmLibrary;
}

class LoadRealmLibraryError extends Error {
  List<Error> loadingFromPathErrors = [];
  void add(Error err) {
    loadingFromPathErrors.add(err);
  }

  @override
  @override
  String toString() {
    List<String> errMessages = [];
    for (Error err in loadingFromPathErrors) {
      errMessages.add(err.toString());
    }
    return errMessages.join('\n');
  }
}
