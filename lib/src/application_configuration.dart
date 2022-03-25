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

import 'cli/common/utils.dart';
import 'native/realm_core.dart';

@immutable
class ApplicationConfiguration {
  final RealmAppConfigHandle _handle;

  final String appId;
  final Uri? baseUrl;
  final Duration? defaultRequestTimeout;
  final String? localAppName;
  final Version? localAppVersion;

  ApplicationConfiguration(
    this.appId, {
    this.baseUrl,
    this.defaultRequestTimeout,
    this.localAppName,
    this.localAppVersion,
  }) : _handle = realmCore.createAppConfig(appId, realmCore.createHttpTransport(HttpClient())) {
    if (baseUrl != null) realmCore.setAppConfigBaseUrl(_handle, baseUrl!);
    if (defaultRequestTimeout != null) realmCore.setAppConfigDefaultRequestTimeout(_handle, defaultRequestTimeout!);
    if (localAppName != null) realmCore.setAppConfigLocalAppName(_handle, localAppName!);
    if (localAppVersion != null) realmCore.setAppConfigLocalAppVersion(_handle, localAppVersion!);
    realmCore.setAppConfigPlatform(_handle, Platform.operatingSystem);
    realmCore.setAppConfigPlatformVersion(_handle, Platform.operatingSystemVersion);
    realmCore.setAppConfigSdkVersion(_handle, Version.parse(Platform.version.takeUntil(' ')));
  }
}

extension ApplicationConfigurationInternal on ApplicationConfiguration {
  RealmAppConfigHandle get handle => _handle;
}