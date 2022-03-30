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
import 'application.dart';
import 'native/realm_core.dart';

/// A class, encapsulating functionality for users, logged in with [Credentials.emailPassword()].
/// It is always scoped to a particular app and can only be accessed via [emailPasswordProvider].
/// {@category Application}
class EmailPasswordProvider {
  final RealmAppHandle _handle;

  EmailPasswordProvider(Application app) : _handle = app.handle;

  /// Registers a new user with the given email and password.
  /// The [email] to register with. This will be the user's username and, if user confirmation is enabled, this will be the address for
  /// the confirmation email.
  /// The [password] to associate with the email. The password must be between 6 and 128 characters long.
  /// Returns an awaitable [Future<bool>] representing the asynchronous RegisterUser operation. Successful completion indicates that the user has been
  /// created on the server and can now be logged in calling [logIn] with [Credentials.emailPassword()]"
  Future<bool> registerUser(String email, String password) async {
    return await realmCore.appEmailPasswordRegisterUser(_handle, email, password);
  }
}
