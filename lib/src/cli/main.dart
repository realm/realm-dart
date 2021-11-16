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

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import 'generate/generate_command.dart';
import 'install/install_command.dart';
import 'metrics/metrics_command.dart';

void main(List<String> arguments) {
  CommandRunner<void>(
    path.basenameWithoutExtension(Platform.script.path),
    'Tool to help working with the Realm Flutter & Dart SDK',
  )
    ..addCommand(MetricsCommand())
    ..addCommand(GenerateCommand())
    ..addCommand(InstallCommand())
    ..run(arguments).catchError((Object error) {
      if (error is UsageException) {
        print(error);
        exit(64); // Exit code 64 indicates a usage error.
      }
      throw error;
    });
}
