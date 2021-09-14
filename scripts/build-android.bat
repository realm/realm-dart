@REM This scripts assumes in-source building where the project directory is one dir up. 
@REM Output is in PROJECT_DIR\binary directory 
@REM example usage: ....\realm-dart\build-android>..\scripts\build-android.bat all

@REM rmdir /s /q x86

mkdir x86
cd x86

cmake.exe ^
    -GNinja ^
    -DANDROID_NDK=%ANDROID_NDK% ^
    -DANDROID_ABI=x86 ^
    -DCMAKE_MAKE_PROGRAM=ninja ^
    -DCMAKE_TOOLCHAIN_FILE=%ANDROID_NDK%/build/cmake/android.toolchain.cmake ^
    -DANDROID_TOOLCHAIN=clang ^
    -DANDROID_NATIVE_API_LEVEL=16 ^
    -DCMAKE_BUILD_TYPE=MinSizeRel ^
    -DANDROID_ALLOW_UNDEFINED_SYMBOLS=1 ^
    -DANDROID_STL=c++_static ^
    ..\..\

cmake --build .
cd ..

if [%1]==[] exit /B 0

@REM rmdir /s /q armeabi-v7a
mkdir armeabi-v7a
cd armeabi-v7a

cmake.exe ^
    -GNinja ^
    -DANDROID_NDK=%ANDROID_NDK% ^
    -DANDROID_ABI=armeabi-v7a ^
    -DCMAKE_MAKE_PROGRAM=ninja ^
    -DCMAKE_TOOLCHAIN_FILE=%ANDROID_NDK%/build/cmake/android.toolchain.cmake ^
    -DANDROID_TOOLCHAIN=clang ^
    -DANDROID_NATIVE_API_LEVEL=16 ^
    -DCMAKE_BUILD_TYPE=MinSizeRel ^
    -DANDROID_ALLOW_UNDEFINED_SYMBOLS=1 ^
    -DANDROID_STL=c++_static ^
    ..\..\

cmake --build .
cd ..

@REM rmdir /s /q arm64-v8a
mkdir arm64-v8a
cd arm64-v8a

cmake.exe ^
    -GNinja ^
    -DANDROID_NDK=%ANDROID_NDK% ^
    -DANDROID_ABI=arm64-v8a ^
    -DCMAKE_MAKE_PROGRAM=ninja ^
    -DCMAKE_TOOLCHAIN_FILE=%ANDROID_NDK%/build/cmake/android.toolchain.cmake ^
    -DANDROID_TOOLCHAIN=clang ^
    -DANDROID_NATIVE_API_LEVEL=16 ^
    -DCMAKE_BUILD_TYPE=MinSizeRel ^
    -DANDROID_ALLOW_UNDEFINED_SYMBOLS=1 ^
    -DANDROID_STL=c++_static ^
    ..\..\

cmake --build .
cd ..

@REM rmdir /s /q x86_64
mkdir x86_64
cd x86_64

cmake.exe ^
    -GNinja ^
    -DANDROID_NDK=%ANDROID_NDK% ^
    -DANDROID_ABI=x86_64 ^
    -DCMAKE_MAKE_PROGRAM=ninja ^
    -DCMAKE_TOOLCHAIN_FILE=%ANDROID_NDK%/build/cmake/android.toolchain.cmake ^
    -DANDROID_TOOLCHAIN=clang ^
    -DANDROID_NATIVE_API_LEVEL=16 ^
    -DCMAKE_BUILD_TYPE=MinSizeRel ^
    -DANDROID_ALLOW_UNDEFINED_SYMBOLS=1 ^
    -DANDROID_STL=c++_static ^
    ..\..\

cmake --build .
cd ..