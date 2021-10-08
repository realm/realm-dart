#!/usr/bin/env bash

set -e
set -o pipefail

# Start in the root directory of the project.
cd "$(dirname "$0")/.."

mkdir -p build-macos
pushd build-macos

cmake -G Xcode \
      ..

cmake --build . --config MinSizeRel