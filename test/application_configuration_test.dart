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

import 'package:pub_semver/pub_semver.dart';
import 'package:test/expect.dart';

import '../lib/realm.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  setupTests(args);

  test('ApplicationConfiguration can be created', () {
    final a = ApplicationConfiguration('a');
    expect(a.appId, 'a');
    expect(a.baseFilePath.path, Directory.current.path);
    expect(a.baseUrl, Uri.parse('https://realm.mongodb.com'));
    expect(a.defaultRequestTimeout, const Duration(minutes: 1));

    final b = ApplicationConfiguration(
      'b',
      baseFilePath: Directory.systemTemp,
      baseUrl: Uri.parse('https://not_re.al'),
      defaultRequestTimeout: const Duration(seconds: 2),
      localAppName: 'bar',
      localAppVersion: Version(1, 0, 0),
      httpClient: HttpClient(context: SecurityContext(withTrustedRoots: false)),
    );
    expect(b.appId, 'b');
    expect(b.baseFilePath.path, Directory.systemTemp.path);
    expect(b.baseUrl,Uri.parse('https://not_re.al'));
    expect(b.defaultRequestTimeout, const Duration(milliseconds: 2000));
  });
}
