//
// Created by lubo on 2020-05-11.
//

#ifndef ANDROID_DART_IO_EXTENSIONS_H
#define ANDROID_DART_IO_EXTENSIONS_H

//#define DART_EXTENSION_EXPORT __attribute__ ((visibility ("default")))  __attribute((used))

typedef void (*Dart_ExtensionInitCallback)();
DART_EXPORT bool Dart_SetInitCallback(Dart_ExtensionInitCallback callback);

#endif //ANDROID_DART_IO_EXTENSIONS_H
