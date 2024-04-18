import 'package:realm_common/realm_common.dart';

part 'all_named_ctor.realm.dart';

const config = GeneratorConfig(ctorStyle: CtorStyle.allNamed);
const realmModel = RealmModel.using(baseType: ObjectType.realmObject, generatorConfig: config);

@realmModel
class _Person {
  late String name;
  int age = 42;
}
