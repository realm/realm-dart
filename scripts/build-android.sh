#!/usr/bin/env bash

set -e
set -o pipefail

# ANDROID_NDK and ANDROID_HOME variables should be set
# ninja path is hardcoded since at the moment there is only one ninja version distributed with the Android SDK
# Output is in PROJECT_DIR/binary directory 
# example usage: ../realm-dart$./scripts/build-android.sh all


# Start in the root directory of the project.
cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)

mkdir -p build-android

# build for x86 first to optimize for emulator testing

# rmdir /s /q x86
mkdir x86
pushd x86

cmake \
    -GNinja \
    -DANDROID_NDK=$ANDROID_NDK \
    -DANDROID_ABI=x86 \
    -DCMAKE_MAKE_PROGRAM=$ANDROID_HOME/cmake/3.10.2.4988404/bin/ninja \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
    -DANDROID_TOOLCHAIN=clang \
    -DANDROID_NATIVE_API_LEVEL=16 \
    -DCMAKE_BUILD_TYPE=MinSizeRel \
    -DANDROID_ALLOW_UNDEFINED_SYMBOLS=1 \
    -DANDROID_STL=c++_static \
    $PROJECT_ROOT

cmake --build .
popd

# only building for x86 if no arguments
if [ $# -eq 0 ]
    then
        exit 0
fi

# rmdir /s /q armeabi-v7a
mkdir armeabi-v7a
pushd armeabi-v7a

cmake \
    -GNinja \
    -DANDROID_NDK=$ANDROID_NDK \
    -DANDROID_ABI=armeabi-v7a \
    -DCMAKE_MAKE_PROGRAM=$ANDROID_HOME/cmake/3.10.2.4988404/bin/ninja \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
    -DANDROID_TOOLCHAIN=clang \
    -DANDROID_NATIVE_API_LEVEL=16 \
    -DCMAKE_BUILD_TYPE=MinSizeRel \
    -DANDROID_ALLOW_UNDEFINED_SYMBOLS=1 \
    -DANDROID_STL=c++_static \
    $PROJECT_ROOT

cmake --build .
popd

# rmdir /s /q arm64-v8a
mkdir arm64-v8a
pushd arm64-v8a

cmake \
    -GNinja \
    -DANDROID_NDK=$ANDROID_NDK \
    -DANDROID_ABI=arm64-v8a \
    -DCMAKE_MAKE_PROGRAM=$ANDROID_HOME/cmake/3.10.2.4988404/bin/ninja \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
    -DANDROID_TOOLCHAIN=clang \
    -DANDROID_NATIVE_API_LEVEL=16 \
    -DCMAKE_BUILD_TYPE=MinSizeRel \
    -DANDROID_ALLOW_UNDEFINED_SYMBOLS=1 \
    -DANDROID_STL=c++_static \
    $PROJECT_ROOT

cmake --build .
popd

# rmdir /s /q x86_64
mkdir x86_64
pushd x86_64

cmake \
    -GNinja \
    -DANDROID_NDK=$ANDROID_NDK \
    -DANDROID_ABI=x86_64 \
    -DCMAKE_MAKE_PROGRAM=$ANDROID_HOME/cmake/3.10.2.4988404/bin/ninja \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
    -DANDROID_TOOLCHAIN=clang \
    -DANDROID_NATIVE_API_LEVEL=16 \
    -DCMAKE_BUILD_TYPE=MinSizeRel \
    -DANDROID_ALLOW_UNDEFINED_SYMBOLS=1 \
    -DANDROID_STL=c++_static \
    $PROJECT_ROOT

cmake --build .
popd