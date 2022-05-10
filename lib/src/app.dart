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
import 'package:meta/meta.dart';
import 'native/realm_core.dart';
import 'credentials.dart';
import 'user.dart';
import 'configuration.dart';

/// Specify if and how to persists user objects.
/// {@category Application}
enum MetadataPersistenceMode {
  /// Persist [User] objects, but do not encrypt them.
  plaintext,

  /// Persist [User] objects in an encrypted store.
  encrypted,

  /// Do not persist [User] objects.
  disabled,
}

@immutable

/// A class exposing configuration options for an [App]
/// {@category Application}
class AppConfiguration {
  /// The [appId] is the unique id that identifies the Realm application.
  final String appId;

  /// The [baseFilePath] is the [Directory] relative to which all local data for this application will be stored.
  ///
  /// This data includes metadata for users and synchronized Realms. If set, you must ensure that the [baseFilePath]
  /// directory exists.
  final Directory baseFilePath;

  /// The [baseUrl] is the [Uri] used to reach the MongoDB Realm server.
  ///
  /// [baseUrl] only needs to be set if for some reason your application isn't hosted on realm.mongodb.com.
  /// This can be the case if you're testing locally or are using a pre-production environment.
  final Uri baseUrl;

  /// The [defaultRequestTimeout] for HTTP requests. Defaults to 60 seconds.
  final Duration defaultRequestTimeout;

  /// The [localAppName] is the friendly name identifying the current client application.
  ///
  /// This is typically used to differentiate between client applications that use the same
  /// MongoDB Realm app.
  ///
  /// These can be the same conceptual app developed for different platforms, or
  /// significantly different client side applications that operate on the same data - e.g. an event managing
  /// service that has different clients apps for organizers and attendees.
  final String? localAppName;

  /// The [localAppVersion] can be specified, if you wish to distinguish different client versions of the
  /// same application.
  final String? localAppVersion;

  /// Enumeration that specifies how and if logged-in User objects are persisted across application launches.
  final MetadataPersistenceMode metadataPersistenceMode;

  /// The encryption key to use for user metadata on this device, if [metadataPersistenceMode] is
  /// [MetadataPersistenceMode.encrypted].
  ///
  /// The [metadataEncryptionKey] must be exactly 64 bytes.
  /// Setting this will not change the encryption key for individual Realms, which is set in the [Configuration].
  final List<int>? metadataEncryptionKey;

  /// The [HttpClient] that will be used for HTTP requests during authentication.
  ///
  /// You can use this to override the default http client handler and configure settings like proxies,
  /// client certificates, and cookies. While these are not required to connect to MongoDB Realm under
  /// normal circumstances, they can be useful if client devices are behind corporate firewall or use
  /// a more complex networking setup.
  final HttpClient httpClient;

  /// Instantiates a new [AppConfiguration] with the specified appId.
  AppConfiguration(
    this.appId, {
    Uri? baseUrl,
    Directory? baseFilePath,
    this.defaultRequestTimeout = const Duration(seconds: 60),
    this.localAppName,
    this.localAppVersion,
    this.metadataEncryptionKey,
    this.metadataPersistenceMode = MetadataPersistenceMode.plaintext,
    HttpClient? httpClient,
  })  : baseUrl = baseUrl ?? Uri.parse('https://realm.mongodb.com'),
        baseFilePath = baseFilePath ?? Directory(Configuration.filesPath),
        httpClient = httpClient ?? HttpClient();
}

/// An [App] is the main client-side entry point for interacting with a MongoDB Realm App.
///
/// The [App]] can be used to
/// * Register uses and perform various user-related operations through authentication providers
/// * Synchronize data between the local device and a remote Realm App with Synchronized Realms
/// {@category Application}
class App {
  final AppHandle _handle;
  final AppConfiguration configuration;

  /// Create an app with a particular [AppConfiguration]
  App(this.configuration) : _handle = realmCore.getApp(configuration);

  /// Logs in a user with the given credentials.
  Future<User> logIn(Credentials credentials) async {
    var userHandle = await realmCore.logIn(this, credentials);
    return UserInternal.create(this, userHandle);
  }

  /// Gets the currently logged in [User]. If none exists, `null` is returned.
  User? get currentUser {
    final userHandle = realmCore.getCurrentUser(_handle);
    if (userHandle == null) {
      return null;
    }
    return UserInternal.create(this, userHandle);
  }

  /// Gets all currently logged in users.
  Iterable<User> get users {
    return realmCore.getUsers(this).map((handle) => UserInternal.create(this, handle));
  }

  /// Removes a [user] and their local data from the device. If the user is logged in, they will be logged out in the process.
  Future<void> removeUser(User user) async {
    return await realmCore.removeUser(this, user);
  }
  
  /// Switches the [currentUser] to the one specified in [user].
  void switchUser(User user) {
    realmCore.switchUser(this, user);
  }

  /// Returns an instance of [EmailPasswordAuthProvider]
  EmailPasswordAuthProvider get emailPasswordAuthProvider => EmailPasswordAuthProviderInternal.create(this);
}

/// @nodoc
extension AppInternal on App {
  AppHandle get handle => _handle;
}
