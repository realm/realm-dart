// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'options.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

T _$enumValueHelper<T>(Map<T, String> enumValues, String source) => enumValues
    .entries
    .singleWhere((e) => e.value == source,
        orElse: () =>
            throw ArgumentError('`$source` is not one of the supported values: '
                '${enumValues.values.join(', ')}'))
    .key;

T? _$nullableEnumValueHelperNullable<T>(
        Map<T, String> enumValues, String? source) =>
    source == null ? null : _$enumValueHelper(enumValues, source);

Options _$parseOptionsResult(ArgResults result) => Options()
  ..targetOsType = _$nullableEnumValueHelperNullable(
      _$TargetOsTypeEnumMapBuildCli, result['target-os-type'] as String?)
  ..targetOsVersion = result['target-os-version'] as String?
  ..flutter = result['flutter'] as bool
  ..verbose = result['verbose'] as bool
  ..help = result['help'] as bool;

const _$TargetOsTypeEnumMapBuildCli = <TargetOsType, String>{
  TargetOsType.android: 'android',
  TargetOsType.ios: 'ios',
  TargetOsType.linux: 'linux',
  TargetOsType.macos: 'macos',
  TargetOsType.windows: 'windows'
};

ArgParser _$populateOptionsParser(ArgParser parser) => parser
  ..addOption('target-os-type',
      allowed: ['android', 'ios', 'linux', 'macos', 'windows'])
  ..addOption('target-os-version')
  ..addFlag('flutter', defaultsTo: true)
  ..addFlag('verbose', abbr: 'v', help: 'Show additional command output.')
  ..addFlag('help',
      abbr: 'h', help: 'Prints usage information.', negatable: false);

final _$parserForOptions = _$populateOptionsParser(ArgParser());

Options parseOptions(List<String> args) {
  final result = _$parserForOptions.parse(args);
  return _$parseOptionsResult(result);
}
