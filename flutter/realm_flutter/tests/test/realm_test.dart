// @dart=2.10

import 'dart:io';

import 'package:realm/realm.dart';
import 'package:test/test.dart';

void main() {
  initRealm();

  group('RealmClass tests', () {
    test('Realm version', () {
      expect(Realm.version, contains('11.'));
    });
  });

  tearDownAll(() async {
    exit(0);
  });
}