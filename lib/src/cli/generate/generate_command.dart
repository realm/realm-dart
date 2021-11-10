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

class GenerateCommand extends Command<void> {
  @override
  final String description = 'Generate Realm objects from data model classes';

  @override
  final String name = 'generate';

  @override
  FutureOr<void>? run() async {
    // Ensure realm_generator has run (EXPENSIVE!)
    // Not really needed currently, as we don't pick up features yet,
    // but it ensures the realm_generator has been run
    final process = await Process.start('dart', [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ]);
    await stdout.addStream(process.stdout);
  }
}

