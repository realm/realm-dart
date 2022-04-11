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
    echo "   <platforms> : platforms to build for (catalyst, ios, or simulator)"
    echo "                                                                     "
    echo "Environment variables:"
    echo "  REALM_USE_CCACHE=TRUE - enables ccache builds"
    exit 1;
}

CONFIGURATION=Release
SUPPORT_PLATFORMS=(catalyst ios simulator)

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
    echo "No platform given. building all platforms...";
    PLATFORMS=(ios catalyst simulator)
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

DESTINATIONS=()
LIBRARIES=()
BUILD_LIB_CMDS=()
for platform in "${PLATFORMS[@]}"; do
    case "$platform" in 
        ios)
            DESTINATIONS+=(-destination 'generic/platform=iOS')
            LIBRARIES+=(-library ./out/$CONFIGURATION-iphoneos/librealm_flutter_ios.a -headers ./_include)
            BUILD_LIB_CMDS+=("xcrun libtool -static -o ./out/$CONFIGURATION-iphoneos/librealm_flutter_ios.a ./out/$CONFIGURATION-iphoneos/*.a")
        ;;
        catalyst)
            DESTINATIONS+=(-destination 'platform=macOS,arch=x86_64,variant=Mac Catalyst')
            LIBRARIES+=(-library ./out/$CONFIGURATION-maccatalyst/librealm_flutter_ios.a -headers ./_include)
            BUILD_LIB_CMDS+=("xcrun libtool -static -o ./out/$CONFIGURATION-maccatalyst/librealm_flutter_ios.a ./out/$CONFIGURATION-maccatalyst/*.a")
        ;;
        simulator)
            DESTINATIONS+=(-destination 'generic/platform=iOS Simulator')
            LIBRARIES+=(-library ./out/$CONFIGURATION-iphonesimulator/librealm_flutter_ios.a -headers ./_include)
            BUILD_LIB_CMDS+=("xcrun libtool -static -o ./out/$CONFIGURATION-iphonesimulator/librealm_flutter_ios.a ./out/$CONFIGURATION-iphonesimulator/*.a")
        ;;
        *)
            echo "${platform} not supported"
            usage
            exit 1
        ;;
    esac
done

mkdir -p build-ios
pushd build-ios



# Configure CMake project
cmake "$PROJECT_ROOT" -GXcode \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_TOOLCHAIN_FILE="$PROJECT_ROOT/src/realm-core/tools/cmake/xcode.toolchain.cmake" \
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="$(pwd)/out/$<CONFIG>\$EFFECTIVE_PLATFORM_NAME"
    

# The above command cmake --build does the same as this one
xcodebuild build \
    -scheme realm_dart \
    "${DESTINATIONS[@]}" \
    -configuration $CONFIGURATION \
    ONLY_ACTIVE_ARCH=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SUPPORTS_MACCATALYST=YES

for cmd in "${BUILD_LIB_CMDS[@]}"; do
    eval "${cmd}"
done

mkdir -p _include/realm_dart_ios
cp "$PROJECT_ROOT"/src/realm-core/src/realm.h _include/realm_dart_ios/
cp "$PROJECT_ROOT"/src/realm_dart.h _include/realm_dart_ios/
cp "$PROJECT_ROOT"/src/realm_dart_scheduler.h _include/realm_dart_ios/
cp -r "$PROJECT_ROOT"/src/dart-include _include/realm_dart_ios/


# clean binary output directory
rm -rf ../binary/ios/realm_flutter_ios.xcframework

# build an xcframework
xcodebuild -create-xcframework \
    "${LIBRARIES[@]}" \
    -output ../binary/ios/realm_flutter_ios.xcframework
