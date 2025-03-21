// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_common/realm_common.dart' as common;

import 'native/decimal128.dart' if (dart.library.js_interop) 'web/decimal128.dart' as impl;

abstract interface class Decimal128 implements Comparable<Decimal128>, common.Decimal128 {
  /// The value 0.
  static Decimal128 get zero => impl.Decimal128.zero;

  /// The value 1.
  static Decimal128 get one => impl.Decimal128.one;

  /// The value 10.
  static Decimal128 get ten => impl.Decimal128.ten;

  /// The value NaN.
  static Decimal128 get nan => impl.Decimal128.nan;

  /// The value +Inf.
  static Decimal128 get infinity => impl.Decimal128.infinity;

  /// The value -Inf.
  static Decimal128 get negativeInfinity => impl.Decimal128.negativeInfinity;

  /// Parses a string into a [Decimal128]. Returns `null` if the string is not a valid [Decimal128].
  static Decimal128? tryParse(String source) => impl.Decimal128.tryParse(source);

  /// Parses a string into a [Decimal128]. Throws a [FormatException] if the string is not a valid [Decimal128].
  factory Decimal128.parse(String source) = impl.Decimal128.parse;

  /// Converts a `int` into a [Decimal128].
  factory Decimal128.fromInt(int value) = impl.Decimal128.fromInt;

  /// Converts a `double` into a [Decimal128].
  factory Decimal128.fromDouble(double value) = impl.Decimal128.fromDouble;

  /// Returns `true` if `this` is NaN.
  bool get isNaN;

  /// Adds `this` with `other` and returns a new [Decimal128].
  Decimal128 operator +(Decimal128 other);

  /// Subtracts `other` from `this` and returns a new [Decimal128].
  Decimal128 operator -(Decimal128 other);

  /// Multiplies `this` with `other` and returns a new [Decimal128].
  Decimal128 operator *(Decimal128 other);

  /// Divides `this` by `other` and returns a new [Decimal128].
  Decimal128 operator /(Decimal128 other);

  /// Negates `this` and returns a new [Decimal128].
  Decimal128 operator -();

  /// Returns the absolute value of `this`.
  Decimal128 abs();

  /// Returns `true` if `this` is less than `other`.
  bool operator <(Decimal128 other);

  /// Returns `true` if `this` is less than or equal to `other`.
  bool operator <=(Decimal128 other);

  /// Returns `true` if `this` is greater than `other`.
  bool operator >(Decimal128 other);

  /// Returns `true` if `this` is greater than or equal to `other`.
  bool operator >=(Decimal128 other);

  /// Converts `this` to an `int`. Possibly loosing precision.
  int toInt();

  /// Compares `this` to `other`.
  @override
  int compareTo(Decimal128 other);
}
