// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:isolate';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import '../realm.dart';
import 'credentials.dart';
import 'handles/app_handle.dart';
import 'handles/default_client.dart';
import 'handles/realm_core.dart';
import 'logging.dart';
import 'user.dart';

/// Options for configuring timeouts and intervals used by the sync client.
@immutable
class SyncTimeoutOptions {
  /// Controls the maximum amount of time to allow for a connection to
  /// become fully established.
  ///
  /// This includes the time to resolve the
  /// network address, the TCP connect operation, the SSL handshake, and
  /// the WebSocket handshake.
  ///
  /// Defaults to 2 minutes.
  final Duration connectTimeout; // TimeSpan.FromMinutes(2);

  /// Controls the amount of time to keep a connection open after all
  /// sessions have been abandoned.
  ///
  /// After all synchronized Realms have been closed for a given server, the
  /// connection is kept open until the linger time has expired to avoid the
  /// overhead of reestablishing the connection when Realms are being closed and
  /// reopened.
  ///
  /// Defaults to 30 seconds.
  final Duration connectionLingerTime;

  /// Controls how long to wait between each heartbeat ping message.
  ///
  /// The client periodically sends ping messages to the server to check if the
  /// connection is still alive. Shorter periods make connection state change
  /// notifications more responsive at the cost of battery life (as the antenna
  /// will have to wake up more often).
  ///
  /// Defaults to 1 minute.
  final Duration pingKeepAlivePeriod;

  /// Controls how long to wait for a reponse to a heartbeat ping before
  /// concluding that the connection has dropped.
  ///
  /// Shorter values will make connection state change notifications more
  /// responsive as it will only change to `disconnected` after this much time has
  /// elapsed, but overly short values may result in spurious disconnection
  /// notifications when the server is simply taking a long time to respond.
  ///
  /// Defaults to 2 minutes.
  final Duration pongKeepAliveTimeout;

  /// Controls the maximum amount of time since the loss of a
  /// prior connection, for a new connection to be considered a "fast
  /// reconnect".
  ///
  /// When a client first connects to the server, it defers uploading any local
  /// changes until it has downloaded all changesets from the server. This
  /// typically reduces the total amount of merging that has to be done, and is
  /// particularly beneficial the first time that a specific client ever connects
  /// to the server.
  ///
  /// When an existing client disconnects and then reconnects within the "fact
  /// reconnect" time this is skipped and any local changes are uploaded
  /// immediately without waiting for downloads, just as if the client was online
  /// the whole time.
  ///
  /// Defaults to 1 minute.
  final Duration fastReconnectLimit;

  const SyncTimeoutOptions(
      {this.connectTimeout = const Duration(minutes: 2),
      this.connectionLingerTime = const Duration(seconds: 30),
      this.pingKeepAlivePeriod = const Duration(minutes: 1),
      this.pongKeepAliveTimeout = const Duration(minutes: 2),
      this.fastReconnectLimit = const Duration(minutes: 1)});
}

/// A class exposing configuration options for an [App]
/// {@category Application}
@immutable
class AppConfiguration {
  /// The [appId] is the unique id that identifies the [Atlas App Services](https://www.mongodb.com/docs/atlas/app-services/) application.
  final String appId;

  /// The [baseFilePath] is the [Directory] relative to which all local data for this application will be stored.
  ///
  /// This data includes metadata for users and synchronized Realms. If set, you must ensure that the [baseFilePath]
  /// directory exists.
  final String baseFilePath;

  /// The [baseUrl] is the [Uri] used to reach the MongoDB Atlas.
  ///
  /// [baseUrl] only needs to be set if for some reason your application isn't hosted on services.cloud.mongodb.com.
  /// This can be the case if you're synchronizing with an edge server.
  final Uri baseUrl;

  /// The [defaultRequestTimeout] for HTTP requests. Defaults to 60 seconds.
  final Duration defaultRequestTimeout;

  /// The maximum duration to allow for a connection to
  /// become fully established. This includes the time to resolve the
  /// network address, the TCP connect operation, the SSL handshake, and
  /// the WebSocket handshake. Defaults to 2 minutes.
  @Deprecated('Use SyncTimeoutOptions.connectTimeout')
  final Duration maxConnectionTimeout;

  /// Enumeration that specifies how and if logged-in User objects are persisted across application launches.
  final MetadataPersistenceMode metadataPersistenceMode;

  /// The encryption key to use for user metadata on this device, if [metadataPersistenceMode] is
  /// [MetadataPersistenceMode.encrypted].
  ///
  /// The [metadataEncryptionKey] must be exactly 64 bytes.
  /// Setting this will not change the encryption key for individual Realms, which is set in the [Configuration].
  final List<int>? metadataEncryptionKey;

  /// The [Client] that will be used for HTTP requests during authentication.
  ///
  /// You can use this to override the default http client handler and configure settings like proxies,
  /// client certificates, and cookies. While these are not required to connect to MongoDB Atlas under
  /// normal circumstances, they can be useful if client devices are behind corporate firewall or use
  /// a more complex networking setup.
  final Client httpClient;

  /// Options for the assorted types of connection timeouts for sync connections opened for this app.
  final SyncTimeoutOptions syncTimeoutOptions;

  /// Instantiates a new [AppConfiguration] with the specified appId.
  AppConfiguration(this.appId,
      {Uri? baseUrl,
      String? baseFilePath,
      this.defaultRequestTimeout = const Duration(seconds: 60),
      this.metadataEncryptionKey,
      this.metadataPersistenceMode = MetadataPersistenceMode.plaintext,
      @Deprecated('Use SyncTimeoutOptions.connectTimeout') this.maxConnectionTimeout = const Duration(minutes: 2),
      Client? httpClient,
      this.syncTimeoutOptions = const SyncTimeoutOptions()})
      : baseUrl = baseUrl ?? Uri.parse(realmCore.getDefaultBaseUrl()),
        baseFilePath = baseFilePath ?? path.dirname(Configuration.defaultRealmPath),
        httpClient = httpClient ?? defaultClient {
    if (appId == '') {
      throw RealmException('Supplied appId must be a non-empty value');
    }
  }
}

/// An [App] is the main client-side entry point for interacting with an [Atlas App Services](https://www.mongodb.com/docs/atlas/app-services/) application.
///
/// The [App] can be used to
/// * Register uses and perform various user-related operations through authentication providers
/// * Synchronize data between the local device and a remote Realm App with Synchronized Realms
/// {@category Application}
class App {
  final AppHandle _handle;

  /// The id of this application. This is the same as the appId in the [AppConfiguration] used to
  /// create this [App].
  String get id => handle.id;

  /// Create an app with a particular [AppConfiguration]. This constructor should only be used on the main isolate and,
  /// ideally, only once as soon as the app starts.
  App(AppConfiguration configuration) : _handle = _createApp(configuration) {
    // This is not foolproof, but could point people to errors they may have in their app. Realm apps are cached natively, so calling App(config)
    // on a background isolate will not recreate the app. Instead, users should construct the app on the main isolate and then call getById on the
    // background isolates. This check will log a warning if the isolate name is != 'main' and doesn't start with 'test/' since dart test will
    // construct a new isolate per file and we don't want to log excessively in unit test projects.
    if (Isolate.current.debugName != 'main' && Isolate.current.debugName?.startsWith('test/') == false) {
      Realm.logger.log(LogLevel.warn,
          "App constructor called on Isolate ${Isolate.current.debugName} which doesn't appear to be the main isolate. If you need an app instance on a background isolate use App.getById after constructing the App on the main isolate.");
    }
  }

  /// Obtain an [App] instance by id. The app must have first been created by calling the constructor that takes an [AppConfiguration]
  /// on the main isolate. If an App hasn't been already constructed with the same id, will return null. This method is safe to call
  /// on a background isolate.
  static App? getById(String id, {Uri? baseUrl}) {
    final handle = AppHandle.get(id, baseUrl?.toString());
    return handle == null ? null : App._(handle);
  }

  App._(this._handle);

  static AppHandle _createApp(AppConfiguration configuration) {
    return AppHandle.from(configuration);
  }

  /// Logs in a user with the given credentials.
  Future<User> logIn(Credentials credentials) async {
    var userHandle = await handle.logIn(credentials.handle);
    return UserInternal.create(userHandle, this);
  }

  /// Gets the currently logged in [User]. If none exists, `null` is returned.
  User? get currentUser {
    final userHandle = _handle.currentUser;
    if (userHandle == null) {
      return null;
    }
    return UserInternal.create(userHandle, this);
  }

  /// Gets all currently logged in users.
  Iterable<User> get users {
    return handle.users.map((handle) => UserInternal.create(handle, this));
  }

  /// Removes a [user] and their local data from the device. If the user is logged in, they will be logged out in the process.
  Future<void> removeUser(User user) async {
    return await handle.removeUser(user.handle);
  }

  /// Deletes a user and all its data from the device as well as the server.
  Future<void> deleteUser(User user) async {
    return await handle.deleteUser(user.handle);
  }

  /// Switches the [currentUser] to the one specified in [user].
  void switchUser(User user) {
    handle.switchUser(user.handle);
  }

  /// Provide a hint to this app's sync client to reconnect.
  /// Useful when the device has been offline and then receives a network reachability update.
  ///
  /// The sync client will always attempt to reconnect eventually, this is just a hint.
  void reconnect() {
    handle.reconnect();
  }

  /// Returns the current value of the base URL used to communicate with the server.
  ///
  /// If an [updateBaseUrl] operation is currently in progress, this value will not
  /// be updated with the new value until that operation has completed.
  @experimental
  Uri get baseUrl {
    return Uri.parse(handle.baseUrl);
  }

  /// Temporarily overrides the [baseUrl] value from [AppConfiguration] with a new [baseUrl] value
  /// used for communicating with the server. If set to `null`, the app will revert to the default
  /// base url.
  ///
  /// If this operation fails, the app will continue to use the original base URL. If another [App]
  /// operation is started while this function is in progress, that request will use the original
  /// base URL location information.
  ///
  /// The App will revert to using the value in [AppConfiguration] when it is restarted.
  @experimental
  Future<void> updateBaseUrl(Uri? baseUrl) async {
    return await handle.updateBaseUrl(baseUrl);
  }

  /// Returns an instance of [EmailPasswordAuthProvider]
  EmailPasswordAuthProvider get emailPasswordAuthProvider => EmailPasswordAuthProviderInternal.create(this);
}

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

/// @nodoc
extension AppInternal on App {
  AppHandle get handle => _handle;

  static App create(AppHandle handle) => App._(handle);

  static AppException createException(String message, String? linkToLogs, int statusCode) => AppException._(message, linkToLogs, statusCode);
}

/// An exception thrown from operations interacting with a [Atlas App Services](https://www.mongodb.com/docs/atlas/app-services/) app.
class AppException extends RealmException {
  /// A link to the server logs associated with this exception if available.
  final String? linkToServerLogs;

  /// The HTTP status code returned by the server for this exception.
  final int statusCode;

  AppException._(super.message, this.linkToServerLogs, this.statusCode);

  @override
  String toString() {
    var errorString = "AppException: $message, status code: $statusCode";
    if (linkToServerLogs != null) {
      errorString += ", link to server logs: $linkToServerLogs";
    }

    return errorString;
  }
}
