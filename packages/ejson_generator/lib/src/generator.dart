// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:ejson_analyzer/ejson_analyzer.dart';
import 'package:ejson_generator/ejson_generator.dart';
import 'package:source_gen/source_gen.dart';

extension on EJsonError {
  String get message => switch (this) {
        EJsonError.tooManyAnnotatedConstructors => 'Too many annotated constructors',
        EJsonError.missingGetter => 'Missing getter',
        EJsonError.mismatchedGetterType => 'Mismatched getter type',
        EJsonError.tooManyConstructorsOnAnnotatedClass => 'Too many constructors on annotated class',
        EJsonError.noExplicitConstructor => 'No explicit constructor',
      };

  Never raise() {
    throw EJsonSourceError._(this);
  }
}

class EJsonSourceError extends InvalidGenerationSourceError {
  final EJsonError error;
  EJsonSourceError._(this.error) : super(error.message);
}

/// @nodoc
class EJsonGenerator extends Generator {
  const EJsonGenerator();

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    // find all classes with annotated constructors or classes directly annotated
    final annotated = library.classes.map((cls) => (cls, cls.constructors.where((ctor) => isEJsonAnnotated(ctor)))).where((element) {
      final (cls, ctors) = element;
      return ctors.isNotEmpty || isEJsonAnnotated(cls);
    });

    return annotated.map((x) {
      final (cls, annotatedCtors) = x;
      final className = cls.name;

      if (annotatedCtors.length > 1) {
        EJsonError.tooManyAnnotatedConstructors.raise();
      }

      if (annotatedCtors.isEmpty) {
        // class is directly annotated, and no constructors are annotated.
        final annotation = getEJsonAnnotation(cls);
        if (annotation.decoder != null && annotation.encoder != null) {
          return ''; // class has custom defined encoder and decoder
        }
        if (cls.constructors.length > 1) {
          EJsonError.tooManyConstructorsOnAnnotatedClass.raise();
        }
      }

      final ctor = annotatedCtors.singleOrNull ?? cls.constructors.singleOrNull;
      if (ctor == null) {
        // class is annotated, but has no explicit constructors
        EJsonError.noExplicitConstructor.raise();
      }

      for (final p in ctor.parameters) {
        // check that all ctor parameters have a getter with the same name and type
        final getter = cls.getGetter(p.name);
        if (getter == null) {
          EJsonError.missingGetter.raise();
        }
        if (!TypeChecker.fromStatic(p.type).isAssignableFromType(getter.returnType)) {
          EJsonError.mismatchedGetterType.raise();
        }
      }

      // generate the codec pair
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
              ${ctor.parameters.map((p) => "${p.isNamed ? '${p.name} : ' : ''}fromEJson(${p.name})").join(',\n')}
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
