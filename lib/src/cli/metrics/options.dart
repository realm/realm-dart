import 'package:build_cli_annotations/build_cli_annotations.dart';
import 'target_os_type.dart';

part 'options.g.dart';

@CliOptions()
class Options {
  TargetOsType? targetOsType;
  String? targetOsVersion;

  @CliOption(defaultsTo: true)
  late bool flutter;

  @CliOption(abbr: 'v', help: 'Show additional command output.')
  bool verbose = false;
}

String get usage => _$parserForOptions.usage;

ArgParser populateOptionsParser(ArgParser p) => _$populateOptionsParser(p);

Options parseOptionsResult(ArgResults results) => _$parseOptionsResult(results);
