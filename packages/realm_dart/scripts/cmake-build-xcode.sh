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

# TODO: allow code signing once we setup certificates on CI.
# Otherwise, Xcode 15 will use an empty identifier, which will then be rejected when the app is submitted to the app store.
# See https://github.com/realm/realm-dart/issues/1679 for more details.
xcodebuild "${XCODEBUILD_ARGS[@]}" CODE_SIGNING_ALLOWED=NO
