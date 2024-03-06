// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'options.g.dart';

@CliOptions()
class Options {
  @CliOption(help: 'Url for MongoDB Atlas.')
  final String? baasUrl;

  @CliOption(help: 'The database prefix that will be used for the sync service.')
  final String? differentiator;

  @CliOption(help: 'Atlas Cluster to link in the application.')
  final String? atlasCluster;

  @CliOption(help: 'Atlas API key to use for the import. Only used if atlas-cluster is specified.')
  final String? apiKey;

  @CliOption(help: 'The private Atlas API key to use for the import. Only used if atlas-cluster is specified.')
  final String? privateApiKey;

  @CliOption(help: 'The Atlas project id to use for the import. Only used if atlas-cluster is specified.')
  final String? projectId;

  @CliOption(help: 'API key to use with BaaSaaS to spawn a new container and create apps in it.', name: 'baasaas-api-key')
  final String? baasaasApiKey;

  Options({this.baasUrl, this.atlasCluster, this.apiKey, this.privateApiKey, this.projectId, this.differentiator, this.baasaasApiKey});
}

String get usage => _$parserForOptions.usage;

ArgParser populateOptionsParser(ArgParser p) => _$populateOptionsParser(p);

Options parseOptionsResult(ArgResults results) => _$parseOptionsResult(results);
