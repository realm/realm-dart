// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:build_cli_annotations/build_cli_annotations.dart';
import '../common/target_os_type.dart';

part 'options.g.dart';

@CliOptions()
class Options {
  @CliOption(help: 'The target OS to install binaries for.', abbr: 't')
  TargetOsType? targetOsType;

  // use to debug install command
  @CliOption(hide: true, help: 'Download binary from http://localhost:8000/.', defaultsTo: false)
  bool debug;

  @CliOption(help: 'Force install, even if we would normally skip it.', abbr: 'f', defaultsTo: false)
  bool force;

  Options({this.targetOsType, this.force = false, this.debug = false});
}

String get usage => _$parserForOptions.usage;

ArgParser populateOptionsParser(ArgParser p) => _$populateOptionsParser(p);

Options parseOptionsResult(ArgResults results) => _$parseOptionsResult(results);
