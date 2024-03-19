// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:test/test.dart' as testing;

import 'package:realm_dart/realm.dart';
import 'package:realm_dart/src/cli/atlas_apps/baas_client.dart';
import 'package:realm_dart/src/native/realm_core.dart';

const String publicRSAKeyForJWTValidation = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvNHHs8T0AHD7SJ+CKvVR
leeJa4wqYTnaVYV+5bX9FmFXVoN+vHbMLEteMvSw4L3kSRZdcqxY7cTuhlpAvkXP
Yq6qSI+bW8T4jGW963uCc83UhVMx4MH/PzipAlfcPjVO2u4c+dmpgZQpgEmA467u
tauXUhmTsGpgNg2Gvc61B7Ny4LphshsyrfaJ9WjA/NM6LOmEBW3JPNcVG2qyU+gt
O8BM8KOSx9wGyoGs4+OusvRkJizhPaIwa3FInLs4r+xZW9Bp6RndsmVECtvXRv5d
87ztpg6o3DZJRmTp2lAnkNLmxXlFkOSNIwiT3qqyRZOh4DuxPOpfg9K+vtFmRdEJ
RwIDAQAB
-----END PUBLIC KEY-----''';

enum Env {
  baasUrl('BAAS_URL', String.fromEnvironment('BAAS_URL')),
  baasCluster('BAAS_CLUSTER', String.fromEnvironment('BAAS_CLUSTER')),
  baasApiKey('BAAS_API_KEY', String.fromEnvironment('BAAS_API_KEY')),
  baasPrivateApiKey('BAAS_PRIVATE_API_KEY', String.fromEnvironment('BAAS_PRIVATE_API_KEY')),
  baasProjectId('BAAS_PROJECT_ID', String.fromEnvironment('BAAS_PROJECT_ID')),
  baasAasApiKey('BAAS_BAASAAS_API_KEY', String.fromEnvironment('BAAS_BAASAAS_API_KEY')),
  differentiator('BAAS_DIFFERENTIATOR', String.fromEnvironment('BAAS_DIFFERENTIATOR')),
  ;

  final String name;
  final String _dartDefined;

  const Env(this.name, this._dartDefined);

  String? get dartDefined => _dartDefined.emptyAsNull;
  String? get shellDefined => Platform.environment[name];
  String? get value => dartDefined ?? shellDefined;

  bool get isDefined => value != null;
  bool get isNotDefined => !isDefined;

  String? call() => value;
}

extension on String? {
  String? get emptyAsNull {
    final self = this;
    if (self == null || self.isEmpty) return null;
    return self;
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

  static Future<BaasHelper?> setupBaas() async {
    try {
      final client = await _setupClient();
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

  static bool get shouldRunBaasTests {
    return Env.baasUrl.isDefined || Env.baasAasApiKey.isDefined;
  }

  BaasHelper._(this._baasClient);

  static Future<BaasClient?> _setupClient() async {
    var baasUrl = Env.baasUrl();
    final cluster = Env.baasCluster();
    final apiKey = Env.baasApiKey();
    final privateApiKey = Env.baasPrivateApiKey();
    final projectId = Env.baasProjectId();
    final differentiator = Env.differentiator() ?? 'local';

    if (baasUrl == null) {
      final baasAasApiKey = Env.baasAasApiKey();
      if (baasAasApiKey != null) {
        if (cluster != null) {
          throw "BAAS_BAASAAS_API_KEY can't be combined with BAAS_CLUSTER";
        }

        (baasUrl, _) = await BaasClient.retry(() => BaasClient.getOrDeployContainer(
              baasAasApiKey,
              differentiator,
            ));
      }
    }

    if (baasUrl == null) {
      return null;
    }

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
          throw 'Unsuccessful status: ${result['status']}';
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
