// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../realm.dart' as realm show isFlutterPlatform;
import '../realm.dart' show realmBinaryName;
import 'cli/common/target_os_type.dart';
import 'cli/metrics/metrics_command.dart';
import 'cli/metrics/options.dart';
import 'realm_class.dart';

DynamicLibrary? _library;

String _getPluginPath(String libName) {
  if (Platform.isAndroid) {
    return libName;
  }
  if (Platform.isLinux) {
    return '$_exeDirName/lib/$libName';
  }
  if (Platform.isMacOS) {
    return '$_exeDirName/../Frameworks/$libName';
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

  DynamicLibrary? tryOpen(String path) {
    try {
      return DynamicLibrary.open(path);
    } on Error catch (_) {
      return null;
    }
  }

  Never throwError(Iterable<String> candidatePaths) {
    throw RealmError(
      [
        'Could not open $libName. Tried:',
        (candidatePaths.join('\n')),
        isFlutterPlatform //
            ? 'Did you forget to add a dependency on realm package?'
            : 'Did you forget to run `dart run realm_dart install`?'
      ].join('\n'),
    );
  }

  if (isFlutterPlatform) {
    final path = _getPluginPath(libName);
    return tryOpen(path) ?? throwError([path]);
  } else {
    final root = _getNearestProjectRoot(Platform.script.path) ?? _getNearestProjectRoot(p.current);
    final candidatePaths = [
      libName, // just ask OS..
      p.join(_exeDirName, libName), // try finding it next to the executable
      if (root != null) p.join(root, 'binary', Platform.operatingSystem, libName), // try finding it relative to project
    ];
    DynamicLibrary? lib;
    for (final path in candidatePaths) {
      lib = tryOpen(path);
      if (lib != null) return lib;
    }
    throwError(candidatePaths);
  }
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

  final realmLibrary = _openRealmLib();

  final initializeApi = realmLibrary.lookupFunction<IntPtr Function(Pointer<Void>), int Function(Pointer<Void>)>('realm_dart_initializeDartApiDL');
  var initResult = initializeApi(NativeApi.initializeApiDLData);
  if (initResult != 0) {
    throw AssertionError('Realm initialization failed. Error: could not initialize Dart APIs');
  }

  return _library = realmLibrary;
}
