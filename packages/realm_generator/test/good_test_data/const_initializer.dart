import 'package:realm_common/realm_common.dart';

part 'const_initializer.realm.dart';

@RealmModel()
class _ConstInitializer {
  int x = 0;
  int y = -1;
  int z = const int.fromEnvironment('FOO', defaultValue: 1);

  String a = const String.fromEnvironment('FOO');
  String b = 'foo';

  var s = const <int>[]; // list
  var t = const <String, int>{}; // map
  var u = const <int>{}; // set

  var v = <int>[];
  var w = <String, int>{};
}
