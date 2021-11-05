////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

library realm_generator;

import 'dart:convert';

//import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class RealmObjectGenerator extends Generator {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {    
    var schemaClasses = library.classes.where((clazz) {
      return clazz.name.startsWith("_") &&
          clazz.fields.any((field) {
            return field.metadata.any((meta) {
              if (meta.element!.enclosingElement!.displayName == "RealmProperty") {
                return true;
              }
              //meta.element.enclosingElement.displayName == "RealmProperty"
              //meta.element.enclosingElement.fields[0].displayName == "primaryKey"
              //meta.element.enclosingElement.fields[0].type.displayName == "bool"
              //meta.element.enclosingElement.fields[0].type.isDartCoreBool == true

              // if (meta.annotationAst.name.name == "RealmProperty") {
              //   return true;
              // }
              //RealmProperty(type: "int")
              //meta.annotationAst.name.name == "RealmProperty"
              //type == meta.annotationAst.arguments.arguments[0].name.label.name
              //"int" == meta.annotationAst.arguments.arguments[0].expression.value

              return true;
            });
          });
    });
    //final numValue = annotation.read('value').literalValue as num;

    //return 'num ${element.name}Multiplied() => ${element.name} * $numValue;';

    StringBuffer generated = StringBuffer();
    for (var schemaClass in schemaClasses) {
      var className = schemaClass.name.substring(1);

      StringBuffer getSchemaPropertyBuffer = StringBuffer();
      
      /// The `const dynamic type = ...` is there to remove the warning of unused_element for the Realm data model class in the user dart file
      getSchemaPropertyBuffer.writeln("""
            static dynamic getSchema() {
              const dynamic type = ${schemaClass.name};
              return RealmObject.getSchema('$className', [
            """);


      //Class._constructor() is used from native code when creating new instances of this type
      //Class() constructor is used to be able to create new detached objects and add them to the realm
      generated.writeln("""class $className extends RealmObject {
          // ignore_for_file: unused_element, unused_local_variable
          $className._constructor() : super.constructor();
          $className();
        """);

      for (var field in schemaClass.fields) {
        if (field.metadata.isEmpty) {
          throw Exception("Class '${schemaClass.name}' has a non RealmProperty type field '${field.name}'");
        }

        if (field.type.element!.name == "dynamic") {
          throw Exception("Class '${schemaClass.name}' has a dynamic type field '${field.name}'");
        }

        var fieldTypeName = field.type.element!.name;
        if (fieldTypeName!.startsWith('_')) {
          fieldTypeName = fieldTypeName.substring(1);
        }

        // else if (field.type.isDartCoreInt) {

        // }
        // else if (field.type.isDartCoreDouble) {

        // }
        // else if (field.type.isDartCoreBool) {

        // }

        for (var meta in field.metadata) {
          if (meta.element!.enclosingElement!.name != "RealmProperty") {
            continue;
          }

          //copy the @RealmProperty anotation
          var realmPropertyDefiniton = meta.toSource();
          generated.writeln("$realmPropertyDefiniton");

          String? listTypeArumentName = "";
          if (fieldTypeName == "List") {
            InterfaceType fieldType = field.type as InterfaceType;
            var listTypeArument = fieldType.typeArguments[0].element;
            listTypeArumentName = listTypeArument!.name;
            var isDartType = listTypeArumentName == "String" ||
              listTypeArumentName == "int" ||
              listTypeArumentName == "double" ||
              listTypeArumentName == "bool";

            // if (field.type.element.name == "dynamic") {
            //   throw new Exception("Class '${schemaClass.name}' has a List<dynamic> type field '${field.displayName}'");
            // }

            //TODO: could read the source and try to extract the type T from List<T>
            //the source is available here or from
            //String source = field.source.contents.data;
            //see also [AnalysisContext.getContents]
            //also field.session has an
            //int offs = field.declaration.nameOffset;
            //field.declaration.linkedNode.parent.childEntities.first.typeArguments.arguments.single.name.name == 'Car' //when List<Car>
            //field.session.getParsedUnit(field.source.fullName)

            if (!isDartType && !listTypeArumentName!.startsWith("_")) {
              throw Exception(
                  "Field ${schemaClass.name}.${field.name} has an inavlid type ${field.type.toString()}. Type parameter name should start with '_' and be a RealmObject schema type");
            }

            if (listTypeArumentName!.startsWith("_")) {
              listTypeArumentName = listTypeArumentName.substring(1);
            }

            //generate
            //String get make => super['make'];
            generated
                .writeln("$fieldTypeName<$listTypeArumentName> get ${field.name} => this.super_get<$listTypeArumentName>('${field.name}');");

            //generate
            //set name(String value) => super["name"] = value;
            generated.writeln(
                "set ${field.name}($fieldTypeName<$listTypeArumentName> value) => this.super_set<$listTypeArumentName>('${field.name}', value);");
          } else {
            //generate
            //String get make => super['make'];
            generated.writeln("$fieldTypeName get ${field.name} => super['${field.name}'] as $fieldTypeName;");

            //generate
            //set name(String value) => super["name"] = value;
            generated.writeln("set ${field.name}($fieldTypeName value) => super['${field.name}'] = value;");
          }
          //empty line between fields
          generated.writeln();

          //generte get _schema property
          //generated.writeln("dynamic get _schema {");
          //generated.writeln("var schema = RealmObject.getSchema('${className}', [");

          //infer the type of the object
          var schemaPropertyDefinition = "SchemaProperty('${field.name}', ";

          //if not RealmProperty.type is given. Try to infer the type
          if (!realmPropertyDefiniton.contains("type:")) {
            //normalize string to realm string
            if (field.type.isDartCoreString) {
              fieldTypeName = "string";
            }

            var inferredTypeDefinition = "type: '$fieldTypeName',";
            if (fieldTypeName == "List") {
              if (listTypeArumentName == "String") {
                listTypeArumentName = "string";
              }
              inferredTypeDefinition = "type: '$listTypeArumentName[]',";
            }

            //schemaPropertyName.replaceFirst(")", ")")
            schemaPropertyDefinition += inferredTypeDefinition;
            //schemaPropertyDefinition = "SchemaProperty('${field.name}', ${inferredTypeDefinition},";
            //schemaPropertyDefinition = schemaPropertyDefinition.replaceFirst(",", ",${inferredTypeDefinition},");
            //schemaPropertyDefinition = schemaPropertyDefinition.replaceFirst(', ', ' ');
          }

          var schemaPropertyName = realmPropertyDefiniton.replaceFirst("@RealmProperty(", schemaPropertyDefinition);
          schemaPropertyName = schemaPropertyName.replaceFirst(",)", ")");
          getSchemaPropertyBuffer.writeln("$schemaPropertyName,");
        }
      }

      getSchemaPropertyBuffer.writeln("]);");
      getSchemaPropertyBuffer.writeln("}");

      //end class
      generated.writeln(getSchemaPropertyBuffer.toString());
      generated.writeln("}");
    }

    //String fileName = library.element.definingCompilationUnit.librarySource.shortName;
    //fileName = fileName.replaceAll(".dart", ".g.dart");

    // String generated = """part '${fileName}'; \n
    //                   """;
    //return generated;
    return generated.toString();
  }
}
