import 'package:realm_common/realm_common.dart';

part 'const_initializer.realm.dart';

@RealmModel()
class _ConstInitializer {
  int zero = 0;
  int minusOne = -1;
  int fooOrOne = const int.fromEnvironment('FOO', defaultValue: 1);
  int parenthesis = (1);
  int minusMinusOne = -(-1);
  int add = 1 + 1;

  String fooEnv = const String.fromEnvironment('FOO');
  String fooLit = 'foo';

  // const collections allowed, but must be empty
  var constEmptyList = const <int>[]; // list
  var constEmptyMap = const <String, int>{}; // map
  var constEmptySet = const <int>{}; // set

  // const not needed on collections
  var emptyList = <int>[];
  var emptyMao = <String, int>{};
  var emptySet = <int>{};
}
