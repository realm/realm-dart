import 'package:build_cli_annotations/build_cli_annotations.dart';
import 'package:metrics/src/target_os_type.dart';

part 'options.g.dart';

@CliOptions()
class Options {
  @CliOption(abbr: 't')
  TargetOsType? targetOsType;

  @CliOption(abbr: 'v')
  String? targetOsVersion;

  @CliOption(
    abbr: 'i',
    help:
        'Platform specific application identifer (package name, bundle id, etc.)',
  )
  String? applicationIdentifier;

  @CliOption(
    abbr: 'h',
    negatable: false,
    defaultsTo: false,
    help: 'Prints usage information.',
  )
  late bool help;

  @CliOption()
  Options(this.targetOsType, this.targetOsVersion);
}

String get usage => _$parserForOptions.usage;
