////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
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
  final String _baseUrl;
  final Map<String, String> _headers;

  late String _groupId;

  BaasClient._(String baseUrl)
      : _baseUrl = "$baseUrl/api/admin/v3.0",
        _headers = <String, String>{'Accept': 'application/json'};

  static Future<BaasClient> docker(String baseUrl) async {
    final BaasClient result = BaasClient._(baseUrl);

    await result._authenticate("local-userpass", <String, String>{'username': "unique_user@domain.com", 'password': "password"});

    dynamic groupDoc = await result._get("auth/profile");
    result._groupId = (groupDoc['roles'] as List<dynamic>)[0]['group_id'] as String;

    print("Current GroupID ${result._groupId}");

    return result;
  }

  static Future<BaasClient> atlas(String baseUrl, String cluster, String apiKey, String privateApiKey, String groupId) async {
    final BaasClient result = BaasClient._(baseUrl);

    return result;
  }

  Future<void> _authenticate(String provider, Object credentials) async {
    dynamic response = await _post("auth/providers/$provider/login", credentials);

    _headers['Authorization'] = "Bearer ${response['access_token']}";
  }

  Map<String, String> _getHeaders([Map<String, String>? additionalHeaders]) {
    if (additionalHeaders == null) {
      return _headers;
    }

    additionalHeaders.addAll(_headers);
    return additionalHeaders;
  }

  Uri _getUri(String relativePath) {
    return Uri.parse("$_baseUrl/$relativePath");
  }

  Future<dynamic> _post(String relativePath, Object object) async {
    var response = await http.post(_getUri(relativePath), headers: _getHeaders(<String, String>{'Content-Type': 'application/json'}), body: jsonEncode(object));

    if (response.statusCode > 399 || response.statusCode < 200) {
      throw Exception("Failed to post $relativePath: ${response.statusCode} ${response.body}");
    }

    return jsonDecode(response.body);
  }

  Future<dynamic> _get(String relativePath) async {
    var response = await http.get(_getUri(relativePath), headers: _getHeaders());

    if (response.statusCode > 399 || response.statusCode < 200) {
      throw Exception("Failed to get $relativePath: ${response.statusCode} ${response.body}");
    }

    return jsonDecode(response.body);
  }
}
