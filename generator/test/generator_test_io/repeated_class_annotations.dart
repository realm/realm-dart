import 'package:realm_common/realm_common.dart';

//part 'repeated_class_annotations.g.dart';

@RealmModel()
@MapTo('Bad')
@RealmModel()
class _Bad {}
