# Flutter runtime diff

The preview version of Realm SDK for Flutter™ requires a custom Flutter runtime. The changes are kept to a minimum and consist of exposing some of the Dart VM APIs which are hidden in the official Flutter engine.

The preview version of Realm SDK for Dart™ does not need a custom engine since the required Dart VM APIs are qpublic in the official Dart VM.

This directory contains a diff file for all the changes made.


The base Flutter 2.0 engine version is https://github.com/flutter/engine/commit/40441def692f444660a11e20fac37af9050245ab

The base Dart runtime version is https://github.com/dart-lang/sdk/commit/72c1995001d1214138a8186032f2199f237bc505


## Building the engine
~/flutter/engine/src$ flutter/tools/gn --android --android-cpu=x86 --runtime-mode=jit_release
~/flutter/engine/src$ ninja -C out/android_jit_release_x86
