import 'package:realm_common/realm_common.dart';

//part 'nullable_set.g.dart';

@RealmModel()
class _Bad {
  @PrimaryKey()
  late int id;

  Set<int>? wrong;
}
