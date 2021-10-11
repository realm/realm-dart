@ECHO OFF

@REM ANDROID_NDK and ANDROID_HOME variables should be set
@REM ninja path is hardcoded since at the moment there is only one ninja version distributed with the Android SDK
@REM Output is in PROJECT_ROOT\binary directory 
@REM Output is in PROJECT_ROOT\binary directory 
@REM example usage: ....\realm-dart>scripts\build-android.bat all

@REM Start in the root directory of the project.
pushd "%~dp0.."
echo %CD%
SET PROJECT_ROOT=%CD%

mkdir %PROJECT_ROOT%\build-android 
pushd %PROJECT_ROOT%\build-android 


@REM build for x86 first to optimize for emulator testing

@REM rmdir /s /q x86
mkdir x86
pushd x86

cmake.exe ^
    -GNinja ^
    -DANDROID_NDK=%ANDROID_NDK% ^
    -DANDROID_ABI=x86 ^
    -DCMAKE_MAKE_PROGRAM=%ANDROID_HOME%\cmake\3.10.2.4988404\bin\ninja.exe ^
    -DCMAKE_TOOLCHAIN_FILE=%ANDROID_NDK%\build\cmake\android.toolchain.cmake ^
    -DANDROID_TOOLCHAIN=clang ^
    -DANDROID_NATIVE_API_LEVEL=16 ^
    -DCMAKE_BUILD_TYPE=MinSizeRel ^
    -DANDROID_ALLOW_UNDEFINED_SYMBOLS=1 ^
    -DANDROID_STL=c++_static ^
    %PROJECT_ROOT%

cmake --build .
popd

if [%1]==[] goto popd_all

@REM rmdir /s /q armeabi-v7a
mkdir armeabi-v7a
pushd armeabi-v7a

cmake.exe ^
    -GNinja ^
    -DANDROID_NDK=%ANDROID_NDK% ^
    -DANDROID_ABI=armeabi-v7a ^
    -DCMAKE_MAKE_PROGRAM=%ANDROID_HOME%\cmake\3.10.2.4988404\bin\ninja.exe ^
    -DCMAKE_TOOLCHAIN_FILE=%ANDROID_NDK%/build/cmake/android.toolchain.cmake ^
    -DANDROID_TOOLCHAIN=clang ^
    -DANDROID_NATIVE_API_LEVEL=16 ^
    -DCMAKE_BUILD_TYPE=MinSizeRel ^
    -DANDROID_ALLOW_UNDEFINED_SYMBOLS=1 ^
    -DANDROID_STL=c++_static ^
    %PROJECT_ROOT%

cmake --build .
popd

@REM rmdir /s /q arm64-v8a
mkdir arm64-v8a
pushd arm64-v8a

cmake.exe ^
    -GNinja ^
    -DANDROID_NDK=%ANDROID_NDK% ^
    -DANDROID_ABI=arm64-v8a ^
    -DCMAKE_MAKE_PROGRAM=%ANDROID_HOME%\cmake\3.10.2.4988404\bin\ninja.exe ^
    -DCMAKE_TOOLCHAIN_FILE=%ANDROID_NDK%/build/cmake/android.toolchain.cmake ^
    -DANDROID_TOOLCHAIN=clang ^
    -DANDROID_NATIVE_API_LEVEL=16 ^
    -DCMAKE_BUILD_TYPE=MinSizeRel ^
    -DANDROID_ALLOW_UNDEFINED_SYMBOLS=1 ^
    -DANDROID_STL=c++_static ^
    %PROJECT_ROOT%

cmake --build .
popd

@REM rmdir /s /q x86_64
mkdir x86_64
pushd x86_64

cmake.exe ^
    -GNinja ^
    -DANDROID_NDK=%ANDROID_NDK% ^
    -DANDROID_ABI=x86_64 ^
    -DCMAKE_MAKE_PROGRAM=%ANDROID_HOME%\cmake\3.10.2.4988404\bin\ninja.exe ^
    -DCMAKE_TOOLCHAIN_FILE=%ANDROID_NDK%/build/cmake/android.toolchain.cmake ^
    -DANDROID_TOOLCHAIN=clang ^
    -DANDROID_NATIVE_API_LEVEL=16 ^
    -DCMAKE_BUILD_TYPE=MinSizeRel ^
    -DANDROID_ALLOW_UNDEFINED_SYMBOLS=1 ^
    -DANDROID_STL=c++_static ^
     %PROJECT_ROOT%

cmake --build .
popd


@REM exit to caller's location
:popd_all
popd && goto popd_all