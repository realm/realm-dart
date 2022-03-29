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

import 'dart:io';

import 'package:realm_dart/src/application_credentials.dart';
import 'package:test/test.dart' hide test, throws;
import 'test.dart';

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  setupTests(args);

  test('ApplicationCredentials anonymous', () {
    final credentials = ApplicationCredentials.anonymous();
    expect(credentials.handle, isNotNull);
  });

  test('ApplicationCredentials unknown', () {
    expect(() => ApplicationCredentials(AuthProvider.unknown), throws<CredentialsException>("Unsupported authentication provider."));
  });
}
