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

Options _$parseOptionsResult(ArgResults result) => Options(
    _$nullableEnumValueHelperNullable(
        _$TargetOsTypeEnumMapBuildCli, result['target-os-type'] as String?),
    result['target-os-version'] as String?)
  ..applicationIdentifier = result['application-identifier'] as String?
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
      abbr: 't', allowed: ['android', 'ios', 'linux', 'macos', 'windows'])
  ..addOption('target-os-version', abbr: 'v')
  ..addOption('application-identifier',
      abbr: 'i',
      help:
          'Platform specific application identifer (package name, bundle id, etc.)')
  ..addFlag('help',
      abbr: 'h', help: 'Prints usage information.', negatable: false);

final _$parserForOptions = _$populateOptionsParser(ArgParser());

Options parseOptions(List<String> args) {
  final result = _$parserForOptions.parse(args);
  return _$parseOptionsResult(result);
}
