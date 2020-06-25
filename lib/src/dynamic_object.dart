import 'helpers.dart';

class TypeStaticProperties {
  static final _staticProperties = new Map<Type, Map<String, dynamic>>();

  static dynamic getValue(Type type, String name) {
    Map<String, dynamic> properties = _staticProperties[type];
    if (properties == null) {
      return null;
    }

    return properties[name];
  }

  static setValue(Type type, String name, dynamic value) {
    Map<String, dynamic> properties = _staticProperties[type];
    if (properties == null) {
      properties = new Map<String, dynamic>();
      _staticProperties[type] = properties;
    }

    properties[name] = value;
  }
}

class DynamicObject {
  DynamicObject();

  final _properties = new Map<String, Object>();

  dynamic operator [](String name) {
    return _properties[name];
  }

  void operator []=(String name, dynamic value) {
    _properties[name] = value;
  }

  List<String> get propertyNames {
    var result = new List<String>();
    result.addAll(_properties.keys);
    return result;
  }

  @override
  noSuchMethod(Invocation invocation) {
    if (!invocation.isAccessor) {
      return super.noSuchMethod(invocation);
    }

    //final realName = invocation.memberName.toString();
    String name = invocation.memberName.name;
    name = name.endsWith('=') ? name.substring(0, name.length - 1) : name;
    if (invocation.isSetter) {
      //final name = realName.substring(8, realName.length - 3);
      dynamic value = invocation.positionalArguments.first;
      _properties[name] = value;
    } else {
      return _properties[name];
    }
  }
}

// class SchemaDynamicObject {
//   SchemaDynamicObject(Map<String, dynamic> map) {}

//   dynamic operator [](String name) {
//     return this[name];
//   }

//   void operator []=(String name, dynamic value) {
//     this[name] = value;
//   }

//   final _properties = new Map<String, Object>();

//   @override
//   noSuchMethod(Invocation invocation) {
//     print("dynamic object noSuchMethod invoked");
//     if (invocation.isAccessor) {
//       final realName = invocation.memberName.toString();
//       if (invocation.isSetter) {
//         final name = realName.substring(8, realName.length - 3);
//         _properties[name] = invocation.positionalArguments.first;
//         return;
//       } else {
//         return _properties[realName];
//       }
//     }

//     return super.noSuchMethod(invocation);
//   }
// }
