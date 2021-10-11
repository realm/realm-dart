@REM @ECHO OFF

@REM Output is in PROJECT_ROOT\binary directory 
@REM example usage: ....\realm-dart>scripts\build.bat

@REM Start in the root directory of the project.
pushd "%~dp0.."
echo %CD%
SET PROJECT_ROOT=%CD%

mkdir %PROJECT_ROOT%\build-windows 
pushd %PROJECT_ROOT%\build-windows 

cmake ^
    -G "Visual Studio 16 2019" ^
    -A x64 ^
    %PROJECT_ROOT%

cmake --build . --config MinSizeRel

@REM exit to caller's location
:popd_all
popd && goto popd_all