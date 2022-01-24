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

import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import 'options.dart';

class GenerateCommand extends Command<void> {
  @override
  final String description = 'Generate Realm objects from data model classes';

  @override
  final String name = 'generate';

  GenerateCommand() {
    populateOptionsParser(argParser);
  }

  @override
  FutureOr<void>? run() async {
    final options = parseOptionsResult(argResults!);

    final process = await Process.start('dart', [
      'run',
      'build_runner',
      // prioritize clean, then watch, then build
      options.clean ? 'clean' : options.watch ? 'watch' : 'build',
      ...[if (!options.clean) '--delete-conflicting-outputs'], // not legal option to clean
    ]);
    
    await stdout.addStream(process.stdout);
  }
}
