////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 Realm Inc.
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

import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';

import 'test.dart';

part 'realm_value_test.g.dart';

@RealmModel()
class _AnythingGoes {
  @Indexed()
  late RealmValue any;
  late List<RealmValue> manyAny;
}

void main() {
  group('any', () {
    test('Roundtrip', () {
      final config = Configuration.inMemory([AnythingGoes.schema]);
      final realm = getRealm(config);
      final something = realm.write(() => realm.add(AnythingGoes(any: RealmValue.bool(true))));
      expect(something.any.as<bool>(), true);
    });

    test('Illegal value', () {
      final config = Configuration.inMemory([AnythingGoes.schema]);
      final realm = getRealm(config);
      expect(() => realm.write(() => realm.add(AnythingGoes(any: RealmValue.from(<int>[1, 2])))), throwsArgumentError);
    });

    test('Switch', () {
      final something = AnythingGoes(any: RealmValue.int(1));
      switch (something.any.value?.runtimeType) {
        case null:
          break;
        case int:
        case String:
      }
    });

    test('If-switch', () {
      final something = AnythingGoes(any: RealmValue.double(3.14));
      final value = something.any.value;

      if (value == null) {
      } else if (value is int) {
        value + 1;
      } else if (value is String) {
        value.substring(2);
      }
    });
  });

  group('manyAny', () {
    test('foo', () {
      final config = Configuration.inMemory([AnythingGoes.schema]);
      final realm = getRealm(config);

      final something = realm.write(() => realm.add(AnythingGoes(manyAny: [RealmValue.bool(true), RealmValue.int(42)])));

      expect(something.manyAny.map((e) => e.value), [true, 42]);
      expect(something.manyAny, [RealmValue.bool(true), RealmValue.int(42)]);
    });
  });
}
