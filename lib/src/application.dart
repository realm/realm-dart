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
import 'email_password_provider.dart';
import 'native/realm_core.dart';
import 'credentials.dart';
import 'user.dart';

class Application {
  final RealmAppHandle _handle;
  late final EmailPasswordProvider _emailPasswordProvider;

  Application(ApplicationConfiguration configuration) : _handle = realmCore.getApp(configuration.handle) {
    _emailPasswordProvider = EmailPasswordProvider(this);
  }

  EmailPasswordProvider get emailPasswordProvider => _emailPasswordProvider;

  Future<User> logIn(Credentials credentials) async {
    return UserInternal.create(await realmCore.logIn(_handle, credentials.handle));
  }
}

extension ApplicationInternal on Application {
  RealmAppHandle get handle => _handle;
}
