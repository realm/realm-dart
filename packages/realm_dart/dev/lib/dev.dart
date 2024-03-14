// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:cli_launcher/cli_launcher.dart';

import 'src/build.dart';

Future<void> main(List<String> arguments, LaunchContext launchContext) async {
  final runner = CommandRunner<int>('dev', 'Helper tool for building realm_dart')
    ..addCommand(BuildNativeCommand())
    ..addCommand(PossibleTargets())
    ..argParser.addFlag('verbose', abbr: 'v', help: 'Print verbose output', defaultsTo: false);
  try {
    final exitCode = await runner.run(arguments);
    io.exit(exitCode ?? 0);
  } on UsageException catch (error) {
    logger.err('$error');
    io.exit(64); // Exit code 64 indicates a usage error.
  }
}
