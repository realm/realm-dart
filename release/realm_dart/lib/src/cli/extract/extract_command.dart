// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import 'options.dart';
import '../common/archive.dart';

class ExtractCommand extends Command<void> {
  @override
  final String description = 'Extract Realm binaries from an archive. Internal command used when downloading Realm binaries on build.';

  @override
  final String name = 'extract';

  @override
  bool get hidden => true;

  late Options options;

  ExtractCommand() {
    populateOptionsParser(argParser);
  }

  @override
  FutureOr<void>? run() async {
    options = parseOptionsResult(argResults!);
    if (options.sourceFile == null) {
      abort("source-file option not specified");
    }

    if (options.outputDir == null) {
      abort("output-dir option not specified");
    }

    final archive = Archive();
    archive.extract(File(options.sourceFile!), Directory(options.outputDir!));
  }

  void abort(String error) {
    print(error);
    print(usage);
    exit(64); //usage error
  }
}
