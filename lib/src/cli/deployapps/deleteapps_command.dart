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

class DeleteAppsCommand extends Command<void> {
  @override
  final String description = 'Delete test applications from MongoDB Atlas.';

  @override
  final String name = 'delete-apps';

  @override
  bool get hidden => true;
  late Options options;

  DeleteAppsCommand() {
    populateOptionsParser(argParser);
  }

  @override
  FutureOr<void>? run() async {
    options = parseOptionsResult(argResults!);

    if (options.appIds == null) {
      abort('--appIds must be supplied');
    }
    List<String> appIds = (options.appIds!).split(',');

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

    final differentiator = options.differentiator ?? 'local';

    final client = await (options.atlasCluster == null
        ? BaasClient.docker(options.baasUrl, differentiator)
        : BaasClient.atlas(options.baasUrl, options.atlasCluster!, options.apiKey!, options.privateApiKey!, options.projectId!, differentiator));

    appIds.forEach((appId) async {
      await client.deleteApp(appId);
      print("  App '$appId' is deleted.");
    });
  }

  void abort(String error) {
    print(error);
    print(usage);
    exit(64); //usage error
  }
}
