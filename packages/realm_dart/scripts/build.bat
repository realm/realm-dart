@ECHO OFF

@REM Output is in PROJECT_ROOT\binary directory 
@REM example usage: ....\realm-dart>scripts\build.bat

@REM Start in the root directory of the project.
pushd "%~dp0.."
echo %CD%

@REM only building for x64 if no arguments
set ABIS=x64 arm64
if [%1]==[] set ABIS=x64

(for %%a in (%ABIS%) do (
    cmake --preset windows-%%a
    cmake --build --preset windows-%%a --config MinSizeRel
))