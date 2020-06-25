import 'package:meta/meta.dart';

class RealmProperty {
  final bool primaryKey;
  final String type;
  final String defaultValue;
  final bool optional;
  final String mapTo;
  const RealmProperty({@required this.type, this.defaultValue, this.optional, this.mapTo, this.primaryKey});
}

class SchemaProperty extends RealmProperty {
  final String propertyName;
  const SchemaProperty(this.propertyName, { type, defaultValue, optional, mapTo, primaryKey }) 
    : super(type: type, defaultValue: defaultValue, optional: optional, mapTo: mapTo, primaryKey: primaryKey);
}