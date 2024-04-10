// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';
import 'dart:io';

import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;

import '../realm.dart' as realm show isFlutterPlatform;
import 'cli/common/target_os_type.dart';
import 'cli/metrics/metrics_command.dart';
import 'cli/metrics/options.dart';
import 'realm_class.dart';

const realmBinaryName = 'realm_dart';
final targetOsType = Platform.operatingSystem.asTargetOsType ?? _platformNotSupported();
final nativeLibraryName = _getLibName(realmBinaryName);

DynamicLibrary? _library;

String _getLibPathFlutter() {
  final root = _exeDirName;
  return switch (targetOsType) {
    TargetOsType.android => nativeLibraryName,
    TargetOsType.ios => p.join(root, 'Frameworks', 'realm_dart.framework', nativeLibraryName),
    TargetOsType.linux => p.join(root, 'lib', nativeLibraryName),
    TargetOsType.macos => p.join(p.dirname(root), 'Frameworks', nativeLibraryName),
    TargetOsType.windows => nativeLibraryName,
  };
}

String _getLibPathFlutterTest(Package realmPackage) {
  assert(realmPackage.name == 'realm');
  final root = p.join(realmPackage.root.toFilePath(), targetOsType.name);
  return switch (targetOsType) {
    TargetOsType.linux => p.join(root, 'binary', 'linux', nativeLibraryName),
    TargetOsType.macos => p.join(root, nativeLibraryName),
    TargetOsType.windows => p.join(root, 'binary', 'windows', nativeLibraryName),
    _ => _platformNotSupported(),
  };
}

String _getLibPathDart(Package realmDartPackage) {
  assert(realmDartPackage.name == 'realm_dart');
  final root = p.join(realmDartPackage.root.toFilePath(), 'binary', targetOsType.name);
  if (targetOsType.isDesktop) {
    return p.join(root, nativeLibraryName);
  }
  _platformNotSupported();
}

bool get isFlutterPlatform => realm.isFlutterPlatform;

String _getLibName(String stem) => switch (targetOsType) {
      TargetOsType.android => 'lib$stem.so',
      TargetOsType.ios => stem, // xcframeworks are a directory
      TargetOsType.linux => 'lib$stem.so',
      TargetOsType.macos => 'lib$stem.dylib',
      TargetOsType.windows => '$stem.dll',
    };

String? _getNearestProjectRoot(String dir) {
  while (dir != p.dirname(dir)) {
    if (File(p.join(dir, 'pubspec.yaml')).existsSync()) return dir;
    dir = p.dirname(dir);
  }
  return null;
}

File _getPackageConfigJson(Directory d) {
  final root = _getNearestProjectRoot(d.path);
  if (root != null) {
    final file = File(p.join(root, '.dart_tool', 'package_config.json'));
    if (file.existsSync()) return file;
  }
  throw StateError('Could not find package_config.json');
}

Never _platformNotSupported() => throw UnsupportedError('Platform ${Platform.operatingSystem} is not supported');

String get _exeDirName => p.dirname(Platform.resolvedExecutable);

DynamicLibrary _openRealmLib() {
  DynamicLibrary? tryOpen(String path) {
    try {
      return DynamicLibrary.open(path);
    } catch (_) {
      return null;
    }
  }

  Never throwError(Iterable<String> candidatePaths) {
    throw RealmError(
      [
        'Could not open $nativeLibraryName. Tried:',
        candidatePaths.map((p) => '- "$p"').join('\n'),
        isFlutterPlatform //
            ? 'Hint: Did you forget to add a dependency on the realm package?'
            : 'Hint: Did you forget to run `dart run realm_dart install`?'
      ].join('\n'),
    );
  }

  DynamicLibrary open(String path) => tryOpen(path) ?? throwError([path]);

  final isFlutterTest = Platform.environment.containsKey('FLUTTER_TEST');
  if (isFlutterPlatform && !isFlutterTest) {
    return open(_getLibPathFlutter());
  }

  // NOTE: This needs to be sync, so we cannot use findPackageConfig
  final packageConfigFile = _getPackageConfigJson(Directory.current);
  final packageConfig = PackageConfig.parseBytes(packageConfigFile.readAsBytesSync(), packageConfigFile.uri);

  if (isFlutterTest) {
    final realmPackage = packageConfig['realm']!;
    return open(_getLibPathFlutterTest(realmPackage));
  }

  final realmDartPackage = packageConfig['realm_dart']!;

  // else plain dart
  final candidatePaths = [
    nativeLibraryName, // just ask OS..
    p.join(_exeDirName, nativeLibraryName), // try finding it next to the executable
    _getLibPathDart(realmDartPackage), // try finding it in the package
  ];
  DynamicLibrary? lib;
  for (final path in candidatePaths) {
    lib = tryOpen(path);
    if (lib != null) return lib;
  }
  throwError(candidatePaths);
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
