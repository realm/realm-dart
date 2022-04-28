#!/usr/bin/env bash

set -e
set -o pipefail

# Start in the root directory of the project.
cd "$(dirname "$0")/.."

cmake --preset macos
cmake --build --preset macos --config MinSizeRel -- -destination "generic/platform=macOS"
