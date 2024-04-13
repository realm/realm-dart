// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import '../realm.dart';
import 'credentials.dart';
import 'logging.dart';
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

  if (Platform.isWindows) {
    try {
      final context = SecurityContext(withTrustedRoots: true);
      context.setTrustedCertificatesBytes(const AsciiEncoder().convert(isrgRootX1CertPEM));
      return HttpClient(context: context);
    } on TlsException catch (e) {
      // certificate is already trusted. Nothing to do here
      if (e.osError?.message.contains("CERT_ALREADY_IN_HASH_TABLE") != true) {
        rethrow;
      }
    }
  }

  return HttpClient();
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
  /// [baseUrl] only needs to be set if for some reason your application isn't hosted on services.cloud.mongodb.com.
  /// This can be the case if you're synchronizing with an edge server.
  final Uri baseUrl;

  /// The [defaultRequestTimeout] for HTTP requests. Defaults to 60 seconds.
  final Duration defaultRequestTimeout;

  /// The maximum duration to allow for a connection to
  /// become fully established. This includes the time to resolve the
  /// network address, the TCP connect operation, the SSL handshake, and
  /// the WebSocket handshake. Defaults to 2 minutes.
  final Duration maxConnectionTimeout;

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
    this.metadataEncryptionKey,
    this.metadataPersistenceMode = MetadataPersistenceMode.plaintext,
    this.maxConnectionTimeout = const Duration(minutes: 2),
    HttpClient? httpClient,
  })  : baseUrl = baseUrl ?? Uri.parse(realmCore.getDefaultBaseUrl()),
        baseFilePath = baseFilePath ?? Directory(path.dirname(Configuration.defaultRealmPath)),
        httpClient = httpClient ?? _defaultClient {
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
class App implements Finalizable {
  final AppHandle _handle;

  /// The id of this application. This is the same as the appId in the [AppConfiguration] used to
  /// create this [App].
  String get id => this.handle.id;

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
    final handle = realmCore.getApp(id, baseUrl?.toString());
    return handle == null ? null : App._(handle);
  }

  App._(this._handle);

  static AppHandle _createApp(AppConfiguration configuration) {
    configuration.baseFilePath.createSync(recursive: true);
    return AppHandle(configuration);
  }

  /// Logs in a user with the given credentials.
  Future<User> logIn(Credentials credentials) async {
    var userHandle = await handle.logIn(credentials);
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
    var errorString = "AppException: $message, status code: $statusCode";
    if (linkToServerLogs != null) {
      errorString += ", link to server logs: $linkToServerLogs";
    }

    return errorString;
  }
}
