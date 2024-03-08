// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:dev/dev.dart' as dev;
import 'package:cli_launcher/cli_launcher.dart';
Future<void> main(List<String> arguments) async => launchExecutable(
      arguments,
      LaunchConfig(
        name: ExecutableName('dev'),
        entrypoint: dev.main,
      ),
    );