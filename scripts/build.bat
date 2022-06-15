@ECHO OFF

@REM Output is in PROJECT_ROOT\binary directory 
@REM example usage: ....\realm-dart>scripts\build.bat

@REM Start in the root directory of the project.
pushd "%~dp0.."
echo %CD%

cmake --preset windows
cmake --build --preset windows --config Debug
