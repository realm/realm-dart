import 'package:realm_common/realm_common.dart';

//part 'map_unsupported.g.dart';

@RealmModel()
class _Person {
  late Map<int, _Person?> relatives;
}
