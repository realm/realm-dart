import 'dart:io';
import 'package:integration_test/integration_test.dart';
import 'package:test/test.dart';

import 'realm_test.dart' as tests;

Future<void> main() async {
  print("Current PID $pid");

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late List<String> testArgs;
  setUpAll(() {
    testArgs = [
      getArgFromEnvVariable("BAAS_URL"),
      getArgFromEnvVariable("BAAS_CLUSTER"),
      getArgFromEnvVariable("BAAS_API_KEY"),
      getArgFromEnvVariable("BAAS_PRIVATE_API_KEY"),
      getArgFromEnvVariable("BAAS_PROJECT_ID"),
      getArgFromEnvVariable("BAAS_DIFFERENTIATOR"),
    ];
  });

  await tests.main(testArgs);
}

String getArgFromEnvVariable(String argName) {
  return " --$argName ${Platform.environment[argName]}";
}
