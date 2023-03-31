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

import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import 'options.dart';
import 'baas_client.dart';

class DeployAppsCommand extends Command<void> {
  final String publicRSAKeyForJWTValidation = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvNHHs8T0AHD7SJ+CKvVR
leeJa4wqYTnaVYV+5bX9FmFXVoN+vHbMLEteMvSw4L3kSRZdcqxY7cTuhlpAvkXP
Yq6qSI+bW8T4jGW963uCc83UhVMx4MH/PzipAlfcPjVO2u4c+dmpgZQpgEmA467u
tauXUhmTsGpgNg2Gvc61B7Ny4LphshsyrfaJ9WjA/NM6LOmEBW3JPNcVG2qyU+gt
O8BM8KOSx9wGyoGs4+OusvRkJizhPaIwa3FInLs4r+xZW9Bp6RndsmVECtvXRv5d
87ztpg6o3DZJRmTp2lAnkNLmxXlFkOSNIwiT3qqyRZOh4DuxPOpfg9K+vtFmRdEJ
RwIDAQAB
-----END PUBLIC KEY-----''';

  @override
  final String description = 'Deploys test applications to MongoDB Atlas.';

  @override
  final String name = 'deploy-apps';

  @override
  bool get hidden => true;

  late Options options;

  DeployAppsCommand() {
    populateOptionsParser(argParser);
  }

  @override
  FutureOr<void>? run() async {
    options = parseOptionsResult(argResults!);

    if (options.atlasCluster != null) {
      if (options.apiKey == null) {
        abort('--api-key must be supplied when --atlas-cluster is not set');
      }

      if (options.privateApiKey == null) {
        abort('--private-api-key must be supplied when --atlas-cluster is not set');
      }

      if (options.projectId == null) {
        abort('--project-id must be supplied when --atlas-cluster is not set');
      }
    }

    final differentiator = options.differentiator ?? 'shared';

    final sharedClient = await (options.atlasCluster == null
        ? BaasClient.docker(options.baasUrl, differentiator)
        : BaasClient.atlas(options.baasUrl, options.atlasCluster!, options.apiKey!, options.privateApiKey!, options.projectId!, differentiator));
    var apps = await sharedClient.getExistingApps();
    sharedClient.publicRSAKey = publicRSAKeyForJWTValidation;

    await sharedClient.createAppIfNotExists(apps, "autoConfirm", confirmationType: "auto");
    await sharedClient.createAppIfNotExists(apps, "emailConfirm", confirmationType: "email");

    print('App import is complete. There are: ${apps.length} apps on the server:');
    List<String> listApps = [];
    apps.forEach((_, value) {
      print("  App '${value.name}': '${value.clientAppId}'");
      if (value.error != null) {
        throw value.error!;
      }
      listApps.add(value.appId);
    });
    print("appIds: ");
    print(listApps.join(","));
  }

  void abort(String error) {
    print(error);
    print(usage);
    exit(64); //usage error
  }
}
