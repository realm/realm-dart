// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_common/realm_common.dart';

import 'init.dart';
import 'ffi.dart';
import 'realm_bindings.dart';

const bugInTheSdkMessage = "This is likely a bug in the Realm SDK - please file an issue at https://github.com/realm/realm-dart/issues";

// stamped into the library by the build system (see prepare-release.yml)
const libraryVersion = '20.1.1';

final realmLib = () {
  final result = RealmLibrary(initRealm());
  final nativeLibraryVersion = result.realm_dart_library_version().cast<Utf8>().toDartString();
  if (libraryVersion != nativeLibraryVersion) {
    final additionMessage =
        isFlutterPlatform ? bugInTheSdkMessage : "Did you forget to run `dart run realm_dart install` after upgrading the realm_dart package?";
    throw RealmError('Realm SDK package version does not match the native library version ($libraryVersion != $nativeLibraryVersion). $additionMessage');
  }
  result.realm_dart_init_debug_logger();
  return result;
}();
