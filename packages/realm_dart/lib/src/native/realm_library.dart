// This variable allows access to realm native library even before RealmCore is created. For Decimal128 for example
import 'package:ffi/ffi.dart';
import 'package:realm_common/realm_common.dart';
import 'package:realm_dart/src/init.dart';
import 'package:realm_dart/src/native/realm_bindings.dart';

const bugInTheSdkMessage = "This is likely a bug in the Realm SDK - please file an issue at https://github.com/realm/realm-dart/issues";

// stamped into the library by the build system (see prepare-release.yml)
const libraryVersion = '2.3.0';

final realmLib = () {
  final result = RealmLibrary(initRealm());
  final nativeLibraryVersion = result.realm_dart_library_version().cast<Utf8>().toDartString();
  if (libraryVersion != nativeLibraryVersion) {
    final additionMessage =
        isFlutterPlatform ? bugInTheSdkMessage : "Did you forget to run `dart run realm_dart install` after upgrading the realm_dart package?";
    throw RealmError('Realm SDK package version does not match the native library version ($libraryVersion != $nativeLibraryVersion). $additionMessage');
  }
  return result;
}();
