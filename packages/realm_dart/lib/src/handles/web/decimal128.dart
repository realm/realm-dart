// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:decimal/decimal.dart';
import 'package:realm_dart/src/handles/native/convert.dart';
import 'package:realm_dart/src/handles/web/web_not_supported.dart';

import '../decimal128.dart' as intf;

class Decimal128 implements intf.Decimal128 {
  static final zero = Decimal128.fromInt(0);

  /// The value 1.
  static final one = Decimal128.fromInt(1);

  /// The value 10.
  static final ten = Decimal128.fromInt(10);

  /// The value NaN.
  static Decimal128 get nan => webNotSupported();

  /// The value +Inf.
  static final infinity = one / zero; // +Inf

  /// The value -Inf.
  static final negativeInfinity = -infinity;

  /// Parses a string into a [Decimal128]. Returns `null` if the string is not a valid [Decimal128].
  static Decimal128? tryParse(String source) => Decimal.tryParse(source).convert(Decimal128._);

  /// Parses a string into a [Decimal128]. Throws a [FormatException] if the string is not a valid [Decimal128].
  factory Decimal128.parse(String source) => Decimal128._(Decimal.parse(source));

  /// Converts a `int` into a [Decimal128].
  factory Decimal128.fromInt(int value) => Decimal128._(Decimal.fromInt(value));

  /// Converts a `double` into a [Decimal128].
  factory Decimal128.fromDouble(double value) => webNotSupported();

  final Decimal _value;
  Decimal128._(this._value); // TODO: truncate to 128 bits and handle NaN correctly

  @override
  Decimal128 operator *(covariant Decimal128 other) => Decimal128._(_value * other._value);

  @override
  Decimal128 operator +(covariant Decimal128 other) => Decimal128._(_value + other._value);

  @override
  Decimal128 operator -() => Decimal128._(-_value);

  @override
  Decimal128 operator -(covariant Decimal128 other) => Decimal128._(_value - other._value);

  @override
  Decimal128 operator /(covariant Decimal128 other) => Decimal128._((_value / other._value).toDecimal());

  @override
  bool operator <(covariant Decimal128 other) => _value < other._value;

  @override
  bool operator <=(covariant Decimal128 other) => _value <= other._value;

  @override
  bool operator >(covariant Decimal128 other) => _value > other._value;

  @override
  bool operator >=(covariant Decimal128 other) => _value >= other._value;

  @override
  Decimal128 abs() => Decimal128._(_value.abs());

  @override
  int compareTo(covariant Decimal128 other) => _value.compareTo(other._value);

  @override
  // TODO: implement isNaN
  bool get isNaN => webNotSupported();

  @override
  int toInt() => _value.toBigInt().toInt();
}
