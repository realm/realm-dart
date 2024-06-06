// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';

import 'package:realm_dart/src/handles/native/convert.dart';
import 'package:realm_dart/src/handles/web/web_not_supported.dart';

import '../decimal128.dart' as intf;

/// This is not a compliant IEEE 754 Decimal128 implementation, as it is
/// just based on the `decimal` package, but the precision is potentially better
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
  factory Decimal128.fromDouble(double value) {
    if (value.isNaN) return nan;
    if (value.isInfinite) return value.isNegative ? negativeInfinity : infinity;

    // Extract the sign, exponent and mantissa from the double
    final bytes = ByteData(8);
    bytes.setFloat64(0, value);
    final bits = bytes.getUint64(0);

    final sign = bits >> 63; // 1 bit
    final exponent = (bits & 0x7ff0000000000000) >> 12; // 11 bits
    final mantissa = bits & 0x000fffffffffffff; // 52 bits

    const bias = 1 << 12 - 1; // 1023 bit bias for 64bit double

    final minusOne = -BigInt.one;
    final denominator = BigInt.one << 52;

    final s = minusOne.pow(sign); // -1^sign
    final e = BigInt.one << (exponent - bias); // 2^(exponent - bias)
    final m = Rational(BigInt.from(mantissa) + denominator, denominator); // mantissa + 1.0

    return Decimal128._(((s * e).toRational() * m).toDecimal()); // s * e * m
  }

  final Decimal _value;
  Decimal128._(Decimal value) : _value = value.truncate(scale: 6144);

  @override
  Decimal128 operator *(covariant Decimal128 other) => Decimal128._(_value * other._value);

  @override
  Decimal128 operator +(covariant Decimal128 other) => Decimal128._(_value + other._value);

  @override
  Decimal128 operator -() => Decimal128._(-_value);

  @override
  Decimal128 operator -(covariant Decimal128 other) => Decimal128._(_value - other._value);

  // Note IEEE 754 Decimal128 defines division with zero as infinity, similar to double
  @override
  Decimal128 operator /(covariant Decimal128 other) => Decimal128._((_value / other._value).toDecimal(scaleOnInfinitePrecision: 6144));

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
  int compareTo(covariant Decimal128 other) {
    final sign = _value.compareTo(other._value);
    if (sign < 0) return -1;
    if (sign > 0) return 1;
    return 0;
  }

  @override
  bool get isNaN => this == nan;

  @override
  int toInt() => _value.toBigInt().toInt();

  @override
  String toString() => _value.toStringAsExponential(27);

  @override
  operator ==(Object other) => other is Decimal128 && _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
