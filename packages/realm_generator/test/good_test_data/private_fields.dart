// ignore_for_file: unused_element, prefer_final_fields, unused_field

import 'package:realm_common/realm_common.dart';

part 'private_fields.realm.dart';

@RealmModel()
class _WithPrivateFields {
  late String _plain;
  int _withDefault = 0;
}
