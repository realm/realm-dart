// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'options.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

Options _$parseOptionsResult(ArgResults result) => Options(
      sourceFile: result['source-file'] as String?,
      outputDir: result['output-dir'] as String?,
    );

ArgParser _$populateOptionsParser(ArgParser parser) => parser
  ..addOption(
    'output-dir',
    help: 'This option is required',
  )
  ..addOption(
    'source-file',
    help: 'This option is required',
  );

final _$parserForOptions = _$populateOptionsParser(ArgParser());

Options parseOptions(List<String> args) {
  final result = _$parserForOptions.parse(args);
  return _$parseOptionsResult(result);
}
