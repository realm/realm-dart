#!/usr/bin/env bash

set -e
set -o pipefail

# Start in the root directory of the project.
cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)

mkdir -p build-macos
pushd build-macos

cmake -G Xcode \
      -DCMAKE_TOOLCHAIN_FILE="$PROJECT_ROOT/src/realm-core/tools/cmake/xcode.toolchain.cmake" \
      -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
      -DCMAKE_SYSTEM_NAME=Darwin \
      -DCMAKE_OSX_ARCHITECTURES="x86_64" \ #to enable apple silicon -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" \
      ..

cmake --build . --config MinSizeRel