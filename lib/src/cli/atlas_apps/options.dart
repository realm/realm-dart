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

import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'options.g.dart';

@CliOptions()
class Options {
  @CliOption(help: 'Url for MongoDB Atlas.', defaultsTo: 'http://localhost:9090')
  final String baasUrl;

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

  Options(this.baasUrl, {this.atlasCluster, this.apiKey, this.privateApiKey, this.projectId, this.differentiator});
}

String get usage => _$parserForOptions.usage;

ArgParser populateOptionsParser(ArgParser p) => _$populateOptionsParser(p);

Options parseOptionsResult(ArgResults results) => _$parseOptionsResult(results);
