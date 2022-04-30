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

import 'dart:convert';

import 'native/realm_core.dart';
import 'app.dart';

/// This class represents a user in a MongoDB Realm app.
/// A user can log in to the server and, if access is granted, it is possible to synchronize the local Realm to MongoDB.
/// Moreover, synchronization is halted when the user is logged out. It is possible to persist a user. By retrieving a user, there is no need to log in again.
/// Persisting a user between sessions, the user's credentials are stored
/// locally on the device, and should be treated as sensitive data.
/// {@category Application}
class User {
  final UserHandle _handle;
  
  /// The [App] with which the user is associated with.
  final App app;

  User._(this.app, this._handle);

  /// The custom user data associated with this user.
  /// 
  /// The data is only refreshed when the user's access token is refreshed or when explicitly calling [refreshCustomData] 
  dynamic get customData {
    final data = realmCore.userGetCustomData(this);
    return jsonDecode(data);
  }

  /// Re-fetch the user's custom data from the server.
  Future<dynamic> refreshCustomData() async {
    await realmCore.userRefreshCustomData(app, this);
    return customData;
  }
}

/// @nodoc
extension UserInternal on User {
  UserHandle get handle => _handle;

  static User create(App app, UserHandle handle) => User._(app, handle);
}
