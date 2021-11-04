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
    }).then((_) => exit(0));
}
