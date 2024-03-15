// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'options.g.dart';

@CliOptions()
class Options {
  @CliOption(help: "This option is required")
  final String? outputDir;
  @CliOption(help: "This option is required")
  final String? sourceFile;

  Options({this.sourceFile, this.outputDir});
}

String get usage => _$parserForOptions.usage;

ArgParser populateOptionsParser(ArgParser p) => _$populateOptionsParser(p);

Options parseOptionsResult(ArgResults results) => _$parseOptionsResult(results);
