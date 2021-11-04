import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

class GenerateCommand extends Command<void> {
  @override
  final String description = 'Generate realm model objects from prototypes';

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

