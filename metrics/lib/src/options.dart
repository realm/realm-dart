import 'package:build_cli_annotations/build_cli_annotations.dart';
import 'package:metrics/src/target_os_type.dart';

part 'options.g.dart';

@CliOptions()
class Options {
  TargetOsType? targetOsType;
  String? targetOsVersion;

  @CliOption(defaultsTo: true)
  late bool flutter;

  @CliOption(abbr: 'v', help: 'Show additional command output.')
  bool verbose = false;

  @CliOption(
    abbr: 'h',
    negatable: false,
    defaultsTo: false,
    help: 'Prints usage information.',
  )
  late bool help;
}

String get usage => _$parserForOptions.usage;
