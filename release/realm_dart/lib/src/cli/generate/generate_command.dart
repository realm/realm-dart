// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

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
      options.clean
          ? 'clean'
          : options.watch
              ? 'watch'
              : 'build',
      ...[if (!options.clean) '--delete-conflicting-outputs'], // not legal option to clean
    ]);

    await stdout.addStream(process.stdout);
    final exitCode = await process.exitCode;
    exit(exitCode);
  }
}
