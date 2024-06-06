// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'handle_base.dart';

extension PointerEx<T extends NativeType> on Pointer<T> {
  Pointer<T>? get nullPtrAsNull => this == nullptr ? null : this;
  U? convert<U>(U Function(Pointer<T>) convertor) => nullPtrAsNull.convert(convertor);
}

extension HandleBaseEx<T extends HandleBase> on T {
  T? get nullPtrAsNull => pointer == nullptr ? null : this;
  U? convert<U>(U Function(T) convertor) => nullPtrAsNull.convert(convertor);
}

extension NullableObjectEx<T> on T? {
  U? convert<U>(U Function(T) convertor) {
    final self = this;
    if (self == null) return null;
    return convertor(self);
  }
}
