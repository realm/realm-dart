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

import 'package:http/http.dart' as http;
import 'dart:convert';

class BaasClient {
  static const String _confirmFuncSource = '''exports = ({ token, tokenId, username }) => {
    // process the confirm token, tokenId and username
    if (username.includes("realm_tests_do_autoverify")) {
      return { status: 'success' }
    }
    // do not confirm the user
    return { status: 'fail' };
  };''';

  static const String _resetFuncSource = '''exports = ({ token, tokenId, username, password }) => {
    // process the reset token, tokenId, username and password
    if (password.includes("realm_tests_do_reset")) {
      return { status: 'success' };
    }
    // will not reset the password
    return { status: 'fail' };
  };''';

  final String _baseUrl;
  final String? _clusterName;
  final String _appSuffix;
  final Map<String, String> _headers;

  late String _groupId;

  BaasClient._(String baseUrl, [this._clusterName])
      : _baseUrl = '$baseUrl/api/admin/v3.0',
        _headers = <String, String>{'Accept': 'application/json'},
        _appSuffix = '-$_clusterName';

  /// A client that imports apps in a MongoDB Realm docker image. See https://github.com/realm/ci/tree/master/realm/docker/mongodb-realm
  /// for instructions on how to set it up.
  /// @nodoc
  static Future<BaasClient> docker(String baseUrl) async {
    final result = BaasClient._(baseUrl);

    await result._authenticate('local-userpass', '{ "username": "unique_user@domain.com", "password": "password" }');

    dynamic groupDoc = await result._get('auth/profile');
    result._groupId = (groupDoc['roles'] as List<dynamic>)[0]['group_id'] as String;

    print('Current GroupID ${result._groupId}');

    return result;
  }

  /// A client that imports apps to an MongoDB Realm environment (typically realm-dev or realm-qa).
  /// @nodoc
  static Future<BaasClient> atlas(String baseUrl, String cluster, String apiKey, String privateApiKey, String groupId) async {
    final BaasClient result = BaasClient._(baseUrl, cluster);

    await result._authenticate('mongodb-cloud', '{ "username": "$apiKey", "apiKey": "$privateApiKey" }');

    result._groupId = groupId;

    return result;
  }

  /// Tries to look up the applications for the specified cluster. For [docker] client, returns all apps,
  /// for [atlas] one, it will return only apps with suffix equal to the cluster name. If no apps exist,
  /// then it will create the test applications and return them.
  /// @nodoc
  Future<Map<String, BaasApp>> getOrCreateApps() async {
    final result = <String, BaasApp>{};
    var apps = await _getApps();
    if (apps.isNotEmpty) {
      for (final app in apps) {
        result[app.name] = app;
      }
    }
    const String appName = 'flexible';

    if (!result.containsKey(appName)) {
      final defaultApp = await _createApp(appName);
      result[defaultApp.name] = defaultApp;
    }
    // Add more types of apps as we add more tests here.
    return result;
  }

  Future<List<BaasApp>> _getApps() async {
    final apps = await _get('groups/$_groupId/apps') as List<dynamic>;
    return apps
        .map((dynamic doc) {
          final name = doc['name'] as String;
          if (!name.endsWith(_appSuffix)) {
            return null;
          }

          final appName = name.substring(0, name.length - _appSuffix.length);
          return BaasApp(doc['_id'] as String, doc['client_app_id'] as String, appName);
        })
        .where((doc) => doc != null)
        .map((doc) => doc!)
        .toList();
  }

  Future<BaasApp> _createApp(String name) async {
    print('Creating app $name');

    final dynamic doc = await _post('groups/$_groupId/apps', '{ "name": "$name$_appSuffix" }');
    final appId = doc['_id'] as String;
    final clientAppId = doc['client_app_id'] as String;

    final app = BaasApp(appId, clientAppId, name);

    final confirmFuncId = await _createFunction(app, 'confirmFunc', _confirmFuncSource);
    final resetFuncId = await _createFunction(app, 'resetFunc', _resetFuncSource);

    await enableProvider(app, 'anon-user');
    await enableProvider(app, 'local-userpass', '''{
      "autoConfirm": false,
      "confirmEmailSubject": "",
      "confirmationFunctionName": "confirmFunc",
      "confirmationFunctionId": "$confirmFuncId",
      "emailConfirmationUrl": "http://localhost/confirmEmail",
      "resetFunctionName": "resetFunc",
      "resetFunctionId": "$resetFuncId",
      "resetPasswordSubject": "",
      "resetPasswordUrl": "http://localhost/resetPassword",
      "runConfirmationFunction": true,
      "runResetFunction": true
    }''');

    await _createMongoDBService(app, '''{
      "flexible_sync": {
        "state": "enabled",
        "database_name": "flexible_sync_data",
        "queryable_fields_names": ["TODO"],
        "permissions": {
          "rules": {},
          "defaultRoles": [
            {
              "name": "all",
              "applyWhen": {},
              "read": true,
              "write": true
            }
          ]
        }
      }
    }''');

    await _put('groups/$_groupId/apps/$app/sync/config', '{ "development_mode_enabled": true }');

    return app;
  }

  Future<void> enableProvider(BaasApp app, String type, [String config = '{}']) async {
    print('Enabling provider $type for ${app.name}');

    final url = 'groups/$_groupId/apps/$app/auth_providers';
    if (type == 'api-key') {
      final providers = await _get(url) as List<dynamic>;
      final apiKeyProviderId = providers.singleWhere((dynamic doc) => doc['type'] == 'api-key')['_id'] as String;

      await _put('$url/$apiKeyProviderId/enable', '{}');
    } else {
      await _post(url, '''{
          "name": "$type",
          "type": "$type",
          "disabled": false,
          "config": $config
        }''');
    }
  }

  Future<void> _authenticate(String provider, String credentials) async {
    dynamic response = await _post('auth/providers/$provider/login', credentials);

    _headers['Authorization'] = "Bearer ${response['access_token']}";
  }

  Future<String> _createFunction(BaasApp app, String name, String source) async {
    print('Creating function $name for ${app.name}...');

    final dynamic response = await _post('groups/$_groupId/apps/$app/functions', '''{
        "name": "$name",
        "source": ${jsonEncode(source)},
        "private": false,
        "can_evaluate": {}
      }''');

    return response['_id'] as String;
  }

  Future<String> _createMongoDBService(BaasApp app, String syncConfig) async {
    final serviceName = _clusterName == null ? 'mongodb' : 'mongodb-atlas';
    final mongoConfig = _clusterName == null ? '{ "uri": "mongodb://localhost:26000" }' : '{ "clusterName": "$_clusterName" }';
    final mongoServiceId = await _createService(app, 'BackingDB', serviceName, mongoConfig);

    // The cluster linking must be separated from enabling sync because Atlas
    // takes a few seconds to provision a user for BaaS, meaning enabling sync
    // will fail if we attempt to do it with the same request. It's nondeterministic
    // how long it'll take, so we must retry for a while.
    var attempt = 0;
    while (true) {
      try {
        await _patch('groups/$_groupId/apps/$app/services/$mongoServiceId/config', syncConfig);
        break;
      } catch (err) {
        if (attempt++ < 24) {
          print('Failed to update service after ${attempt * 5} seconds. Will keep retrying ...');

          await Future<dynamic>.delayed(const Duration(seconds: 5));
        } else {
          rethrow;
        }
      }
    }

    return mongoServiceId;
  }

  Future<String> _createService(BaasApp app, String name, String type, String config) async {
    print('Creating service $name for ${app.name}');

    final dynamic response = await _post('groups/$_groupId/apps/$app/services', '''{
        "name": "$name",
        "type": "$type",
        "config": $config
      }''');

    return response['_id'] as String;
  }

  Map<String, String> _getHeaders([Map<String, String>? additionalHeaders]) {
    if (additionalHeaders == null) {
      return _headers;
    }

    additionalHeaders.addAll(_headers);
    return additionalHeaders;
  }

  Uri _getUri(String relativePath) {
    return Uri.parse('$_baseUrl/$relativePath');
  }

  Future<dynamic> _post(String relativePath, String payload) async {
    var response = await http.post(_getUri(relativePath), headers: _getHeaders({'Content-Type': 'application/json'}), body: payload);
    return _decodeResponse(response, payload);
  }

  Future<dynamic> _get(String relativePath) async {
    var response = await http.get(_getUri(relativePath), headers: _getHeaders());
    return _decodeResponse(response);
  }

  Future<dynamic> _put(String relativePath, String payload) async {
    var response = await http.put(_getUri(relativePath), headers: _getHeaders({'Content-Type': 'application/json'}), body: payload);
    return _decodeResponse(response, payload);
  }

  Future<dynamic> _patch(String relativePath, String payload) async {
    var response = await http.patch(_getUri(relativePath), headers: _getHeaders({'Content-Type': 'application/json'}), body: payload);
    return _decodeResponse(response, payload);
  }

  dynamic _decodeResponse(http.Response response, [String? payload]) {
    if (response.statusCode > 399 || response.statusCode < 200) {
      throw Exception('Failed to ${response.request?.method} ${response.request?.url}: ${response.statusCode} ${response.body}. Body: $payload');
    }

    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }
    return jsonDecode(response.body);
  }
}

class BaasApp {
  final String appId;
  final String clientAppId;
  final String name;

  BaasApp(this.appId, this.clientAppId, this.name);

  @override
  String toString() {
    return appId;
  }
}
