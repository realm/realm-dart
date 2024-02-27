////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
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
import '../common/target_os_type.dart';

part 'options.g.dart';

@CliOptions()
class Options {
  @CliOption(help: 'The target OS to install binaries for.', abbr: 't')
  TargetOsType? targetOsType;

  // use to debug install command
  @CliOption(hide: true, help: 'Download binary from http://localhost:8000/.', defaultsTo: false)
  bool debug;

  @CliOption(hide: true, help: 'Force install, even if we would normally skip it.', defaultsTo: false)
  bool force;

  Options({this.targetOsType, this.force = false, this.debug = false});
}

String get usage => _$parserForOptions.usage;

ArgParser populateOptionsParser(ArgParser p) => _$populateOptionsParser(p);

Options parseOptionsResult(ArgResults results) => _$parseOptionsResult(results);
