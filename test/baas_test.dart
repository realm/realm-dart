import 'credentials_test.dart' as credentials_tests;
import 'app_test.dart' as app_tests;

Future<void> main([List<String>? args]) async {
  await credentials_tests.main(args);
  await app_tests.main(args);
}
