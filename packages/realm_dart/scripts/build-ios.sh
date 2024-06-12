#!/usr/bin/env bash

set -e
set -o pipefail

# Start in the root directory of the project.
cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)
SCRIPT=$(basename "${BASH_SOURCE[0]}")

function usage {
    echo "Usage: ${SCRIPT} [-c <configuration>] [<platforms>]"
    echo ""
    echo "Arguments:"
    echo "   -c : build configuration (Debug or Release)"
    echo "   <platforms> : platforms to build for (ios, or simulator)"
    echo "                                                                     "
    echo "Environment variables:"
    echo "  REALM_USE_CCACHE=TRUE - enables ccache builds"
    exit 1;
}

CONFIGURATION=Release
SUPPORT_PLATFORMS=(ios simulator) # flutter doesn't support maccatalyst

function is_supported_platform(){
    for platform in "${SUPPORT_PLATFORMS[@]}"; do
        [[ "${platform}" == $1 ]] && return 0
    done
    return 1
}

# Parse the options
while getopts ":c:" opt; do
    case "${opt}" in
        c) CONFIGURATION=${OPTARG};;
        *) usage;;
    esac
done

shift $((OPTIND-1))
PLATFORMS=($@)

if [ -z ${PLATFORMS} ]; then
    echo "No platform given. building for all supported platforms...";
    PLATFORMS=(ios simulator)
else
    echo "Building for...";
    for check_platform in "${PLATFORMS[@]}"; do
        if ! is_supported_platform $check_platform; then
            echo "${check_platform} is not a supported platform"
            usage
            exit 1
        fi
        echo ${check_platform};
    done
fi

cmake --preset ios

FRAMEWORKS=()
BUILD_LIB_CMDS=()
for platform in "${PLATFORMS[@]}"; do
    case "$platform" in
        ios)
            cmake --build --preset ios-device --config $CONFIGURATION
            FRAMEWORKS+=(-framework ./binary/ios/$CONFIGURATION-iphoneos/realm_dart.framework)
        ;;
        simulator)
            cmake --build --preset ios-simulator --config $CONFIGURATION
            FRAMEWORKS+=(-framework ./binary/ios/$CONFIGURATION-iphonesimulator/realm_dart.framework)
        ;;
        *)
            echo "${platform} not supported"
            usage
            exit 1
        ;;
    esac
done

# clean binary output directory
rm -rf ./binary/ios/realm_dart.xcframework

# build an xcframework
xcodebuild -create-xcframework \
    "${FRAMEWORKS[@]}" \
    -output ./binary/ios/realm_dart.xcframework
