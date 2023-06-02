////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 Realm Inc.
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

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:ejson_annotation/ejson_annotation.dart';
import 'package:ejson_generator/ejson_generator.dart';
import 'package:source_gen/source_gen.dart';

extension on EJsonError {
  String get message => switch (this) {
        EJsonError.tooManyAnnotatedConstructors =>
          'Too many annotated constructors',
        EJsonError.missingGetter => 'Missing getter',
        EJsonError.mismatchedGetterType => 'Mismatched getter type',
      };

  Never raise() {
    throw EJsonSourceError(this);
  }
}

class EJsonSourceError extends InvalidGenerationSourceError {
  final EJsonError error;
  EJsonSourceError(this.error) : super(error.message);
}

/// @nodoc
class EJsonGenerator extends Generator {
  const EJsonGenerator();

  TypeChecker get typeChecker => TypeChecker.fromRuntime(EJson);

  bool _isAnnotated(Element element) =>
      typeChecker.hasAnnotationOfExact(element);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    // find all classes with annotated constructors or classes directly annotated
    final annotated = library.classes
        .map((cls) =>
            (cls, cls.constructors.where((ctor) => _isAnnotated(ctor))))
        .where((element) {
      final (cls, ctors) = element;
      return ctors.isNotEmpty || _isAnnotated(cls);
    });

    //buildStep.

    return annotated.map((x) {
      final (cls, ctors) = x;
      final className = cls.name;

      if (ctors.length > 1) {
        EJsonError.tooManyAnnotatedConstructors.raise();
      }

      if (ctors.isEmpty) {
        // TODO!
      }

      final ctor = ctors.single;

      for (final p in ctor.parameters) {
        final getter = cls.getGetter(p.name);
        if (getter == null) {
          EJsonError.missingGetter.raise();
        }
        if (getter.returnType != p.type) {
          EJsonError.mismatchedGetterType.raise();
        }
      }

      log.info('Generating EJson for $className');
      return '''
        EJsonValue encode$className($className value) {
          return {
            ${ctor.parameters.map((p) => "'${p.name}': value.${p.name}.toEJson()").join(',\n')}
          };
        }

        $className decode$className(EJsonValue ejson) {
          return switch (ejson) {
              ${decodePattern(ctor.parameters)} => $className${ctor.name.isEmpty ? '' : '.${ctor.name}'}(
              ${ctor.parameters.map((p) => "${p.isNamed ? '${p.name} : ' : ''}${p.name}.to<${p.type}>()").join(',\n')}
            ),
            _ => raiseInvalidEJson(ejson),
          };
        }

        extension ${className}EJsonEncoderExtension on $className {
          @pragma('vm:prefer-inline')
          EJsonValue toEJson() => encode$className(this);
        }
      ''';
    }).join('\n\n');
  }
}

String decodePattern(Iterable<ParameterElement> parameters) {
  if (parameters.isEmpty) {
    return 'Map m when m.isEmpty';
  }
  return '''{
    ${parameters.map((p) => "'${p.name}': EJsonValue ${p.name}").join(',\n')} 
  }''';
}
