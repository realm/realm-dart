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
  late RealmValue? any;
}

void main() {
  test('Roundtrip', () {
    final config = Configuration.inMemory([AnythingGoes.schema]);
    final realm = getRealm(config);
    final something = realm.write(() => realm.add(AnythingGoes(any: RealmValue.bool(true))));
    expect(something.any!.as<bool>(), true);
  });

  test('Switch', () {
    final something = AnythingGoes();
    switch (something.any?.value.runtimeType) {
      case null:
        break;
      case int:
      case String:
    }
  });

  test('If-switch', () {
    final something = AnythingGoes();
    final value = something.any?.value;
    if (value == null) {
    } else if (value is int) {
      value + 1;
    } else if (value is String) {
      value.substring(2);
    }
  });
}
