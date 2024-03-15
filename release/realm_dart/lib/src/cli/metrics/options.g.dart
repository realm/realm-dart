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
      targetOsVersion: result['target-os-version'] as String?,
      flutterRoot: result['flutter-root'] as String?,
      pubspecPath: result['pubspec-path'] as String?,
    )..verbose = result['verbose'] as bool;

const _$TargetOsTypeEnumMapBuildCli = <TargetOsType, String>{
  TargetOsType.android: 'android',
  TargetOsType.ios: 'ios',
  TargetOsType.linux: 'linux',
  TargetOsType.macos: 'macos',
  TargetOsType.windows: 'windows'
};

ArgParser _$populateOptionsParser(ArgParser parser) => parser
  ..addOption(
    'target-os-type',
    help: 'The OS type this project is targeting.',
    allowed: ['android', 'ios', 'linux', 'macos', 'windows'],
  )
  ..addOption(
    'target-os-version',
    help: 'The OS version this project is targeting.',
  )
  ..addOption(
    'flutter-root',
    help: 'The path to the Flutter SDK (excluding the bin directory).',
  )
  ..addOption(
    'pubspec-path',
    help: 'The path to the application pubspec',
  )
  ..addFlag(
    'verbose',
    abbr: 'v',
    help: 'Show additional command output.',
  );

final _$parserForOptions = _$populateOptionsParser(ArgParser());

Options parseOptions(List<String> args) {
  final result = _$parserForOptions.parse(args);
  return _$parseOptionsResult(result);
}
