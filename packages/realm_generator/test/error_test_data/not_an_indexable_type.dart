import 'package:realm_common/realm_common.dart';

//part 'not_an_indexable_type.g.dart';

@RealmModel()
class _Bad {
  @Indexed()
  late double notAnIndexableType;
}
