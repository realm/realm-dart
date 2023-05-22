// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'options.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

T _$enumValueHelper<T>(Map<T, String> enumValues, String source) =>
    enumValues.entries
        .singleWhere(
          (e) => e.value == source,
          orElse: () => throw ArgumentError(
            '`$source` is not one of the supported values: '
            '${enumValues.values.join(', ')}',
          ),
        )
        .key;

T? _$nullableEnumValueHelperNullable<T>(
  Map<T, String> enumValues,
  String? source,
) =>
    source == null ? null : _$enumValueHelper(enumValues, source);

Options _$parseOptionsResult(ArgResults result) => Options(
      targetOsType: _$nullableEnumValueHelperNullable(
        _$TargetOsTypeEnumMapBuildCli,
        result['target-os-type'] as String?,
      ),
      flavor: _$enumValueHelper(
        _$FlavorEnumMapBuildCli,
        result['flavor'] as String,
      ),
      force: result['force'] as bool,
      debug: result['debug'] as bool,
    );

const _$TargetOsTypeEnumMapBuildCli = <TargetOsType, String>{
  TargetOsType.android: 'android',
  TargetOsType.ios: 'ios',
  TargetOsType.linux: 'linux',
  TargetOsType.macos: 'macos',
  TargetOsType.windows: 'windows'
};

const _$FlavorEnumMapBuildCli = <Flavor, String>{
  Flavor.flutter: 'flutter',
  Flavor.dart: 'dart'
};

ArgParser _$populateOptionsParser(ArgParser parser) => parser
  ..addOption(
    'target-os-type',
    abbr: 't',
    help: 'The target OS to install binaries for.',
    allowed: ['android', 'ios', 'linux', 'macos', 'windows'],
  )
  ..addOption(
    'flavor',
    abbr: 'f',
    help: 'The flavor to install binaries for.',
    defaultsTo: 'dart',
    allowed: ['flutter', 'dart'],
  )
  ..addFlag(
    'debug',
    help: 'Download binary from http://localhost:8000/.',
    hide: true,
  )
  ..addFlag(
    'force',
    help: 'Force install, even if we would normally skip it.',
    hide: true,
  );

final _$parserForOptions = _$populateOptionsParser(ArgParser());

Options parseOptions(List<String> args) {
  final result = _$parserForOptions.parse(args);
  return _$parseOptionsResult(result);
}
