import 'package:realm_common/realm_common.dart';

//part 'nullable_list.g.dart';

@RealmModel()
class _Bad {
  @PrimaryKey()
  late int id;

  List<int>? wrong;
}
