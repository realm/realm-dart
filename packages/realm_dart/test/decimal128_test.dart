// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:math';

import 'package:meta/meta.dart';
import 'package:test/expect.dart' hide throws;

import 'package:realm_dart/src/native/realm_core.dart';
import 'test.dart';

const int defaultTimes = 100;

void repeat(dynamic Function() body, [int times = defaultTimes]) {
  for (var i = 0; i < times; ++i) {
    body();
  }
}

@isTest
void repeatTest(String description, dynamic Function(Decimal128 x, int xInt, Decimal128 y, int yInt) body, [int times = defaultTimes]) {
  final random = Random(42); // use a fixed seed to make tests deterministic
  test(description, () {
    repeat(
      () {
        // 2^31 ensures x * y doesn't overflow
        var xInt = random.nextInt(1 << 31);
        final x = Decimal128.fromInt(xInt);
        var yInt = random.nextInt(1 << 31);
        final y = Decimal128.fromInt(yInt);

        body(x, xInt, y, yInt);
      },
      times,
    );
  });
}

void main() {
  setupTests();

  test('Decimal128.nan', () {
    // Test that we mimic the behavior of Dart's double wrt. NaN and
    // <, <=, >, >=. Unlike compareTo (which define a total order) these
    // operators return false for NaN.
    expect(0.0, isNot(double.nan));
    expect(0.0, isNot(lessThan(double.nan)));
    expect(0.0, isNot(lessThanOrEqualTo(double.nan)));
    expect(0.0, isNot(greaterThan(double.nan)));
    expect(0.0, isNot(greaterThanOrEqualTo(double.nan)));

    expect(double.nan, isNot(0.0));
    expect(double.nan, isNot(lessThan(0.0)));
    expect(double.nan, isNot(lessThanOrEqualTo(0.0)));
    expect(double.nan, isNot(greaterThan(0.0)));
    expect(double.nan, isNot(greaterThanOrEqualTo(0.0)));

    expect(double.nan, isNot(double.nan));
    expect(double.nan, isNot(lessThan(double.nan)));
    expect(double.nan, isNot(lessThanOrEqualTo(double.nan)));
    expect(double.nan, isNot(greaterThan(double.nan)));
    expect(double.nan, isNot(greaterThanOrEqualTo(double.nan)));

    expect(double.nan.isNaN, isTrue);
    expect((0.0).isNaN, isFalse);
    expect((0.0 / 0.0).isNaN, isTrue);
    expect((1.0).isNaN, isFalse);
    expect((10.0).isNaN, isFalse);
    expect(double.infinity.isNaN, isFalse);

    // NaN != NaN so compare as strings
    expect(Decimal128.tryParse(Decimal128.nan.toString()).toString(), Decimal128.nan.toString());

    expect(Decimal128.zero, isNot(Decimal128.nan));
    expect(Decimal128.zero, isNot(lessThan(Decimal128.nan)));
    expect(Decimal128.zero, isNot(lessThanOrEqualTo(Decimal128.nan)));
    expect(Decimal128.zero, isNot(greaterThan(Decimal128.nan)));
    expect(Decimal128.zero, isNot(greaterThanOrEqualTo(Decimal128.nan)));

    expect(Decimal128.nan, isNot(Decimal128.zero));
    expect(Decimal128.nan, isNot(lessThan(Decimal128.zero)));
    expect(Decimal128.nan, isNot(lessThanOrEqualTo(Decimal128.zero)));
    expect(Decimal128.nan, isNot(greaterThan(Decimal128.zero)));
    expect(Decimal128.nan, isNot(greaterThanOrEqualTo(Decimal128.zero)));

    expect(Decimal128.nan, isNot(Decimal128.nan));
    expect(Decimal128.nan, isNot(lessThan(Decimal128.nan)));
    expect(Decimal128.nan, isNot(lessThanOrEqualTo(Decimal128.nan)));
    expect(Decimal128.nan, isNot(greaterThan(Decimal128.nan)));
    expect(Decimal128.nan, isNot(greaterThanOrEqualTo(Decimal128.nan)));

    expect(Decimal128.nan.isNaN, isTrue);
    expect(Decimal128.zero.isNaN, isFalse);
    expect((Decimal128.zero / Decimal128.zero).isNaN, isTrue);
    expect(Decimal128.one.isNaN, isFalse);
    expect(Decimal128.ten.isNaN, isFalse);
    expect(Decimal128.infinity.isNaN, isFalse);

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
    final inputs = [
      '',
      ' 1',
      'a',
      '1a',
      '1.2.3',
      '1,0',
    ];
    for (var input in inputs) {
      expect(() => Decimal128.parse(input), throwsFormatException);
    }
  });

  test('Decimal128.tryParse', () {
    final inputs = <String, String?>{
      // input -> canonical output
      '-5352089294466601279674461764E+87': '-5352089294466601279674461764E+87',
      '-91.945E0542373228376880240736944': '-Inf',
      '.60438002651113181e-0': '+60438002651113181E-17',
      '100.0e-999': '+1000E-1000',
      '100.0e-9999': '+0E-6176',
      '855084089520e34934827269223590848': '+Inf',
      'NaN': '+NaN',
      'Inf': '+Inf',
      'Infinity': '+Inf',
      '+Infinity': '+Inf',
      '-Infinity': '-Inf',
      'Infi': null,
      '-Infi': null,
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
      final output = entry.value;
      expect(Decimal128.tryParse(input)?.toString(), output);
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

  test('Decimal128 IEEE 754-2019 corner cases', () {
    expect(double.infinity + 1, double.infinity);
    expect(Decimal128.infinity + Decimal128.one, Decimal128.infinity);

    expect(double.infinity * -1, double.negativeInfinity);
    expect(Decimal128.infinity * -Decimal128.one, Decimal128.negativeInfinity);

    expect((double.infinity * 0).isNaN, isTrue);
    expect((Decimal128.infinity * Decimal128.zero).isNaN, isTrue);
  });

  test('Decimal128.compareTo is a total ordering', () {
    // Test that we mimic the behavior of Dart's double wrt. compareTo in relation
    // to IEEE754-2019, ie. +/- NaN, +/- infinity and +/- zero and define a total
    // ordering.
    expect((-0.0).compareTo(0.0), -1);
    expect((0.0).compareTo(-0.0), 1);
    expect((0.0).compareTo(0.0), 0);
    expect((-0.0).compareTo(-0.0), 0);

    expect(double.negativeInfinity.compareTo(double.infinity), -1);
    expect(double.infinity.compareTo(double.negativeInfinity), 1);
    expect(double.infinity.compareTo(double.infinity), 0);
    expect(double.negativeInfinity.compareTo(double.negativeInfinity), 0);

    expect((1.0).compareTo(double.nan), -1);
    expect(double.nan.compareTo(double.nan), 0);
    expect(double.nan.compareTo(1.0), 1);

    // .. and now for Decimal128
    expect((-Decimal128.zero).compareTo(Decimal128.zero), -1);
    expect(Decimal128.zero.compareTo(-Decimal128.zero), 1);
    expect(Decimal128.zero.compareTo(Decimal128.zero), 0);
    expect((-Decimal128.zero).compareTo(-Decimal128.zero), 0);

    expect(Decimal128.negativeInfinity.compareTo(Decimal128.infinity), -1);
    expect(Decimal128.infinity.compareTo(Decimal128.negativeInfinity), 1);
    expect(Decimal128.infinity.compareTo(Decimal128.infinity), 0);
    expect(Decimal128.negativeInfinity.compareTo(Decimal128.negativeInfinity), 0);

    expect(Decimal128.one.compareTo(Decimal128.nan), -1);
    expect(Decimal128.nan.compareTo(Decimal128.nan), 0);
    expect(Decimal128.nan.compareTo(Decimal128.one), 1);
  });

  repeatTest('Decimal128.compareTo + <, <=, ==, !=, >=, >', (x, xInt, y, yInt) {
    expect(x.compareTo(x), 0);
    expect(x.compareTo(y), -(y.compareTo(x)));
    expect(x.compareTo(y), xInt.compareTo(yInt));

    expect(x < x, isFalse);
    expect(x < y, y > x);
    expect(x < y, xInt < yInt);

    expect(x <= x, isTrue);
    expect(x <= y, y >= x);
    expect(x <= y, xInt <= yInt);

    expect(x == x, isTrue);
    expect(x == y, y == x);
    expect(x == y, xInt == yInt);

    expect(x != x, isFalse);
    expect(x != y, y != x);
    expect(x != y, xInt != yInt);

    expect(x > x, isFalse);
    expect(x > y, y < x);
    expect(x > y, xInt > yInt);

    expect(x >= x, isTrue);
    expect(x >= y, y <= x);
    expect(x >= y, xInt >= yInt);
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
    expect(x.abs(), x.abs().abs()); // abs is idempotent
  });
}
