import 'package:realm_common/realm_common.dart';

//part 'invalid_model_name_prefix.g.dart';

@RealmModel()
class Bad {
  // missing _ or $ prefix
}
