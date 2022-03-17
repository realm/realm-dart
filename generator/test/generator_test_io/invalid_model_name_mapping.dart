import 'package:realm_common/realm_common.dart';
//part 'invalid_model_name_mapping.g.dart';

const one = '1';

@RealmModel()
@MapTo(one) // <- invalid
// prefix is not important, as we explicitly define name with @MapTo,
// but obviously 1 is not a valid class name
class Bad {}
