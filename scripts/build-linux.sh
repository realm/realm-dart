#!/usr/bin/env bash

set -e
set -o pipefail

# Start in the root directory of the project.
cd "$(dirname "$0")/.."

mkdir -p build-linux
pushd build-linux

cmake -GNinja ..

cmake --build .