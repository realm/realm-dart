// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:build_cli_annotations/build_cli_annotations.dart';
import '../common/target_os_type.dart';

part 'options.g.dart';

@CliOptions()
class Options {
  @CliOption(help: 'The flavor to install binaries for.', abbr: 'f', provideDefaultToOverride: true)
  Flavor? flavor;

  @CliOption(help: 'The target OS to install binaries for.', abbr: 't', provideDefaultToOverride: true)
  TargetOsType? targetOsType;

  // use to debug install command
  @CliOption(hide: true, help: 'Download binary from http://localhost:8000/.', defaultsTo: false)
  bool debug;

  @CliOption(hide: true, help: 'Force install, even if we would normally skip it.', defaultsTo: false)
  bool force;

  Options({this.targetOsType, this.force = false, this.debug = false});
}

String get usage => _$parserForOptions.usage;

ArgParser populateOptionsParser(
  ArgParser parser, {
  TargetOsType? targetOsTypeDefaultOverride,
  Flavor? flavorDefaultOverride,
}) =>
    _$populateOptionsParser(parser, targetOsTypeDefaultOverride: targetOsTypeDefaultOverride, flavorDefaultOverride: flavorDefaultOverride);

Options parseOptionsResult(ArgResults results) => _$parseOptionsResult(results);
