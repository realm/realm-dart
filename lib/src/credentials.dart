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
import 'native/realm_core.dart';

/// An enum containing all authentication providers. These have to be enabled manually for the application before they can be used.
/// [Authentication Providers Docs](https://docs.mongodb.com/realm/authentication/providers/)
/// {@category Application}
enum AuthProvider {
  /// Mechanism for authenticating without credentials.
  anonymous,

  /// Mechanism for authenticating with an email and a password.
  emailPassword,
}

/// A class, representing the credentials used for authenticating a [User]
/// {@category Application}
class Credentials {
  late final RealmAppCredentialsHandle _handle;

  final AuthProvider provider;

  /// Returns a [Credentials] object that can be used to authenticate an anonymous user.
  /// [Anonymous Authentication Docs](https://docs.mongodb.com/realm/authentication/anonymous)
  Credentials.anonymous()
      : _handle = realmCore.createAppCredentialsAnonymous(),
        provider = AuthProvider.anonymous;
}

/// @nodoc
extension CredentialsInternal on Credentials {
  RealmAppCredentialsHandle get handle => _handle;
}
