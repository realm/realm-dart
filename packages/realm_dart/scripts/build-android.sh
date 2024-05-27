#!/usr/bin/env bash

set -e
set -o pipefail

# ANDROID_NDK and ANDROID_HOME variables should be set
# ninja path is hardcoded since at the moment there is only one ninja version distributed with the Android SDK
# Output is in PROJECT_DIR/binary directory 
# example usage: ../realm-dart$./scripts/build-android.sh all

if [ -z ${ANDROID_HOME} ]; then
    echo "Environment variable ANDROID_HOME not set.";
    exit 64 # Exit code 64 indicates a usage error.
fi

if [ -z ${ANDROID_NDK} ]; then
    echo "Environment variable ANDROID_NDK not set.";
    exit 64 # Exit code 64 indicates a usage error.
fi

# Start in the root directory of the project.
cd "$(dirname "$0")/.."

ABIS=(x86_64 armeabi-v7a arm64-v8a)

# only building for arm64-v8a if no arguments
if [ $# -eq 0 ]; then
    ABIS=arm64-v8a)
fi

for abi in "${ABIS[@]}"; do
    cmake --preset android-$abi
    cmake --build --preset android-$abi --config MinSizeRel --target strip
done
