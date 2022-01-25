// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'options.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

Options _$parseOptionsResult(ArgResults result) => Options()
  ..clean = result['clean'] as bool
  ..watch = result['watch'] as bool;

ArgParser _$populateOptionsParser(ArgParser parser) => parser
  ..addFlag(
    'clean',
    help:
        "Optional. Cleans generator caches. Same as running 'dart run build_runner clean'",
  )
  ..addFlag(
    'watch',
    help:
        "Optional. Watches for changes and generates RealmObjects classes on the background. Same as running 'dart run build_runner watch --delete-conflicting-outputs'",
  );

final _$parserForOptions = _$populateOptionsParser(ArgParser());

Options parseOptions(List<String> args) {
  final result = _$parserForOptions.parse(args);
  return _$parseOptionsResult(result);
}
