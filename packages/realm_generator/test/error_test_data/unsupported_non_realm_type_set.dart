import 'package:realm_common/realm_common.dart';

//part 'unsupported_non_realm_type_set.realm.dart';

@RealmModel()
class _Bad {
  @PrimaryKey()
  late int id;

  late Set<RealmStateError> wrong;
}