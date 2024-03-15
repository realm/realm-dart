// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:build_cli_annotations/build_cli_annotations.dart';
import 'package:path/path.dart' as path;
import '../common/target_os_type.dart';

part 'options.g.dart';

@CliOptions()
class Options {
  @CliOption(help: "The OS type this project is targeting.")
  final TargetOsType? targetOsType;
  @CliOption(help: "The OS version this project is targeting.")
  final String? targetOsVersion;
  @CliOption(help: "The path to the Flutter SDK (excluding the bin directory).")
  final String? flutterRoot;
  @CliOption(help: "The path to the application pubspec")
  final String pubspecPath;

  @CliOption(abbr: 'v', help: 'Show additional command output.')
  bool verbose = false;

  Options({this.targetOsType, this.targetOsVersion, this.flutterRoot, String? pubspecPath})
      : pubspecPath = path.join(path.current, pubspecPath ?? 'pubspec.yaml');
}

String get usage => _$parserForOptions.usage;

ArgParser populateOptionsParser(ArgParser p) => _$populateOptionsParser(p);

Options parseOptionsResult(ArgResults results) => _$parseOptionsResult(results);
