import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'options.g.dart';

@CliOptions()
class Options {
  @CliOption(help: "Same as running 'dart run build_runner clean'")
  bool clean = false;

  @CliOption(help: "Same as running 'dart run build_runner watch --delete-conflicting-outputs'")
  bool watch = false;
}

String get usage => _$parserForOptions.usage;

ArgParser populateOptionsParser(ArgParser p) => _$populateOptionsParser(p);

Options parseOptionsResult(ArgResults results) => _$parseOptionsResult(results);
