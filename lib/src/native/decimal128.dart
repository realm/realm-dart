////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

part of 'realm_core.dart';

/// A 128-bit decimal floating point number.
class Decimal128 extends Comparable<Decimal128> implements common.Decimal128 {
  /// The value 0.
  static final zero = Decimal128.fromInt(0);

  /// The value 1.
  static final one = Decimal128.fromInt(1);

  /// The value 10.
  static final ten = Decimal128.fromInt(10);

  /// The value NaN.
  static final nan = Decimal128._(_realmLib.realm_dart_decimal128_nan());

  /// The value +Inf.
  static final infinity = one / zero; // +Inf

  /// The value -Inf.
  static final negativeInfinity = -infinity;

  final realm_decimal128_t _value;

  Decimal128._(this._value);

  static final _validInput = RegExp(r'^[+-]?((\d+\.?\d*|\d*\.?\d+)([eE][+-]?\d+)?|NaN|Inf(inity)?)$');

  /// Parses a string into a [Decimal128]. Returns `null` if the string is not a valid [Decimal128].
  static Decimal128? tryParse(String source) {
    if (!_validInput.hasMatch(source)) return null;
    return using((arena) {
      final result = _realmLib.realm_dart_decimal128_from_string(source.toCharPtr(arena));
      return Decimal128._(result);
    });
  }

  /// Parses a string into a [Decimal128]. Throws a [FormatException] if the string is not a valid [Decimal128].
  factory Decimal128.parse(String source) {
    return tryParse(source) ?? (throw FormatException('Invalid Decimal128', source));
  }

  /// Converts a `int` into a [Decimal128].
  factory Decimal128.fromInt(int value) {
    return Decimal128._(_realmLib.realm_dart_decimal128_from_int64(value));
  }

  /// Converts a `double` into a [Decimal128].
  factory Decimal128.fromDouble(double value) {
    return Decimal128.parse(value.toString()); // TODO(kn): Find a way to optimize this
  }

  /// Returns `true` if `this` is NaN.
  bool get isNaN => _realmLib.realm_dart_decimal128_is_nan(_value);

  /// Adds `this` with `other` and returns a new [Decimal128].
  Decimal128 operator +(Decimal128 other) {
    return Decimal128._(_realmLib.realm_dart_decimal128_add(_value, other._value));
  }

  /// Subtracts `other` from `this` and returns a new [Decimal128].
  Decimal128 operator -(Decimal128 other) {
    return Decimal128._(_realmLib.realm_dart_decimal128_subtract(_value, other._value));
  }

  /// Multiplies `this` with `other` and returns a new [Decimal128].
  Decimal128 operator *(Decimal128 other) {
    return Decimal128._(_realmLib.realm_dart_decimal128_multiply(_value, other._value));
  }

  /// Divides `this` by `other` and returns a new [Decimal128].
  Decimal128 operator /(Decimal128 other) {
    return Decimal128._(_realmLib.realm_dart_decimal128_divide(_value, other._value));
  }

  /// Negates `this` and returns a new [Decimal128].
  Decimal128 operator -() => Decimal128._(_realmLib.realm_dart_decimal128_negate(_value));

  /// Returns the absolute value of `this`.
  Decimal128 abs() => this < zero ? -this : this;

  /// Returns `true` if `this` and `other` are equal.
  @override
  // ignore: hash_and_equals
  operator ==(Object other) {
    // WARNING: Don't use identical to ensure nan != nan,
    // if (identical(this, other)) return true;
    if (other is Decimal128) {
      return _realmLib.realm_dart_decimal128_equal(_value, other._value);
    }
    return false;
  }

  /// Returns `true` if `this` is less than `other`.
  bool operator <(Decimal128 other) {
    return _realmLib.realm_dart_decimal128_less_than(_value, other._value);
  }

  /// Returns `true` if `this` is less than or equal to `other`.
  bool operator <=(Decimal128 other) => compareTo(other) <= 0;

  /// Returns `true` if `this` is greater than `other`.
  bool operator >(Decimal128 other) {
    return _realmLib.realm_dart_decimal128_greater_than(_value, other._value);
  }

  /// Returns `true` if `this` is greater than or equal to `other`.
  bool operator >=(Decimal128 other) => compareTo(other) >= 0;

  /// Converts `this` to an `int`. Possibly loosing precision.
  int toInt() => _realmLib.realm_dart_decimal128_to_int64(_value);

  /// String representation of `this`.
  @override
  String toString() {
    return using((arena) {
      final realmString = _realmLib.realm_dart_decimal128_to_string(_value);
      return ascii.decode(realmString.data.cast<Uint8>().asTypedList(realmString.size));
    });
  }

  /// Compares `this` to `other`.
  @override
  int compareTo(Decimal128 other) => _realmLib.realm_dart_decimal128_compare_to(_value, other._value);
}

extension Decimal128Internal on Decimal128 {
  realm_decimal128_t get value => _value;

  static Decimal128 fromNative(realm_decimal128_t value) => Decimal128._(value);
}
