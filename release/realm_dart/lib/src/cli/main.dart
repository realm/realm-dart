// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:args/command_runner.dart';

import 'generate/generate_command.dart';
import 'install/install_command.dart';
import 'metrics/metrics_command.dart';
import 'archive/archive_command.dart';
import 'extract/extract_command.dart';
import 'atlas_apps/deployapps_command.dart';
import 'atlas_apps/deleteapps_command.dart';

void main(List<String> arguments) {
  CommandRunner<void>("dart run realm|realm_dart", 'Realm commands for working with Realm Flutter & Dart SDKs.')
    ..addCommand(MetricsCommand())
    ..addCommand(GenerateCommand())
    ..addCommand(InstallCommand())
    ..addCommand(ArchiveCommand())
    ..addCommand(ExtractCommand())
    ..addCommand(DeployAppsCommand())
    ..addCommand(DeleteAppsCommand())
    ..run(arguments).catchError((Object error) {
      if (error is UsageException) {
        print(error);
        exit(64); // Exit code 64 indicates a usage error.
      }
      throw error;
    });
}
