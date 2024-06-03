// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../decimal128.dart' as intf;

class Decimal128 implements intf.Decimal128 {
  static final zero = Decimal128.fromInt(0);

  /// The value 1.
  static final one = Decimal128.fromInt(1);

  /// The value 10.
  static final ten = Decimal128.fromInt(10);

  /// The value NaN.
  static get nan => throw UnimplementedError('web not supported');

  /// The value +Inf.
  static final infinity = one / zero; // +Inf

  /// The value -Inf.
  static final negativeInfinity = -infinity;

  /// Parses a string into a [Decimal128]. Returns `null` if the string is not a valid [Decimal128].
  static Decimal128? tryParse(String source) => throw UnimplementedError('web not supported');

  /// Parses a string into a [Decimal128]. Throws a [FormatException] if the string is not a valid [Decimal128].
  factory Decimal128.parse(String source) => throw UnimplementedError('web not supported');

  /// Converts a `int` into a [Decimal128].
  factory Decimal128.fromInt(int value) => throw UnimplementedError('web not supported');

  /// Converts a `double` into a [Decimal128].
  factory Decimal128.fromDouble(double value) => throw UnimplementedError('web not supported');

  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}
