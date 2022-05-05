#!/usr/bin/env bash

set -e
set -o pipefail

# Start in the root directory of the project.
cd "$(dirname "$0")/.."

cmake --preset linux
cmake --build --preset linux --config MinSizeRel
