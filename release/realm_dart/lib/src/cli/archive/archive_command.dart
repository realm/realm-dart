// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import 'options.dart';
import '../common/archive.dart';

class ArchiveCommand extends Command<void> {
  @override
  final String description = 'Archive Realm binaries. Internal command used to prepare the Realm binary archives for download';

  @override
  final String name = 'archive';

  @override
  bool get hidden => true;

  late Options options;

  ArchiveCommand() {
    populateOptionsParser(argParser);
  }

  @override
  FutureOr<void>? run() async {
    options = parseOptionsResult(argResults!);
    if (options.sourceDir == null) {
      abort("source-dir option not specified");
    }

    if (options.outputFile == null) {
      abort("output-file option not specified");
    }

    final archive = Archive();
    archive.archive(Directory(options.sourceDir!), File(options.outputFile!));
  }

  void abort(String error) {
    print(error);
    print(usage);
    exit(64); //usage error
  }
}
