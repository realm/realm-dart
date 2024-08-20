// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';
import 'dart:io';

import 'package:ejson/ejson.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:type_plus/type_plus.dart';

import '../../cli/common/target_os_type.dart';
import '../../realm_class.dart';

import '../../../realm.dart' show isFlutterPlatform;
export '../../../realm.dart' show isFlutterPlatform;

import 'decimal128.dart' as impl;

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

File? _getPackageConfigJson(Directory d) {
  final root = _getNearestProjectRoot(d.path);
  if (root != null) {
    final file = File(p.join(root, '.dart_tool', 'package_config.json'));
    if (file.existsSync()) return file;
  }
  return null;
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
    return open(_getLibPathFlutter()); // flutter app
  }

  // NOTE: This needs to be sync, so we cannot use findPackageConfig
  final packageConfigFile = _getPackageConfigJson(Directory.current);
  if (packageConfigFile != null) {
    // inside a project
    final packageConfig = PackageConfig.parseBytes(packageConfigFile.readAsBytesSync(), packageConfigFile.uri);
    if (isFlutterTest) {
      // running flutter test (not flutter test integration_test or flutter drive)
      final realmPackage = packageConfig['realm']!;
      return open(_getLibPathFlutterTest(realmPackage));
    }
    // plain dart
    final realmDartPackage = packageConfig['realm_dart']!;
    return open(_getLibPathDart(realmDartPackage));
  }

  // plain dart (compiled or interpreted)
  final candidatePaths = [
    nativeLibraryName, // just ask OS..
    p.join(_exeDirName, nativeLibraryName), // try finding it next to the executable
  ];
  DynamicLibrary? lib;
  for (final path in candidatePaths) {
    lib = tryOpen(path);
    if (lib != null) return lib;
  }
  throwError(candidatePaths);
}

EJsonValue encodeDecimal128(Decimal128 value) => {'\$numberDecimal': value.toString()};

impl.Decimal128 decodeDecimal128(EJsonValue ejson) => switch (ejson) {
      {'\$numberDecimal': String x} => impl.Decimal128.parse(x),
      _ => raiseInvalidEJson(ejson),
    };

EJsonValue encodeRealmValue(RealmValue value) {
  final v = value.value;
  if (v is RealmObject) {
    final p = RealmObjectBase.get(v, v.objectSchema.primaryKey!.name);
    return DBRef(v.objectSchema.name, p).toEJson();
  }
  return toEJson(v);
}

RealmValue decodeRealmValue(EJsonValue ejson) {
  final decoded = fromEJson<dynamic>(ejson);
  if (decoded is DBRef) {
    final t = TypePlus.fromId(decoded.collection);
    final o = RealmObjectBase.createObject(t, null);
    o.dynamic.set(o.objectSchema.primaryKey!.name, decoded.id);
    return RealmValue.realmObject(o.cast());
  }
  return RealmValue.from(decoded);
}

/// @nodoc
// Initializes Realm library
DynamicLibrary initRealm() {
  if (_library != null) {
    return _library!;
  }

  register<impl.Decimal128>(encodeDecimal128, decodeDecimal128, superTypes: [Decimal128]);
  register<Decimal128>(encodeDecimal128, decodeDecimal128);
  register(encodeRealmValue, decodeRealmValue);

  final realmLibrary = _openRealmLib();

  final initializeApi = realmLibrary.lookupFunction<IntPtr Function(Pointer<Void>), int Function(Pointer<Void>)>('realm_dart_initializeDartApiDL');
  var initResult = initializeApi(NativeApi.initializeApiDLData);
  if (initResult != 0) {
    throw AssertionError('Realm initialization failed. Error: could not initialize Dart APIs');
  }

  return _library = realmLibrary;
}

extension<T> on T {
  U cast<U>() => this as U;
}
