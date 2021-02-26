# Flutter runtime diff

The preview version of Realm SDK for Flutter™ requires a custom Flutter runtime. The changes are kept to a minimum and consist of exposing some of the Dart VM APIs which are hidden in the official Flutter engine.

The preview version of Realm SDK for Dart™ does not need a custom engine since the required Dart VM APIs are qpublic in the official Dart VM.

This directory conatins a diff file for all the changes made.


The base Flutter engine version is https://github.com/flutter/engine/commit/a6c0959d1ac8cdfe6f9ff87892bc4905a73699fe
The base Dart runtime version is https://github.com/dart-lang/sdk/commit/2ea318b540948b55306bf82fd34b2c84ec634f48
