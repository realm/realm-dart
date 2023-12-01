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
        abort('--api-key must be supplied when --atlas-cluster is set');
      }

      if (options.privateApiKey == null) {
        abort('--private-api-key must be supplied when --atlas-cluster is set');
      }

      if (options.projectId == null) {
        abort('--project-id must be supplied when --atlas-cluster is set');
      }

      if (options.useBaaSaaS) {
        abort('--use-baas-aas cannot be used when --atlas-cluster is set');
      }
    }

    if (!options.useBaaSaaS && options.baasUrl == null) {
      abort('--baas-url must be supplied when --use-baas-aas is not set');
    }

    late String baasUrl;
    if (options.useBaaSaaS) {
      late String containerId;
      (baasUrl, containerId) = await BaasClient.deployContainer();
      await File('baasurl').writeAsString(baasUrl);
      await File('containerid').writeAsString(containerId);
      print('BaasUrl: $baasUrl');
    } else {
      baasUrl = options.baasUrl!;
    }

    final differentiator = options.differentiator;
    try {
      final client = await (options.atlasCluster == null
          ? BaasClient.docker(baasUrl, differentiator)
          : BaasClient.atlas(baasUrl, options.atlasCluster!, options.apiKey!, options.privateApiKey!, options.projectId!, differentiator));
      client.publicRSAKey = publicRSAKeyForJWTValidation;
      var apps = await client.getOrCreateApps();
      print('App import is complete. There are: ${apps.length} apps on the server:');
      List<String> listApps = [];
      for (var value in apps) {
        print("  App '${value.name}': '${value.clientAppId}'");
        if (value.error != null) {
          print(value.error!);
        }
        listApps.add(value.appId);
      }
      print("appIds: ");
      print(listApps.join(","));
      exit(0);
    } catch (error) {
      print(error);
    }
  }

  void abort(String error) {
    print(error);
    print(usage);
    exit(64); //usage error
  }
}
