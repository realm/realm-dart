// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'options.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

Options _$parseOptionsResult(ArgResults result) => Options(
      sourceDir: result['source-dir'] as String?,
      outputFile: result['output-file'] as String?,
    );

ArgParser _$populateOptionsParser(ArgParser parser) => parser
  ..addOption(
    'source-dir',
    help: 'This option is required',
  )
  ..addOption(
    'output-file',
    help: 'This option is required',
  );

final _$parserForOptions = _$populateOptionsParser(ArgParser());

Options parseOptions(List<String> args) {
  final result = _$parserForOptions.parse(args);
  return _$parseOptionsResult(result);
}
