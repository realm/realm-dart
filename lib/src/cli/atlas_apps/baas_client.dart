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

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BaasAuthHelper {
  static const String _appId = 'baas-container-service-autzb';
  final String _apiKey;
  final String _location;

  BaasAuthHelper(this._apiKey) : _location = 'https://us-east-1.aws.data.mongodb-api.com';

  Future<dynamic> callEndpoint(String name, {Object? body, Map<String, String>? query, bool isPost = true}) async {
    var url = '$_location/app/$_appId/endpoint/$name';
    if (query != null) {
      url = '$url?${query.entries.map((kvp) => '${kvp.key}=${kvp.value}').join('&')}';
    }
    final headers = {'apiKey': _apiKey};
    final response = isPost ? await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body)) : await http.get(Uri.parse(url), headers: headers);

    return BaasClient._decodeResponse(response);
  }

  Future<String> getUserId() async {
    final response = await callEndpoint('userinfo', isPost: false) as Map<String, dynamic>;
    return response['id'] as String;
  }
}

class BaasClient {
  static const String _confirmFuncSource = '''exports = async ({ token, tokenId, username }) => {
    // process the confirm token, tokenId and username
    if (username.includes("realm_tests_do_autoverify")) {
      return { status: 'success' }
    }
    else if (username.includes("realm_tests_pending_confirm")) {
      const mdb = context.services.get("BackingDB");
      const collection = mdb.db("custom-auth").collection("users");
      const existing = await collection.findOne({ username: username });
      if (existing) {
          return { status: 'success' };
      }

      await collection.insertOne({ username: username });
      return { status: 'pending' }
    }
    else
    {
      // do not confirm the user
      return { status: 'fail' };
    }
  };''';

  static const String _resetFuncSource = '''exports = ({ token, tokenId, username, password }, status) => {
    // process the reset token, tokenId, username and password
    if (status && status !== "") {
      return { status: status };
    }
    else
    {
      return { status: 'fail' };
    }
  };''';

  static const String _authFuncSource = '''exports = (loginPayload) => {
    return loginPayload["userId"];
  };''';

  static const String _userFuncNoArgs = '''exports = function(){
    return {};
  };''';

  static const String _userFuncOneArg = '''exports = function(arg){
    return {'arg': arg };
  };''';

  static const String _userFuncTwoArgs = '''exports = function(arg1, arg2){
    return { 'arg1': arg1, 'arg2': arg2};
  };''';

  static const String _triggerClientResetFuncSource = '''exports = async function(userId, appId) {
    const mongodb = context.services.get('BackingDB');
    console.log('user.id: ' + context.user.id);
    try {
      const dbName = `__realm_sync_\${appId}`;
      const deletionResult = await mongodb.db(dbName).collection('clientfiles').deleteMany({ ownerId: userId });
      console.log('Deleted documents: ' + deletionResult.deletedCount);

      return { status: deletionResult.deletedCount > 0 ? 'success' : 'failure' };
    } catch(err) {
      throw 'Deletion failed: ' + err;
    }
  };''';

  static const String defaultAppName = "flexible";

  final String _adminApiUrl;
  final String? _clusterName;
  final Map<String, String> _headers;
  final String _appSuffix;

  final String baseUrl;

  late String _groupId;
  late String publicRSAKey = '';

  BaasClient._(this.baseUrl, String differentiator, [this._clusterName])
      : _adminApiUrl = '$baseUrl/api/admin/v3.0',
        _headers = <String, String>{'Accept': 'application/json'},
        _appSuffix = '-${shortenDifferentiator(differentiator)}${_clusterName == null ? '' : '-$_clusterName'}';

  /// A client that imports apps in a MongoDB Atlas docker image. See https://github.com/realm/ci/tree/master/realm/docker/mongodb-realm
  /// for instructions on how to set it up.
  /// @nodoc
  static Future<BaasClient> docker(String baseUrl, String differentiator) async {
    final result = BaasClient._(baseUrl, differentiator);

    await result._authenticate('local-userpass', '{ "username": "unique_user@domain.com", "password": "password" }');

    dynamic groupDoc = await result._get('auth/profile');
    result._groupId = groupDoc['roles'][0]['group_id'] as String;

    print('Current GroupID ${result._groupId}');

    return result;
  }

  static Future<void> deleteContainer(String apiKey, String differentiator) async {
    try {
      print('Stopping all containers with differentiator $differentiator');
      final authHelper = BaasAuthHelper(apiKey);
      final containers = await _getContainers(authHelper, differentiator: differentiator);
      for (final container in containers) {
        print('Stopping container ${container.id}');
        await authHelper.callEndpoint('stopContainer', query: {'id': container.id});
        print('Stopped container ${container.id}');
      }
      return;
    } catch (e) {
      print('Failed to destroy container: $e');
      rethrow;
    }
  }

  static Future<(String httpUrl, String containerId)> getOrDeployContainer(String apiKey, String differentiator) async {
    final authHelper = BaasAuthHelper(apiKey);
    final existing = (await _getContainers(authHelper, differentiator: differentiator)).firstOrNull;
    if (existing != null) {
      print('Using existing BaaS container at ${existing.httpUrl}');
      return (existing.httpUrl, existing.id);
    }

    print('Deploying new BaaS container... ');
    final response = await authHelper.callEndpoint('startContainer', body: [
      {'key': 'DIFFERENTIATOR', 'value': differentiator}
    ]) as Map<String, dynamic>;
    final id = response['id'] as String;

    String? httpUrl;
    while (httpUrl == null) {
      await Future.delayed(Duration(seconds: 1));
      httpUrl = await _waitForContainer(authHelper, id);
    }

    print('Deployed BaaS instance at $httpUrl');

    return (httpUrl, id);
  }

  static Future<T> retry<T>(Future<T> Function() func, {int attempts = 5}) async {
    while (attempts >= 0) {
      try {
        return await func();
      } catch (e) {
        print('An error occurred: $e');
        if (--attempts == 0) {
          rethrow;
        }
      }
    }

    throw 'UNREACHABLE';
  }

  static Future<List<_ContainerInfo>> _getContainers(BaasAuthHelper helper, {String? differentiator}) async {
    var result = (await helper.callEndpoint('listContainers', isPost: false) as List<dynamic>).map((e) => _ContainerInfo.fromJson(e)).whereNotNull();
    if (differentiator != null) {
      final userId = await helper.getUserId();
      result = result.where((c) => c.creatorId == userId && c.tags['DIFFERENTIATOR'] == differentiator);
    }

    return result.toList();
  }

  static Future<String?> _waitForContainer(BaasAuthHelper authHelper, String taskId) async {
    try {
      final containers = await _getContainers(authHelper);
      final targetContainer = containers.firstWhereOrNull((c) => c.id == taskId);
      if (targetContainer == null) {
        print('$taskId is not found in container list. Retrying...');
        return null;
      }

      if (!targetContainer.isRunning) {
        print('$taskId status is ${targetContainer.lastStatus}. Retrying...');
        return null;
      }

      final httpUrl = targetContainer.httpUrl;

      final response = await http.get(Uri.parse('$httpUrl/api/private/v1.0/version'));
      if (response.statusCode > 300) {
        print('$taskId version response is ${response.statusCode}. Retrying...');
        return null;
      }

      return httpUrl;
    } catch (e) {
      print('Error waiting for container: $e');
      return null;
    }
  }

  /// A client that imports apps to a MongoDB Atlas environment (typically realm-dev or realm-qa).
  /// @nodoc
  static Future<BaasClient> atlas(String baseUrl, String cluster, String apiKey, String privateApiKey, String groupId, String differentiator) async {
    final BaasClient result = BaasClient._(baseUrl, differentiator, cluster);

    await result._authenticate('mongodb-cloud', '{ "username": "$apiKey", "apiKey": "$privateApiKey" }');

    result._groupId = groupId;

    return result;
  }

  /// Tries to look up the applications for the specified cluster. For [docker] client, returns all apps,
  /// for [atlas] one, it will return only apps with suffix equal to the cluster name. If no apps exist,
  /// then it will create the test applications and return them.
  /// @nodoc
  Future<List<BaasApp>> getOrCreateApps() async {
    var apps = await _getApps();
    await _createAppIfNotExists(apps, defaultAppName, _appSuffix);
    await _createAppIfNotExists(apps, "autoConfirm", _appSuffix, confirmationType: "auto");
    await _createAppIfNotExists(apps, "emailConfirm", _appSuffix, confirmationType: "email");
    return apps;
  }

  Future<void> waitForInitialSync(BaasApp app) async {
    while (!await _isSyncComplete(app.appId)) {
      print('Initial sync for ${app.name} is incomplete. Waiting 5 seconds.');
      await Future.delayed(Duration(seconds: 5));
    }

    print('Initial sync for ${app.name} is complete.');
  }

  Future<void> _createAppIfNotExists(List<BaasApp> existingApps, String appName, String appSuffix, {String? confirmationType}) async {
    final existingApp = existingApps.firstWhereOrNull((a) => a.name == appName);
    if (existingApp == null) {
      existingApps.add(await _createApp(appName, appSuffix, confirmationType: confirmationType));
    }
  }

  Future<bool> _isSyncComplete(String appId) async {
    try {
      final response = await _get('groups/$_groupId/apps/$appId/sync/progress');

      Map<String, dynamic> progressInfo = response['progress'];
      for (final key in progressInfo.keys) {
        final namespaceComplete = progressInfo[key]['complete'] as bool;

        if (!namespaceComplete) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<BaasApp>> _getApps() async {
    final apps = await _get('groups/$_groupId/apps') as List<dynamic>;
    return apps
        .map((dynamic doc) {
          final name = doc['name'] as String;
          final String appName;
          if (name.endsWith(_appSuffix)) {
            appName = name.substring(0, name.length - _appSuffix.length);
          } else {
            return null;
          }
          return BaasApp(appId: doc['_id'] as String, clientAppId: doc['client_app_id'] as String, name: appName, uniqueName: name, isNewDeployment: false);
        })
        .where((doc) => doc != null)
        .map((doc) => doc!)
        .toList();
  }

  Future<void> updateAppConfirmFunction(String name, [String? source]) async {
    final uniqueName = "$name$_appSuffix";
    final dynamic docs = await _get('groups/$_groupId/apps');
    dynamic doc = docs.firstWhere((dynamic d) {
      return d["name"] == uniqueName;
    }, orElse: () => throw Exception("BAAS app not found"));
    final appId = doc['_id'] as String;
    final appUniqueName = doc['name'] as String;
    final clientAppId = doc['client_app_id'] as String;
    final app = BaasApp(appId: appId, clientAppId: clientAppId, name: name, uniqueName: appUniqueName, isNewDeployment: false);

    final dynamic functions = await _get('groups/$_groupId/apps/$appId/functions');
    dynamic function = functions.firstWhere((dynamic f) => f["name"] == "confirmFunc", orElse: () => throw Exception("Func 'confirmFunc' not found"));
    final confirmFuncId = function['_id'] as String;

    await _updateFunction(app, 'confirmFunc', confirmFuncId, source ?? _confirmFuncSource);
  }

  Future<BaasApp> _createApp(String name, String suffix, {String? confirmationType}) async {
    final uniqueName = "$name$suffix";
    print('Creating app $uniqueName');

    BaasApp? app;
    try {
      final dynamic doc = await _post('groups/$_groupId/apps', '{ "name": "$uniqueName" }');

      app = BaasApp(appId: doc['_id'] as String, clientAppId: doc['client_app_id'] as String, name: name, uniqueName: uniqueName, isNewDeployment: true);

      final confirmFuncId = await _createFunction(app, 'confirmFunc', _confirmFuncSource);
      final resetFuncId = await _createFunction(app, 'resetFunc', _resetFuncSource);
      final authFuncId = await _createFunction(app, 'authFunc', _authFuncSource);
      await _createFunction(app, 'userFuncNoArgs', _userFuncNoArgs);
      await _createFunction(app, 'userFuncOneArg', _userFuncOneArg);
      await _createFunction(app, 'userFuncTwoArgs', _userFuncTwoArgs);
      await _createFunction(app, 'triggerClientResetOnSyncServer', _triggerClientResetFuncSource, runAsSystem: true);

      await enableProvider(app, 'anon-user');
      await enableProvider(app, 'local-userpass', config: '''{
        "autoConfirm": ${(confirmationType == "auto").toString()},
        "confirmEmailSubject": "Confirmation required",
        "confirmationFunctionName": "confirmFunc",
        "confirmationFunctionId": "$confirmFuncId",
        "emailConfirmationUrl": "http://localhost/confirmEmail",
        "resetFunctionName": "resetFunc",
        "resetFunctionId": "$resetFuncId",
        "resetPasswordSubject": "",
        "resetPasswordUrl": "http://localhost/resetPassword",
        "runConfirmationFunction": ${(confirmationType != "email" && confirmationType != "auto").toString()},
        "runResetFunction": true
      }''');

      await enableProvider(app, 'api-key');

      if (publicRSAKey.isNotEmpty) {
        String publicRSAKeyEncoded = jsonEncode(publicRSAKey);
        final dynamic createSecretResult = await _post('groups/$_groupId/apps/$app/secrets', '{"name":"rsPublicKey","value":$publicRSAKeyEncoded}');
        String keyName = createSecretResult['name'] as String;

        await enableProvider(app, 'custom-token', config: '''{
          "audience": "mongodb.com",
          "signingAlgorithm": "RS256",
          "useJWKURI": false
            }''', secretConfig: '''{
          "signingKeys": ["$keyName"]
          }''', metadataFelds: '''{
            "required": false,
            "name": "name.firstName",
            "field_name": "firstName"
          },
          {
            "required": false,
            "name": "name.lastName",
            "field_name": "lastName"
          },
          {
            "required": true,
            "name": "email",
            "field_name": "name"
          },
          {
            "required": true,
            "name": "email",
            "field_name": "email"
          },
          {
            "required": false,
            "name": "gender",
            "field_name": "gender"
          },
          {
            "required": false,
            "name": "birthDay",
            "field_name": "birthDay"
          },
          {
            "required": false,
            "name": "minAge",
            "field_name": "minAge"
          },
          {
            "required": false,
            "name": "maxAge",
            "field_name": "maxAge"
          },
          {
            "required": false,
            "name": "company",
            "field_name": "company"
          }''');
      }

      if (confirmationType == null) {
        await enableProvider(app, 'custom-function', config: '''{
            "authFunctionName": "authFunc",
            "authFunctionId": "$authFuncId"
            }''');

        const facebookSecret = "876750ac6d06618b323dee591602897f";
        final dynamic createFacebookSecretResult = await _post('groups/$_groupId/apps/$app/secrets', '{"name":"facebookSecret","value":"$facebookSecret"}');
        String facebookClientSecretKeyName = createFacebookSecretResult['name'] as String;
        await enableProvider(app, 'oauth2-facebook', config: '''{
          "clientId": "1265617494254819"
          }''', secretConfig: '''{
          "clientSecret": "$facebookClientSecretKeyName"
          }''', metadataFelds: '''{
            "required": true,
            "name": "name"
          },
          {
            "required": true,
            "name": "first_name"
          },
          {
            "required": true,
            "name": "last_name"
          },
          {
            "required": false,
            "name": "email"
          },
          {
            "required": false,
            "name": "gender"
          },
          {
            "required": false,
            "name": "birthday"
          },
          {
            "required": false,
            "name": "min_age"
          },
          {
            "required": false,
            "name": "max_age"
          },
          {
            "required": false,
            "name": "picture"
          }''');
      }

      print('Creating database db_$uniqueName');

      await _createMongoDBService(
        app,
        syncConfig: '''{
        "flexible_sync": {
          "state": "enabled",
          "database_name": "db_$uniqueName",
          "queryable_fields_names": ["differentiator", "stringQueryField", "boolQueryField", "intQueryField"]
        }
      }''',
        rules: '''{
        "roles": [
          {
            "name": "all",
            "apply_when": {},
            "document_filters": {
              "read": true,
              "write": true
            },
            "read": true,
            "write": true,
            "insert": true,
            "delete": true,
            "search": true
          }
        ]
      }''',
      );
      await _put('groups/$_groupId/apps/$app/sync/config', '{ "development_mode_enabled": true }');

      //create email/password user for tests
      final dynamic createUserResult = await _post('groups/$_groupId/apps/$app/users', '{"email": "realm-test@realm.io", "password":"123456"}');
      print("Create user result: $createUserResult");
    } catch (error) {
      print(error);
      app ??= BaasApp._empty(name);
      app.error = error;
    }
    return app;
  }

  Future<void> enableProvider(BaasApp app, String type, {String config = '{}', String secretConfig = '{}', String metadataFelds = '{}'}) async {
    print('Enabling provider $type for ${app.clientAppId}');

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
          "config": $config,
          "secret_config": $secretConfig,
          "metadata_fields": [$metadataFelds]
        }''');
    }
  }

  Future<void> deleteApps() async {
    var apps = await _getApps();
    for (final app in apps) {
      print('Deleting app ${app.clientAppId}');

      await _deleteApp(app.appId);
      print("App with id='${app.appId}' is deleted.");
    }
  }

  Future<String> createApiKey(String appId, String name, bool enabled) async {
    final dynamic result = await _post('groups/$_groupId/apps/$appId/api_keys', '{ "name":"$name" }');
    if (!enabled) {
      await _put('groups/$_groupId/apps/$appId/api_keys/${result['_id']}/disable', '');
    }

    return result['key'] as String;
  }

  Future<void> _authenticate(String provider, String credentials) async {
    dynamic response = await _post('auth/providers/$provider/login', credentials);

    _headers['Authorization'] = "Bearer ${response['access_token']}";
  }

  Future<String> _createFunction(BaasApp app, String name, String source, {bool runAsSystem = false}) async {
    print('Creating function $name for ${app.clientAppId}...');

    final dynamic response = await _post('groups/$_groupId/apps/$app/functions', '''{
        "name": "$name",
        "source": ${jsonEncode(source)},
        "private": false,
        "can_evaluate": {},
        "run_as_system": $runAsSystem
      }''');

    return response['_id'] as String;
  }

  Future<void> _updateFunction(BaasApp app, String name, String functionId, String source) async {
    print('Updating function $name for ${app.clientAppId}...');

    await _put('groups/$_groupId/apps/$app/functions/$functionId', '''{
        "name": "$name",
        "source": ${jsonEncode(source)},
        "private": false,
        "can_evaluate": {}
      }''');
  }

  Future<String> _createMongoDBService(BaasApp app, {required String syncConfig, required String rules}) async {
    final serviceName = _clusterName == null ? 'mongodb' : 'mongodb-atlas';
    final mongoConfig = _clusterName == null ? '{ "uri": "mongodb://localhost:26000" }' : '{ "clusterName": "$_clusterName" }';
    final mongoServiceId = await _createService(app, 'BackingDB', serviceName, mongoConfig);

    await _post('groups/$_groupId/apps/$app/services/$mongoServiceId/default_rule', rules);

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
    print('Creating service $name for ${app.clientAppId}');

    final dynamic response = await _post('groups/$_groupId/apps/$app/services', '''{
        "name": "$name",
        "type": "$type",
        "config": $config
      }''');

    return response['_id'] as String;
  }

  Future<void> _deleteApp(String appId) async {
    await _delete('groups/$_groupId/apps/$appId');
  }

  Map<String, String> _getHeaders([Map<String, String>? additionalHeaders]) {
    if (additionalHeaders == null) {
      return _headers;
    }

    additionalHeaders.addAll(_headers);
    return additionalHeaders;
  }

  Uri _getUri(String relativePath) {
    return Uri.parse('$_adminApiUrl/$relativePath');
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

  Future<dynamic> _delete(String relativePath, {String? payload}) async {
    var response = await http.delete(_getUri(relativePath), headers: _getHeaders({'Content-Type': 'application/json'}), body: payload);
    return _decodeResponse(response, payload);
  }

  static dynamic _decodeResponse(http.Response response, [String? payload]) {
    if (response.statusCode > 399 || response.statusCode < 200) {
      throw Exception('Failed to ${response.request?.method} ${response.request?.url}: ${response.statusCode} ${response.body}. Body: $payload');
    }

    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }
    return jsonDecode(response.body);
  }

  static String shortenDifferentiator(String input) {
    if (input.length < 8) {
      return input;
    }
    //Take first 4 and last 4 symbols
    final result = input.replaceRange(4, input.length - 4, '');
    return result;
  }

  Future<void> setAutomaticRecoveryEnabled(String name, bool enable) async {
    final uniqueName = "$name$_appSuffix";
    final dynamic docs = await _get('groups/$_groupId/apps');
    dynamic doc = docs.firstWhere((dynamic d) {
      return d["name"] == uniqueName;
    }, orElse: () => throw Exception("BAAS app not found"));
    final app = BaasApp(
        appId: doc['_id'] as String, clientAppId: doc['client_app_id'] as String, name: name, uniqueName: doc['name'] as String, isNewDeployment: false);

    final dynamic services = await _get('groups/$_groupId/apps/$app/services');
    dynamic service = services.firstWhere((dynamic s) => s["name"] == "BackingDB", orElse: () => throw Exception("Func 'confirmFunc' not found"));
    final mongoServiceId = service['_id'] as String;
    final dynamic configDocs = await _get('groups/$_groupId/apps/$app/services/$mongoServiceId/config');
    final dynamic flexibleSync = configDocs['flexible_sync'];
    final dynamic clusterName = configDocs['clusterName'];
    flexibleSync["is_recovery_mode_disabled"] = !enable;
    String data = jsonEncode(<String, dynamic>{
      if (clusterName != null) 'clusterName': clusterName,
      'flexible_sync': flexibleSync,
    });
    await _patch('groups/$_groupId/apps/$app/services/$mongoServiceId/config', data);
  }
}

class _ContainerInfo {
  final String id;
  bool get isRunning => lastStatus == 'RUNNING';
  final String httpUrl;
  final String lastStatus;
  final Map<String, String> tags;
  final String creatorId;

  _ContainerInfo._(this.id, this.httpUrl, this.lastStatus, this.tags, this.creatorId);

  static _ContainerInfo? fromJson(Map<String, dynamic> json) {
    final httpUrl = json['httpUrl'] as String?;
    if (httpUrl == null) {
      return null;
    }

    final id = json['id'] as String;
    final lastStatus = json['lastStatus'];
    final tags = {for (var v in json['tags'] as List<dynamic>) v['key'] as String: v['value'] as String};
    final creatorId = json['creatorId'] as String;

    return _ContainerInfo._(id, httpUrl, lastStatus, tags, creatorId);
  }
}

class BaasApp {
  final String appId;
  final String clientAppId;
  final String name;
  final String uniqueName;
  final bool isNewDeployment;
  Object? error;

  BaasApp({required this.appId, required this.clientAppId, required this.name, required this.uniqueName, required this.isNewDeployment});

  BaasApp._empty(this.name)
      : appId = "",
        clientAppId = "",
        uniqueName = "",
        isNewDeployment = false;

  @override
  String toString() {
    return appId;
  }
}
