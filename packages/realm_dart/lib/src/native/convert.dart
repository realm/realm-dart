// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

part of 'realm_core.dart';

extension HandleBaseEx<T extends HandleBase> on T {
  T? get nullPtrAsNull => _pointer == nullptr ? null : this;
  U? convert<U>(U Function(T) convertor) => nullPtrAsNull.convert(convertor);
}

extension NullableObjectEx<T> on T? {
  U? convert<U>(U Function(T) convertor) {
    final self = this;
    if (self == null) return null;
    return convertor(self);
  }
}
