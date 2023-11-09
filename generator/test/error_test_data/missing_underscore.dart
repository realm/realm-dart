import 'package:realm_common/realm_common.dart';

// part 'missing_underscore.g.dart';
class Other {} // dummy stand-in for the generated class

@RealmModel()
class _Bad {
  late Other other;
}

@RealmModel()
class _Other {}
