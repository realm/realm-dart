class RealmObject {
    static dynamic getSchema(String name, Iterable<SchemaProperty> properties) {
    }

  Object operator [](String name) { return null; }
  void operator []=(String name, Object value) {}

    dynamic get _schema {}
}

class DynamicObject {}  

//RealmProperty should be in realmobject so it is imported in order to be able to write a Schema class
class RealmProperty {
  final bool primaryKey;
  final String type;
  final String defaultValue;
  final bool optional;
  final String mapTo;
  const RealmProperty({this.type, this.defaultValue, this.optional, this.mapTo, this.primaryKey});
}

class SchemaProperty extends RealmProperty {
  final String propertyName;
  const SchemaProperty(this.propertyName, { type, defaultValue, optional, mapTo, primaryKey }) 
    : super(type: type, defaultValue: defaultValue, optional: optional, mapTo: mapTo, primaryKey: primaryKey);
}

void work() {
  new SchemaProperty("myfile", type: "");
}