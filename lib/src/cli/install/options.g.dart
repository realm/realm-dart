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
      packageName: result['package-name'] as String?,
      debug: result['debug'] as bool?,
    );

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
    abbr: 't',
    help: 'Required for Flutter. The target OS to install binaries for.',
    allowed: ['android', 'ios', 'linux', 'macos', 'windows'],
  )
  ..addOption(
    'package-name',
    abbr: 'p',
    help: 'Optional. The realm package name to install binaries for.',
    defaultsTo: 'realm_dart',
    allowed: ['realm', 'realm_dart'],
  )
  ..addFlag(
    'debug',
    defaultsTo: false,
    hide: true,
  );

final _$parserForOptions = _$populateOptionsParser(ArgParser());

Options parseOptions(List<String> args) {
  final result = _$parserForOptions.parse(args);
  return _$parseOptionsResult(result);
}
