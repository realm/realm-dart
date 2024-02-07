import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'options.g.dart';

@CliOptions()
class Options {
  @CliOption(defaultsTo: false, help: "Optional. Cleans generator caches. Same as running 'dart run build_runner clean'")
  bool clean = false;

  @CliOption(defaultsTo: false, help: "Optional. Watches for changes and generates RealmObjects classes on the background. Same as running 'dart run build_runner watch --delete-conflicting-outputs'")
  bool watch = false;
}

String get usage => _$parserForOptions.usage;

ArgParser populateOptionsParser(ArgParser p) => _$populateOptionsParser(p);

Options parseOptionsResult(ArgResults results) => _$parseOptionsResult(results);
