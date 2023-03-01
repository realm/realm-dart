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

import 'dart:math';

import 'package:meta/meta.dart';
import 'package:realm_dart/src/decimal128.dart';
import 'package:test/test.dart';
import 'package:realm_dart/src/native/realm_core.dart';

const int defaultTimes = 100000;

@isTest
void repeat(dynamic Function() body, [int times = defaultTimes]) {
  for (var i = 0; i < times; ++i) {
    body();
  }
}

void repeatTest(String description, dynamic Function(Decimal128 x, int xInt, Decimal128 y, int yInt) body, [int times = defaultTimes]) {
  final r = Random(42); // use a fixed seed to make tests deterministic
  test('$description ($times variations)', () {
    repeat(
      () {
        var xInt = r.nextInt(1 << 31); // 2^31 ensures multiplication doesn't overflow
        final x = Decimal128.fromInt(xInt);
        var yInt = r.nextInt(1 << 31);
        final y = Decimal128.fromInt(yInt);

        body(x, xInt, y, yInt);
      },
      times,
    );
  });
}

Future<void> main([List<String>? args]) async {
  realmCore.nativeLibraryVersion; // ensure initialization

  test('Decimal128.nan', () {
    expect(Decimal128.nan, isNot(Decimal128.nan));
    // NaN != NaN so compare as strings
    expect(Decimal128.tryParse(Decimal128.nan.toString()).toString(), Decimal128.nan.toString());
  });

  test('Decimal128.infinity', () {
    // Test that we mimic the behavior of Dart's double wrt. infinity
    expect(double.tryParse(double.infinity.toString()), double.infinity);
    expect(Decimal128.tryParse(Decimal128.infinity.toString()), Decimal128.infinity);

    expect(double.infinity, 1.0 / 0.0);
    expect(Decimal128.infinity, Decimal128.one / Decimal128.zero);

    expect(double.infinity, double.parse('Infinity'));
    expect(Decimal128.infinity, Decimal128.parse('Infinity'));
    expect(Decimal128.infinity, Decimal128.parse('Inf')); // special for Decimal128

    expect(double.infinity, double.parse('+Infinity'));
    expect(Decimal128.infinity, Decimal128.parse('+Infinity'));
    expect(Decimal128.infinity, Decimal128.parse('+Inf')); // special for Decimal128

    expect(-double.infinity, double.negativeInfinity);
    expect(-Decimal128.infinity, Decimal128.negativeInfinity);

    expect(-double.infinity, double.parse('-Infinity'));
    expect(-Decimal128.infinity, Decimal128.parse('-Infinity'));
    expect(-Decimal128.infinity, Decimal128.parse('-Inf')); // special for Decimal128
  });

  test('Decimal128.parse throws on invalid input', () {
    expect(() => Decimal128.parse(''), throwsFormatException);
    expect(() => Decimal128.parse(' 1'), throwsFormatException);
    expect(() => Decimal128.parse('a'), throwsFormatException);
    expect(() => Decimal128.parse('1a'), throwsFormatException);
    expect(() => Decimal128.parse('1.2.3'), throwsFormatException);
  });

  test('Decimal128.tryParse', () {
    final inputs = <String, String?>{
      '-5352089294466601279674461764E+87': '-5352089294466601279674461764E+87',
      '-91.945E0542373228376880240736944': '-Inf',
      '.60438002651113181e-0': '+60438002651113181E-17',
      '100.0e-999': '+1000E-1000',
      '100.0e-9999': '+0E-6176',
      '855084089520e34934827269223590848': '+Inf',
      'Inf': '+Inf',
      'Infinity': '+Inf',
      '+Infinity': '+Inf',
      '-Infinity': '-Inf',
      'NaN': '+NaN',
      '': null,
      ' 1': null,
      'a': null,
      '1a': null,
      '1.2.3': null,
      '1,0': null,
      '1.0': '+10E-1',
    };
    for (var entry in inputs.entries) {
      final input = entry.key;
      final result = entry.value;
      expect(Decimal128.tryParse(input)?.toString(), result);
    }
  });

  test('Decimal128 divide by zero', () {
    // Test that we mimic the behavior of Dart's double when dividing by zero
    expect(1.0 / 0.0, double.infinity);
    expect(Decimal128.one / Decimal128.zero, Decimal128.infinity);

    expect(-1.0 / 0.0, -double.infinity);
    expect(-Decimal128.one / Decimal128.zero, -Decimal128.infinity);

    expect(-1.0 / 0.0, double.negativeInfinity);
    expect(-Decimal128.one / Decimal128.zero, Decimal128.negativeInfinity);
  });

  repeatTest('Decimal128.compareTo + <, <=, ==, !=, >=, >', (x, xInt, y, yInt) {
    expect(x.compareTo(y), xInt.compareTo(yInt));
    expect(x == y, xInt == yInt);
    expect(x < y, xInt < yInt);
    expect(x <= y, xInt <= yInt);
    expect(x > y, xInt > yInt);
    expect(x >= y, xInt >= yInt);

    expect(x.compareTo(x), 0);
    expect(x == x, isTrue);
    expect(x < x, isFalse);
    expect(x <= x, isTrue);
    expect(x > x, isFalse);
    expect(x >= x, isTrue);
  });

  repeatTest('Decimal128.toInt/fromInt roundtrip', (x, xInt, y, yInt) {
    expect(Decimal128.fromInt(x.toInt()), x);
  });

  repeatTest('Decimal128.fromInt/toInt roundtrip', (x, xInt, y, yInt) {
    expect(x.toInt(), xInt);
  });

  repeatTest('Decimal128.toString/parse roundtrip', (x, xInt, y, yInt) {
    expect(Decimal128.parse(x.toString()), x);
  });

  repeatTest('Decimal128 add', (x, xInt, y, yInt) {
    expect(x + y, Decimal128.fromInt(xInt + yInt));
  });

  repeatTest('Decimal128 subtract', (x, xInt, y, yInt) {
    expect(x - y, Decimal128.fromInt(xInt - yInt));
  });

  repeatTest('Decimal128 multiply', (x, xInt, y, yInt) {
    expect(x * y, Decimal128.fromInt(xInt * yInt));
  });

  repeatTest('Decimal128 multiply & divide', (x, xInt, y, yInt) {
    expect((x * y) / x, y);
    expect((x * y) / y, x);
  });

  final epsilon = Decimal128.one / Decimal128.fromInt(1 << 62);
  repeatTest('Decimal128 divide', (x, xInt, y, yInt) {
    expect((x / y - (Decimal128.one / (y / x))).abs(), lessThan(epsilon));
  });

  repeatTest('Decimal128 negate', (x, xInt, y, yInt) {
    expect((-x).toInt(), -xInt);
    expect(-(-x), x);
  });

  repeatTest('Decimal128.abs', (x, xInt, y, yInt) {
    expect(x.abs(), (-x).abs());
  });
}
