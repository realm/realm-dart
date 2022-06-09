// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'options.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

Options _$parseOptionsResult(ArgResults result) => Options(
      result['baas-url'] as String,
      atlasCluster: result['atlas-cluster'] as String?,
      apiKey: result['api-key'] as String?,
      privateApiKey: result['private-api-key'] as String?,
      projectId: result['project-id'] as String?,
      differentiator: result['differentiator'] as String?,
    );

ArgParser _$populateOptionsParser(ArgParser parser) => parser
  ..addOption(
    'baas-url',
    help: 'Url for MongoDB Atlas.',
    defaultsTo: 'http://localhost:9090',
  )
  ..addOption(
    'differentiator',
    help: 'The database prefix that will be used for the sync service.',
  )
  ..addOption(
    'atlas-cluster',
    help: 'Atlas Cluster to link in the application.',
  )
  ..addOption(
    'api-key',
    help: 'Atlas API key to use for the import. Only used if atlas-cluster is specified.',
  )
  ..addOption(
    'private-api-key',
    help: 'The private Atlas API key to use for the import. Only used if atlas-cluster is specified.',
  )
  ..addOption(
    'project-id',
    help: 'The Atlas project id to use for the import. Only used if atlas-cluster is specified.',
  );

final _$parserForOptions = _$populateOptionsParser(ArgParser());

Options parseOptions(List<String> args) {
  final result = _$parserForOptions.parse(args);
  return _$parseOptionsResult(result);
}
