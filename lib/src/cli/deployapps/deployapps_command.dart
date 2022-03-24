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
  @override
  final String description = 'Deploys test applications to a MongoDB Realm server.';

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

    final client = await (options.atlasCluster == null
        ? BaasClient.docker(options.baasUrl)
        : BaasClient.atlas(options.baasUrl, options.atlasCluster!, options.apiKey!, options.privateApiKey!, options.projectId!));

    final apps = await client.getOrCreateApps();

    print('App import is complete. There are: ${apps.length} apps on the server:');
    apps.forEach((_, value) {
      print("  App '${value.name}': '${value.clientAppId}'");
    });
  }

  void abort(String error) {
    print(error);
    print(usage);
    exit(64); //usage error
  }
}
