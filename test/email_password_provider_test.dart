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
import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  await setupTests(args);

  test('Email/Password - register user', () async {
    final application = await getApp();
    await application.emailPasswordProvider.registerUser("foo@bar.com", "SWV23R#@T#VFQDV");
  }, skip: "Skip until login is implemented.");

  test('Email/Password - register user twice throws', () async {
    final application = await getApp();
    await application.emailPasswordProvider.registerUser("foo@bar.com", "SWV23R#@T#VFQDV");
    expect(() async {
      await application.emailPasswordProvider.registerUser("foo@bar.com", "SWV23R#@T#VFQDV");
    }, throws<RealmException>("name already in use"));
  }, skip: "Skip until login is implemented.");

  test('Email/Password - register user with weak password throws', () async {
    final application = await getApp();
    expect(() async {
      await application.emailPasswordProvider.registerUser("foo@bar.com", "pwd");
    }, throws<RealmException>("password must be between 6 and 128 characters"));
  }, skip: "Skip until login is implemented.");
}
