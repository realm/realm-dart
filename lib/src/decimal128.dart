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

import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'native/realm_bindings.dart';
import 'native/realm_core.dart';

class Decimal128 extends Comparable<Decimal128> {
  static final zero = Decimal128.fromInt(0);
  static final one = Decimal128.fromInt(1);
  static final ten = Decimal128.fromInt(10);

  static final nan = Decimal128.parse('+NaN');
  static final infinity = one / zero; // +Inf
  static final negativeInfinity = -infinity;

  final realm_decimal128_t _value;

  Decimal128._(this._value);

  static final _validInput = RegExp(r'^[+-]?((\d+\.?\d*|\d*\.?\d+)([eE][+-]?\d+)?|NaN|Inf)$');
  static Decimal128? tryParse(String source) {
    if (!_validInput.hasMatch(source)) return null;
    return using((arena) {
      final result = lib.realm_dart_decimal128_from_string(source.toNativeUtf8(allocator: arena).cast());
      return Decimal128._(result);
    });
  }

  factory Decimal128.parse(String source) {
    return tryParse(source) ?? (throw FormatException('Invalid Decimal128', source));
  }

  factory Decimal128.fromInt(int value) {
    return Decimal128._(lib.realm_dart_decimal128_from_int64(value));
  }

  factory Decimal128.fromDouble(double value) {
    return Decimal128.parse(value.toString()); // TODO(kn): Find a way to optimize this
  }

  Decimal128 operator +(Decimal128 other) {
    return Decimal128._(lib.realm_dart_decimal128_add(_value, other._value));
  }

  Decimal128 operator -(Decimal128 other) {
    return Decimal128._(lib.realm_dart_decimal128_subtract(_value, other._value));
  }

  Decimal128 operator *(Decimal128 other) {
    return Decimal128._(lib.realm_dart_decimal128_multiply(_value, other._value));
  }

  Decimal128 operator /(Decimal128 other) {
    return Decimal128._(lib.realm_dart_decimal128_divide(_value, other._value));
  }

  Decimal128 operator -() => zero - this;

  Decimal128 abs() => this < zero ? -this : this;

  @override
  // ignore: hash_and_equals
  operator ==(Object other) {
    // WARNING: Don't use identical to ensure nan != nan
    // if (identical(this, other)) return true;
    if (other is Decimal128) {
      return lib.realm_dart_decimal128_equal(_value, other._value);
    }
    return false;
  }

  bool operator <(Decimal128 other) {
    return lib.realm_dart_decimal128_less_than(_value, other._value);
  }

  bool operator <=(Decimal128 other) => compareTo(other) <= 0;

  bool operator >(Decimal128 other) {
    return lib.realm_dart_decimal128_greater_than(_value, other._value);
  }

  bool operator >=(Decimal128 other) => compareTo(other) >= 0;

  int toInt() => lib.realm_dart_decimal128_to_int64(_value);

  @override
  String toString() {
    return using((arena) {
      final realmString = lib.realm_dart_decimal128_to_string(_value);
      return ascii.decode(realmString.data.cast<Uint8>().asTypedList(realmString.size));
    });
  }

  @override
  int compareTo(Decimal128 other) {
    if (this < other) {
      return -1;
    } else if (this == other) {
      return 0;
    } else {
      return 1;
    }
  }
}
