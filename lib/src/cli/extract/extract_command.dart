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
import 'package:path/path.dart' as path;

import 'options.dart';
import '../common/archive.dart';

class ExtractCommand extends Command<void> {
  @override
  final String description = 'Extract Realm binaries';

  @override
  final String name = 'extract';

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
