// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: implementation_imports

import 'dart:mirrors';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type_visitor.dart';
import 'package:analyzer/src/dart/element/display_string_builder.dart';
import 'package:analyzer/src/dart/element/type.dart';

// Used to represent a type that is not yet defined, such as the mapped type of a realm model (ie. A for _A)
// Hopefully we can get rid of this when static meta programming lands
class PseudoType extends TypeImpl {
  @override
  final NullabilitySuffix nullabilitySuffix;
  final String _name;

  PseudoType(this._name, {this.nullabilitySuffix = NullabilitySuffix.none});

  Never get _never => throw UnimplementedError();

  @override
  R accept<R>(TypeVisitor<R> visitor) => _never;

  @override
  R acceptWithArgument<R, A>(TypeVisitorWithArgument<R, A> visitor, A argument) => _never;

  @override
  void appendTo(ElementDisplayStringBuilder builder) {
    // Use reflection to call private methods:
    //
    //  builder._write(_name);
    //  builder._writeNullability(nullabilitySuffix);

    final im = reflect(builder);

    // Private Symbols are suffixed with a secret '@<some int>'
    // .. hence this ugly trick ヽ(ಠ_ಠ)ノ
    final writeSymbol = im.type.instanceMembers.keys.firstWhere((m) => '$m'.contains('"_write"'));
    im.invoke(writeSymbol, <dynamic>[_name]); // #_write won't work

    final writeNullability = im.type.instanceMembers.keys.firstWhere((m) => '$m'.contains('"_writeNullability"'));
    im.invoke(writeNullability, <dynamic>[nullabilitySuffix]); // #_writeNullability won't work
  }

  @override
  String? get name => _never;

  @override
  PseudoType withNullability(NullabilitySuffix nullabilitySuffix) {
    return PseudoType(_name, nullabilitySuffix: nullabilitySuffix);
  }

  @override
  Element? get element2 => _never;

  @override
  Element? get element => null;
}
