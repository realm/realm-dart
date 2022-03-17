import 'package:realm_common/realm_common.dart';

//part 'reusing_map_to_name.g.dart';

@RealmModel()
@MapTo('Bad3')
class _Foo {}

@MapTo('Bad3')
@RealmModel()
class _Bar {}
