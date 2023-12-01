import 'dart:io';
import 'dart:isolate';

import 'package:args/args.dart';
import 'package:path/path.dart' as _path;
import 'package:test/test.dart' as testing;
import 'package:test/test.dart';

import '../lib/src/cli/atlas_apps/baas_client.dart';
import '../lib/realm.dart';

import 'test.dart';

part 'baas_helper.g.dart';

const String argBaasUrl = "BAAS_URL";
const String argBaasCluster = "BAAS_CLUSTER";
const String argBaasApiKey = "BAAS_API_KEY";
const String argBaasPrivateApiKey = "BAAS_PRIVATE_API_KEY";
const String argBaasProjectId = "BAAS_PROJECT_ID";
const String argDifferentiator = "BAAS_DIFFERENTIATOR";
const String argUseBaaSaaS = "BAAS_USE_BAASAAS";

const String publicRSAKeyForJWTValidation = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvNHHs8T0AHD7SJ+CKvVR
leeJa4wqYTnaVYV+5bX9FmFXVoN+vHbMLEteMvSw4L3kSRZdcqxY7cTuhlpAvkXP
Yq6qSI+bW8T4jGW963uCc83UhVMx4MH/PzipAlfcPjVO2u4c+dmpgZQpgEmA467u
tauXUhmTsGpgNg2Gvc61B7Ny4LphshsyrfaJ9WjA/NM6LOmEBW3JPNcVG2qyU+gt
O8BM8KOSx9wGyoGs4+OusvRkJizhPaIwa3FInLs4r+xZW9Bp6RndsmVECtvXRv5d
87ztpg6o3DZJRmTp2lAnkNLmxXlFkOSNIwiT3qqyRZOh4DuxPOpfg9K+vtFmRdEJ
RwIDAQAB
-----END PUBLIC KEY-----''';

Map<String, String?> parseTestArguments(List<String>? arguments) {
  Map<String, String?> testArgs = {};
  final parser = ArgParser()
    ..addOption("name")
    ..addOption(argBaasUrl)
    ..addOption(argBaasCluster)
    ..addOption(argBaasApiKey)
    ..addOption(argBaasPrivateApiKey)
    ..addOption(argBaasProjectId)
    ..addOption(argDifferentiator)
    ..addOption(argUseBaaSaaS);

  final result = parser.parse(arguments ?? []);
  testArgs
    ..addArgument(result, "name")
    ..addArgument(result, argBaasUrl)
    ..addArgument(result, argBaasCluster)
    ..addArgument(result, argBaasApiKey)
    ..addArgument(result, argBaasPrivateApiKey)
    ..addArgument(result, argBaasProjectId)
    ..addArgument(result, argDifferentiator)
    ..addArgument(result, argUseBaaSaaS);

  return testArgs;
}

extension on Map<String, String?> {
  void addArgument(ArgResults parsedResult, String argName) {
    final value = parsedResult.wasParsed(argName) ? parsedResult[argName]?.toString() : Platform.environment[argName];
    if (value != null && value.isNotEmpty) {
      this[argName] = value;
    }
  }
}

enum AppNames {
  flexible,

  // For application with name 'autoConfirm' and with confirmationType = 'auto'
  // all the usernames are automatically confirmed.
  autoConfirm,

  emailConfirm,
}

@RealmModel()
class _BaasInfo {
  late String baasUrl;
  String? cluster;
  String? apiKey;
  String? privateApiKey;
  String? projectId;
  String? differentiator;

  late List<_BaasAppDetails> apps;
}

@RealmModel(ObjectType.embeddedObject)
class _BaasAppDetails {
  late String appId;
  late String clientAppId;
  late String name;
  late String uniqueName;

  String? error;
}

class BaasHelper {
  final BaasClient _baasClient;
  final _baasApps = <String, BaasApp>{};

  String get baseUrl => _baasClient.baseUrl;

  static Object? _error;

  static Future<BaasHelper?> setupBaas(Map<String, String?> args) async {
    if (_error != null) {
      throw _error!;
    }

    final realmPath = _path.join(Directory.current.path, 'baasmeta', 'baas_$pid.realm');
    final realm = Realm(Configuration.local([BaasInfo.schema, BaasAppDetails.schema], path: realmPath));
    final (client, baasInfo) = await _setupClient(args, realm);
    if (client == null || baasInfo == null) {
      return null;
    }

    final result = BaasHelper._(client);

    await result._setupApps(baasInfo);

    return result;
  }

  BaasHelper._(this._baasClient);

  static Future<(BaasClient?, BaasInfo?)> _setupClient(Map<String, String?> args, Realm realm) async {
    try {
      var baasInfo = realm.all<BaasInfo>().firstOrNull;
      if (baasInfo == null) {
        late String? baasUrl;
        final useBaaSaaS = args[argUseBaaSaaS] == 'true';
        if (useBaaSaaS) {
          if (args[argBaasCluster] != null) {
            throw "$argUseBaaSaaS can't be combined with $argBaasCluster";
          }

          baasUrl = await BaasClient.deployContainer();
        } else {
          baasUrl = args[argBaasUrl];
        }

        if (baasUrl == null) {
          return (null, null);
        }

        baasInfo = realm.write(() => realm.add(BaasInfo(baasUrl!,
            cluster: args[argBaasCluster],
            apiKey: args[argBaasApiKey],
            privateApiKey: args[argBaasPrivateApiKey],
            projectId: args[argBaasProjectId],
            differentiator: args[argDifferentiator])))!;
      }

      final client = await (baasInfo.cluster == null
          ? BaasClient.docker(baasInfo.baasUrl, baasInfo.differentiator)
          : BaasClient.atlas(baasInfo.baasUrl, baasInfo.cluster!, baasInfo.apiKey!, baasInfo.privateApiKey!, baasInfo.projectId!, baasInfo.differentiator));

      client.publicRSAKey = publicRSAKeyForJWTValidation;
      return (client, baasInfo);
    } catch (error) {
      print(error);
      _error = error;
      return (null, null);
    }
  }

  Future<void> _setupApps(BaasInfo baasInfo) async {
    try {
      var isNewDeployment = false;
      if (baasInfo.apps.isEmpty) {
        final apps = await _baasClient.getOrCreateApps();
        baasInfo.realm.write(() {
          baasInfo.apps.addAll(apps.map((e) => BaasAppDetails(e.appId, e.clientAppId, e.name, e.uniqueName, error: e.error?.toString())));
        });
        isNewDeployment = true;
      }

      for (final app in baasInfo.apps) {
        _baasApps[app.name] = BaasApp(app.appId, app.clientAppId, app.name, app.uniqueName)..error = app.error;
      }

      if (isNewDeployment) {
        await _waitForInitialSync(AppNames.flexible);
      }
    } catch (error) {
      print(error);
      _error = error;
    }
  }

  Future<void> _waitForInitialSync(AppNames app) async {
    while (true) {
      try {
        final baasApp = _baasApps[app.name]!;
        print('Validating initial sync is complete...');
        await _baasClient.waitForInitialSync(baasApp);
        final appConfig = await _getAppConfig(baasApp.name);
        final realm = await getIntegrationRealm(appConfig: appConfig);
        await realm.syncSession.waitForUpload();
        await _baasClient.waitForInitialSync(baasApp);
        return;
      } catch (e) {
        print(e);
      }
    }
  }

  Future<String> createServerApiKey(App app, String name, {bool enabled = true}) async {
    final baasApp = _baasApps.values.firstWhere((ba) => ba.clientAppId == app.id);
    return await _baasClient.createApiKey(baasApp.appId, name, enabled);
  }

  void throwIfSetupFailed() {
    if (_error != null) {
      throw _error!;
    }
  }

  void printSplunkLogLink(AppNames appName, String? uriVariable) {
    if (uriVariable == null) {
      return;
    }

    final app = _baasApps[appName.name] ?? (throw RealmError("No BAAS apps"));
    final baasUri = Uri.parse(uriVariable);

    testing.printOnFailure("App service name: ${app.uniqueName}");
    final host = baasUri.host.endsWith('-qa.mongodb.com') ? "-qa" : "";
    final splunk = Uri.encodeFull(
        "https://splunk.corp.mongodb.com/en-US/app/search/search?q=search index=baas$host \"${app.uniqueName}-*\" | reverse | top error msg&earliest=-7d&latest=now&display.general.type=visualizations");
    testing.printOnFailure("Splunk logs: $splunk");
  }

  Future<AppConfiguration> getAppConfig({AppNames appName = AppNames.flexible}) => _getAppConfig(appName.name);

  Future<AppConfiguration> _getAppConfig(String appName) async {
    final app = _baasApps[appName] ??
        _baasApps.values.firstWhere((element) => element.name == BaasClient.defaultAppName, orElse: () => throw RealmError("No BAAS apps"));
    if (app.error != null) {
      throw app.error!;
    }

    final temporaryDir = await Directory.systemTemp.createTemp('realm_test_');
    return AppConfiguration(
      app.clientAppId,
      baseUrl: Uri.parse(baseUrl),
      baseFilePath: temporaryDir,
      maxConnectionTimeout: Duration(minutes: 10),
      defaultRequestTimeout: Duration(minutes: 7),
    );
  }

  String getClientAppId({AppNames appName = AppNames.flexible}) => _baasApps[appName.name]!.clientAppId;

  Future<void> disableAutoRecoveryForApp(AppNames appName) async {
    await _baasClient.setAutomaticRecoveryEnabled(appName.name, false);
  }

  Future<void> enableAutoRecoveryForApp(AppNames appName) async {
    await _baasClient.setAutomaticRecoveryEnabled(appName.name, true);
  }

  Future<void> triggerClientReset(Realm realm, {bool restartSession = true}) async {
    final config = realm.config;
    if (config is! FlexibleSyncConfiguration) {
      throw RealmError('This should only be invoked for sync realms');
    }

    final session = realm.syncSession;
    if (restartSession) {
      session.pause();
    }

    final userId = config.user.id;
    final appId = _baasApps.values.firstWhere((element) => element.clientAppId == config.user.app.id).appId;

    for (var i = 0; i < 5; i++) {
      try {
        final result = await config.user.functions.call('triggerClientResetOnSyncServer', [userId, appId]) as Map<String, dynamic>;
        expect(result['status'], 'success');
        break;
      } catch (e) {
        if (i == 4) {
          rethrow;
        }

        print('Failed to trigger client reset: $e');
        await Future.delayed(Duration(seconds: i));
      }
    }

    if (restartSession) {
      session.resume();
    }
  }
}
