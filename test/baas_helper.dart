import 'dart:io';

import 'package:args/args.dart';
import 'package:test/test.dart' as testing;

import '../lib/realm.dart';
import '../lib/src/cli/atlas_apps/baas_client.dart';
import '../lib/src/native/realm_core.dart';

const String argBaasUrl = "BAAS_URL";
const String argBaasCluster = "BAAS_CLUSTER";
const String argBaasApiKey = "BAAS_API_KEY";
const String argBaasPrivateApiKey = "BAAS_PRIVATE_API_KEY";
const String argBaasProjectId = "BAAS_PROJECT_ID";
const String argDifferentiator = "BAAS_DIFFERENTIATOR";
const String argBaasaasApiKey = "BAAS_BAASAAS_API_KEY";

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
    ..addOption(argBaasaasApiKey);

  final result = parser.parse(arguments ?? []);
  testArgs
    ..addArgument(result, "name")
    ..addArgument(result, argBaasUrl)
    ..addArgument(result, argBaasCluster)
    ..addArgument(result, argBaasApiKey)
    ..addArgument(result, argBaasPrivateApiKey)
    ..addArgument(result, argBaasProjectId)
    ..addArgument(result, argDifferentiator)
    ..addArgument(result, argBaasaasApiKey);

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

class BaasHelper {
  final BaasClient _baasClient;
  final _baasApps = <String, BaasApp>{};

  String get baseUrl => _baasClient.baseUrl;

  static Object? _error;

  static Future<BaasHelper?> setupBaas(Map<String, String?> args) async {
    try {
      final client = await _setupClient(args);
      if (client == null) {
        return null;
      }

      final result = BaasHelper._(client);

      await result._setupApps();

      return result;
    } catch (e) {
      print(e);
      _error = e;
      rethrow;
    }
  }

  static bool shouldRunBaasTests(Map<String, String?> args) {
    return args[argBaasaasApiKey] != null || args[argBaasUrl] != null;
  }

  BaasHelper._(this._baasClient);

  static Future<BaasClient?> _setupClient(Map<String, String?> args) async {
    var baasUrl = args[argBaasUrl];
    final differentiator = args[argDifferentiator] ?? 'local';
    if (baasUrl == null) {
      final baasaasApiKey = args[argBaasaasApiKey];
      if (baasaasApiKey != null) {
        if (args[argBaasCluster] != null) {
          throw "$argBaasaasApiKey can't be combined with $argBaasCluster";
        }

        (baasUrl, _) = await BaasClient.retry(() => BaasClient.getOrDeployContainer(baasaasApiKey, differentiator));
      }
    }

    if (baasUrl == null) {
      return null;
    }

    final cluster = args[argBaasCluster];
    final apiKey = args[argBaasApiKey];
    final privateApiKey = args[argBaasPrivateApiKey];
    final projectId = args[argBaasProjectId];

    final client = await BaasClient.retry(() => (cluster == null
        ? BaasClient.docker(baasUrl!, differentiator)
        : BaasClient.atlas(baasUrl!, cluster, apiKey!, privateApiKey!, projectId!, differentiator)));

    client.publicRSAKey = publicRSAKeyForJWTValidation;
    return client;
  }

  Future<void> _setupApps() async {
    try {
      final apps = await _baasClient.getOrCreateApps();

      for (final app in apps) {
        _baasApps[app.name] = app;
        if (app.name == AppNames.flexible.name && app.isNewDeployment) {
          await _waitForInitialSync(app);
        }
      }
    } catch (error) {
      print(error);
      _error = error;
    }
  }

  Future<void> _waitForInitialSync(BaasApp app) async {
    while (true) {
      try {
        print('Validating initial sync is complete...');
        await _baasClient.waitForInitialSync(app);
        return;
      } catch (e) {
        print(e);
      } finally {
        realmCore.clearCachedApps();
      }
    }
  }

  Future<String> createServerApiKey(App app, String name, {bool enabled = true}) async {
    final baasApp = _baasApps.values.firstWhere((ba) => ba.clientAppId == app.id);
    return await _baasClient.createApiKey(baasApp.appId, name, enabled);
  }

  static void throwIfSetupFailed() {
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
        if (result['status'] != 'success') {
          throw 'Unsuccesful status: ${result['status']}';
        }
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
