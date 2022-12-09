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
  group('RealmValue', () {
    final config = Configuration.inMemory([AnythingGoes.schema]);
    final realm = getRealm(config);

    for (final x in <Object?>[
      null,
      true,
      'text',
      42,
      3.14,
//      AnythingGoes(),
      DateTime.now().toUtc(),
      ObjectId.fromTimestamp(DateTime.now()),
      Uuid.v4(),
    ]) {
      test('Roundtrip ${x.runtimeType} $x', () {
        final something = realm.write(() => realm.add(AnythingGoes(any: RealmValue.from(x))));
        expect(something.any.value, x);
        expect(something.any, RealmValue.from(x));
      });
    }

    test('Illegal value', () {
      expect(() => realm.write(() => realm.add(AnythingGoes(any: RealmValue.from(<int>[1, 2])))), throwsArgumentError);
    });

    test('Switch', () {
      final something = AnythingGoes(any: RealmValue.int(1));
      final v = something.any.value;
      switch (v?.runtimeType) {
        case null:
          break;
        case int:
          (v as int) + 2;
          break;

        case String:
      }
    });

    test('If-is', () {
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

  group('List<RealmValue>', () {
    test('Roundtrip', () {
      final config = Configuration.inMemory([AnythingGoes.schema]);
      final realm = getRealm(config);

      final now = DateTime.now().toUtc();
      final oid = ObjectId.fromTimestamp(now);
      final uuid = Uuid.v4();

      final something = realm.write(() => realm.add(AnythingGoes(manyAny: [
            const RealmValue.nullValue(),
            const RealmValue.bool(true),
            const RealmValue.string('text'),
            const RealmValue.int(42),
            const RealmValue.double(3.14),
//            RealmValue.realmObject(AnythingGoes()),
            RealmValue.dateTime(now),
            RealmValue.objectId(oid),
            RealmValue.uuid(uuid),
          ])));

      expect(something.manyAny.map((e) => e.value), [null, true, 'text', 42, 3.14, now, oid, uuid]);
      expect(something.manyAny, [null, true, 'text', 42, 3.14, now, oid, uuid].map((e) => RealmValue.from(e)));
//      expect(something.manyAny.cast<Object>(), [true, 42]);
    });
  });
}
