// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';

import 'package:ejson/ejson.dart';
import 'package:test/test.dart';

void main() {
  test('round-trip', () {
    final value = {
      'abe': [1, 4],
      'kat': <int>[],
    };
    final encoded = toEJson(value);
    final json = jsonEncode(encoded);
    print(json);
    final decoded = fromEJson<Map<String, List<int>>>(jsonDecode(json));
    expect(value, decoded);
  });
}
