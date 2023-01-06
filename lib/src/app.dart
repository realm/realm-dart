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
import 'dart:ffi';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as _path;

import '../realm.dart';
import 'credentials.dart';
import 'native/realm_core.dart';
import 'user.dart';

final _defaultClient = () {
  const isrgRootX1CertPEM = // The root certificate used by lets encrypt and hence MongoDB
      '''
subject=CN=ISRG Root X1,O=Internet Security Research Group,C=US
issuer=CN=DST Root CA X3,O=Digital Signature Trust Co.
-----BEGIN CERTIFICATE-----
MIIFYDCCBEigAwIBAgIQQAF3ITfU6UK47naqPGQKtzANBgkqhkiG9w0BAQsFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTIxMDEyMDE5MTQwM1oXDTI0MDkzMDE4MTQwM1ow
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwggIiMA0GCSqGSIb3DQEB
AQUAA4ICDwAwggIKAoICAQCt6CRz9BQ385ueK1coHIe+3LffOJCMbjzmV6B493XC
ov71am72AE8o295ohmxEk7axY/0UEmu/H9LqMZshftEzPLpI9d1537O4/xLxIZpL
wYqGcWlKZmZsj348cL+tKSIG8+TA5oCu4kuPt5l+lAOf00eXfJlII1PoOK5PCm+D
LtFJV4yAdLbaL9A4jXsDcCEbdfIwPPqPrt3aY6vrFk/CjhFLfs8L6P+1dy70sntK
4EwSJQxwjQMpoOFTJOwT2e4ZvxCzSow/iaNhUd6shweU9GNx7C7ib1uYgeGJXDR5
bHbvO5BieebbpJovJsXQEOEO3tkQjhb7t/eo98flAgeYjzYIlefiN5YNNnWe+w5y
sR2bvAP5SQXYgd0FtCrWQemsAXaVCg/Y39W9Eh81LygXbNKYwagJZHduRze6zqxZ
Xmidf3LWicUGQSk+WT7dJvUkyRGnWqNMQB9GoZm1pzpRboY7nn1ypxIFeFntPlF4
FQsDj43QLwWyPntKHEtzBRL8xurgUBN8Q5N0s8p0544fAQjQMNRbcTa0B7rBMDBc
SLeCO5imfWCKoqMpgsy6vYMEG6KDA0Gh1gXxG8K28Kh8hjtGqEgqiNx2mna/H2ql
PRmP6zjzZN7IKw0KKP/32+IVQtQi0Cdd4Xn+GOdwiK1O5tmLOsbdJ1Fu/7xk9TND
TwIDAQABo4IBRjCCAUIwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYw
SwYIKwYBBQUHAQEEPzA9MDsGCCsGAQUFBzAChi9odHRwOi8vYXBwcy5pZGVudHJ1
c3QuY29tL3Jvb3RzL2RzdHJvb3RjYXgzLnA3YzAfBgNVHSMEGDAWgBTEp7Gkeyxx
+tvhS5B1/8QVYIWJEDBUBgNVHSAETTBLMAgGBmeBDAECATA/BgsrBgEEAYLfEwEB
ATAwMC4GCCsGAQUFBwIBFiJodHRwOi8vY3BzLnJvb3QteDEubGV0c2VuY3J5cHQu
b3JnMDwGA1UdHwQ1MDMwMaAvoC2GK2h0dHA6Ly9jcmwuaWRlbnRydXN0LmNvbS9E
U1RST09UQ0FYM0NSTC5jcmwwHQYDVR0OBBYEFHm0WeZ7tuXkAXOACIjIGlj26Ztu
MA0GCSqGSIb3DQEBCwUAA4IBAQAKcwBslm7/DlLQrt2M51oGrS+o44+/yQoDFVDC
5WxCu2+b9LRPwkSICHXM6webFGJueN7sJ7o5XPWioW5WlHAQU7G75K/QosMrAdSW
9MUgNTP52GE24HGNtLi1qoJFlcDyqSMo59ahy2cI2qBDLKobkx/J3vWraV0T9VuG
WCLKTVXkcGdtwlfFRjlBz4pYg1htmf5X6DYO8A4jqv2Il9DjXA6USbW1FzXSLr9O
he8Y4IWS6wY7bCkjCWDcRQJMEhg76fsO3txE+FiYruq9RUWhiF1myv4Q6W+CyBFC
Dfvp7OOGAN6dEOM4+qR9sdjoSYKEBpsr6GtPAQw4dy753ec5
-----END CERTIFICATE-----''';

  final context = SecurityContext(withTrustedRoots: true);
  context.setTrustedCertificatesBytes(const AsciiEncoder().convert(isrgRootX1CertPEM));
  return HttpClient(context: context);
}();

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
  final Directory baseFilePath;

  /// The [baseUrl] is the [Uri] used to reach the MongoDB Atlas.
  ///
  /// [baseUrl] only needs to be set if for some reason your application isn't hosted on realm.mongodb.com.
  /// This can be the case if you're testing locally or are using a pre-production environment.
  final Uri baseUrl;

  /// The [defaultRequestTimeout] for HTTP requests. Defaults to 60 seconds.
  final Duration defaultRequestTimeout;

  /// The maximum duration to allow for a connection to
  /// become fully established. This includes the time to resolve the
  /// network address, the TCP connect operation, the SSL handshake, and
  /// the WebSocket handshake. Defaults to 2 minutes.
  final Duration maxConnectionTimeout;

  /// The [localAppName] is the friendly name identifying the current client application.
  ///
  /// This is typically used to differentiate between client applications that use the same
  /// [Atlas App Services](https://www.mongodb.com/docs/atlas/app-services/) application.
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
  /// client certificates, and cookies. While these are not required to connect to MongoDB Atlas under
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
    this.maxConnectionTimeout = const Duration(minutes: 2),
    HttpClient? httpClient,
  })  : baseUrl = baseUrl ?? Uri.parse('https://realm.mongodb.com'),
        baseFilePath = baseFilePath ?? Directory(_path.dirname(Configuration.defaultRealmPath)),
        httpClient = httpClient ?? _defaultClient;
}

/// An [App] is the main client-side entry point for interacting with an [Atlas App Services](https://www.mongodb.com/docs/atlas/app-services/) application.
///
/// The [App] can be used to
/// * Register uses and perform various user-related operations through authentication providers
/// * Synchronize data between the local device and a remote Realm App with Synchronized Realms
/// {@category Application}
class App implements Finalizable {
  final AppHandle _handle;

  /// The id of this application. This is the same as the appId in the [AppConfiguration] used to
  /// create this [App].
  String get id => realmCore.appGetId(this);

  /// Create an app with a particular [AppConfiguration]
  App(AppConfiguration configuration) : this._(_createApp(configuration));

  App._(this._handle);

  static AppHandle _createApp(AppConfiguration configuration) {
    configuration.baseFilePath.createSync(recursive: true);
    return realmCore.createApp(configuration);
  }

  /// Logs in a user with the given credentials.
  Future<User> logIn(Credentials credentials) async {
    var userHandle = await realmCore.logIn(this, credentials);
    return UserInternal.create(userHandle, this);
  }

  /// Gets the currently logged in [User]. If none exists, `null` is returned.
  User? get currentUser {
    final userHandle = realmCore.getCurrentUser(_handle);
    if (userHandle == null) {
      return null;
    }
    return UserInternal.create(userHandle, this);
  }

  /// Gets all currently logged in users.
  Iterable<User> get users {
    return realmCore.getUsers(this).map((handle) => UserInternal.create(handle, this));
  }

  /// Removes a [user] and their local data from the device. If the user is logged in, they will be logged out in the process.
  Future<void> removeUser(User user) async {
    return await realmCore.removeUser(this, user);
  }

  /// Deletes a user and all its data from the device as well as the server.
  Future<void> deleteUser(User user) async {
    return await realmCore.deleteUser(this, user);
  }

  /// Switches the [currentUser] to the one specified in [user].
  void switchUser(User user) {
    realmCore.switchUser(this, user);
  }

  /// Provide a hint to this app's sync client to reconnect.
  /// Useful when the device has been offline and then receives a network reachability update.
  ///
  /// The sync client will always attempt to reconnect eventually, this is just a hint.
  void reconnect() {
    realmCore.reconnect(this);
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
  @pragma('vm:never-inline')
  void keepAlive() {
    _handle.keepAlive();
  }

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
    return "AppException: $message, link to server logs: $linkToServerLogs";
  }
}
