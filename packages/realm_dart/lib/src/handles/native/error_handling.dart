// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'ffi.dart';

import '../../realm_object.dart';
import 'from_native.dart';
import 'realm_bindings.dart';
import 'realm_library.dart';

extension PointerEx<T extends NativeType> on Pointer<T> {
  Pointer<T> raiseLastErrorIfNull() {
    if (this == nullptr) {
      _raiseLastError();
    }
    return this;
  }
}

extension BoolEx on bool {
  void raiseLastErrorIfFalse() {
    if (!this) {
      _raiseLastError();
    }
  }
}

class LastError {
  final realm_errno code;
  final String? message;
  final Object? userError;

  LastError(this.code, [this.message, this.userError]);

  @override
  String toString() => "${message ?? 'No message'}. Error code: $code.";
}

LastError? _getLastError(Allocator allocator) {
  final error = allocator<realm_error_t>();
  final success = realmLib.realm_get_last_error(error);
  return success ? error.ref.toDart() : null;
}

Never _raiseLastError([String? errorMessage]) {
  using((arena) {
    final lastError = _getLastError(arena);
    if (lastError?.userError != null) {
      throw UserCallbackException(lastError!.userError!);
    }

    final message = '${errorMessage != null ? "$errorMessage. " : ""}${lastError ?? ""}';
    switch (lastError?.code) {
      case realm_errno.RLM_ERR_SCHEMA_MISMATCH:
        throw MigrationRequiredException(message);
      default:
        throw RealmException(message);
    }
  });
}

extension RealmErrorEx on realm_error {
  LastError toDart() {
    final message = this.message.cast<Utf8>().toRealmDartString();
    return LastError(realm_errno.fromValue(error), message, user_code_error.toUserCodeError());
  }
}
