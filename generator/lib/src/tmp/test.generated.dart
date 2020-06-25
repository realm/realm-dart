// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Car extends RealmObject {
  @RealmProperty(type: "string")
  String make;

  @RealmProperty(type: "string")
  String model;

  @RealmProperty(type: "int", defaultValue: "0")
  int kolometers;

  dynamic get _schema {
    // dynamic schema = DynamicObject();
    // schema.name = type.toString();
    // schema.properties = new DynamicObject();
    
    // dynamic propertyValue = DynamicObject();
    // propertyValue.type = realmProperty.type;
    // propertyValue['default'] = realmProperty.defaultValue ?? null;
    // propertyValue.optional = realmProperty.optional ?? null;
    // propertyValue.mapTo = realmProperty.mapTo ?? null;

    // schema.properties[propertyName] = propertyValue;
    // if (realmProperty.primaryKey ?? false) {
    //   schema.primaryKey = propertyName;
    // }
    return RealmObject.getSchema('Car', [
      SchemaProperty('carMake', type: "int", defaultValue: "0"), 
      SchemaProperty('carModel', type: "string"),
    ]);
  }
}

// //this is called from native code to get the schema as DynamicObject. The schema argument is realm::DynamicObject which is created from native code
// dynamic _getSchema(Type type, dynamic schema) {
//   if (type == Car) {
//       schema.name = "Car";
//       schema.properties = schema.newObject(); //returns a new DynamicObject()
//   }

//   throw new Exception("Unkown RealmObject type ${type.toString()}.");
// }
