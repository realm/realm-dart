import 'package:realm_common/realm_common.dart';

part 'missing_underscore.realm.dart';

@RealmModel()
class _Bad {
  late Other other;
}

@RealmModel()
class _Other {}

class Other extends _Other {} // mock class for testing
