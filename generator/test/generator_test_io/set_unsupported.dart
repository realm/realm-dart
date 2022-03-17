import 'package:realm_common/realm_common.dart';

//part 'set_unsupported.g.dart';

@RealmModel()
class _Person {
  late Set<_Person> children;
}
