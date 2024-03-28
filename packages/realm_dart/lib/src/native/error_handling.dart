// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

part of 'realm_core.dart';

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

extension on realm_error {
  LastError toDart() {
    final message = this.message.cast<Utf8>().toRealmDartString();
    return LastError(error, message, user_code_error.toUserCodeError());
  }
}
