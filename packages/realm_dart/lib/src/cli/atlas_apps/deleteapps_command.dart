// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

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

    if (options.baasaasApiKey == null && options.baasUrl == null) {
      abort('--baas-url must be supplied when --baasaas-api-key is null');
    }

    final differentiator = options.differentiator ?? 'local';

    if (options.baasaasApiKey != null) {
      await BaasClient.retry(() => BaasClient.deleteContainer(options.baasaasApiKey!, differentiator));
    } else {
      final client = await (options.atlasCluster == null
          ? BaasClient.docker(options.baasUrl!, differentiator)
          : BaasClient.atlas(options.baasUrl!, options.atlasCluster!, options.apiKey!, options.privateApiKey!, options.projectId!, differentiator));

      await client.deleteApps();
    }
  }

  void abort(String error) {
    print(error);
    print(usage);
    exit(64); //usage error
  }
}
