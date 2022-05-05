@ECHO OFF

@REM ANDROID_NDK should be set
@REM Output is in PROJECT_ROOT\binary directory
@REM example usage: ....\realm-dart>scripts\build-android.bat all

@REM Start in the root directory of the project.
pushd "%~dp0.."
echo %CD%

@REM only building for x86 if no arguments
set ABIS=x86 x86_64 armeabi-v7a arm64-v8a
if [%1]==[] set ABIS=x86

(for %%a in (%ABIS%) do (
    cmake --preset android-%%a
    cmake --build --preset android-%%a --config MinSizeRel --target strip
))
