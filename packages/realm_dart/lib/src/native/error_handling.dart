// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../realm_object.dart';
import 'realm_bindings.dart';
import 'realm_core.dart';
import 'realm_library.dart';

void invokeGetBool(bool Function() callback, [String? errorMessage]) {
  bool success = callback();
  if (!success) {
    throwLastError(errorMessage);
  }
}

Pointer<T> invokeGetPointer<T extends NativeType>(Pointer<T> Function() callback, [String? errorMessage]) {
  final result = callback();
  if (result == nullptr) {
    throwLastError(errorMessage);
  }
  return result;
}

class LastError {
  final int code;
  final String? message;
  final Object? userError;

  LastError(this.code, [this.message, this.userError]);

  @override
  String toString() => "${message ?? 'No message'}. Error code: $code.";
}

LastError? getLastError(Allocator allocator) {
  final error = allocator<realm_error_t>();
  final success = realmLib.realm_get_last_error(error);
  return success ? error.ref.toDart() : null;
}

Never throwLastError([String? errorMessage]) {
  using((Arena arena) {
    final lastError = getLastError(arena);
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
    return LastError(error, message, user_code_error.toUserCodeError());
  }
}
