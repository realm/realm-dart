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
    argParser.addOption('appIds', help: 'List of deployed apps MongoDB Atlas.');
  }

  @override
  FutureOr<void>? run() async {
    List<String> appIds = (argResults!['appIds'] as String).split(',');

    if (appIds.length > 0) {
      final client = await (options.atlasCluster == null
          ? BaasClient.docker(options.baasUrl, null)
          : BaasClient.atlas(options.baasUrl, options.atlasCluster!, options.apiKey!, options.privateApiKey!, options.projectId!, null));
      appIds.forEach((appId) async {
        await client.deleteApp(appId);
        print("  App '${appId}' is deleted.");
      });
    }
  }

  void abort(String error) {
    print(error);
    print(usage);
    exit(64); //usage error
  }
}
