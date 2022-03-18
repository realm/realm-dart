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
import 'package:pub_semver/pub_semver.dart';

enum MetadataPersistenceMode {
  plainText,
  encrypted,
}

@immutable
class ApplicationConfiguration {
  /// The [appId] is the unique id that identifies the Realm application.
  final String appId;

  /// The [baseFilePath] is the [Directory] relative to which all local data for this application will be stored.
  /// This data includes metadata for users and synchronized Realms.
  final Directory? baseFilePath;

  /// The [baseUrl] is the [Uri] used to reach the MongoDB Realm server.
  /// [baseUrl] only needs to be set if for some reason your application isn't hosted on realm.mongodb.com.
  /// This can be the case if you're testing locally or are using a pre-production environment.
  final Uri? baseUrl;

  /// The [defaultRequestTimeout] for HTTP requests performed as part of authentication.
  final Duration? defaultRequestTimeout;

  /// The [localAppName] is the friendly name identifying the current client application.
  /// This is typically used to differentiate between client applications that use the same
  /// MongoDB Realm app. These can be the same conceptual app developed for different platforms, or
  /// significantly different client side applications that operate on the same data - e.g. an event managing
  /// service that has different clients apps for organizers and attendees.
  final String? localAppName;

  /// The [localAppVersion]
  final Version? localAppVersion;

  final MetadataPersistenceMode metadataPersistenceMode;

  /// The encryption key for user metadata on this device.
  /// This will not change the encryption key for individual Realms, which is set in the [Configuration]
  final List<int>? metadataEncryptionKey;

  /// The [HttpClient] that will be used for HTTP requests during authentication.
  /// You can use this to override the default http client handler and configure settings like proxies,
  /// client certificates, and cookies. While these are not required to connect to MongoDB Realm under
  /// normal circumstances, they can be useful if client devices are behind corporate firewall or use
  /// a more complex networking setup.
  final HttpClient httpClient;

  ApplicationConfiguration(
    this.appId, {
    this.baseUrl,
    this.baseFilePath,
    this.defaultRequestTimeout,
    this.localAppName,
    this.localAppVersion,
    this.metadataPersistenceMode = MetadataPersistenceMode.plainText,
    this.metadataEncryptionKey,
    HttpClient? httpClient,
  }) : httpClient = httpClient ?? HttpClient();
}
