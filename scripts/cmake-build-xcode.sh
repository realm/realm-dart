#!/usr/bin/env bash

set -eo pipefail

XCODEBUILD_ARGS=()
for arg in "$@"
do
    if [ "$arg" = "-target" ]; then
        arg="-scheme"
    fi
    XCODEBUILD_ARGS+=("$arg")
done

xcodebuild "${XCODEBUILD_ARGS[@]}"
