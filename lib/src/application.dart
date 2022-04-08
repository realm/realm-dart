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
import 'application_configuration.dart';

import 'native/realm_core.dart';
import 'credentials.dart';
import 'user.dart';

class Application {
  final AppHandle _handle;
  final ApplicationConfiguration configuration;

  Application(this.configuration) : _handle = realmCore.getApp(configuration);

  Future<User> logIn(Credentials credentials) async {
    return UserInternal.create(await realmCore.logIn(this, credentials));
  }
}

extension ApplicationInternal on Application {
  AppHandle get handle => _handle;
}
