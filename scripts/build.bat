@ECHO OFF

@REM Output is in PROJECT_ROOT\binary directory 
@REM example usage: ....\realm-dart>scripts\build.bat

@REM Start in the root directory of the project.
pushd "%~dp0.."
echo %CD%
SET PROJECT_ROOT=%CD%

mkdir %PROJECT_ROOT%\build-windows 
pushd %PROJECT_ROOT%\build-windows 

SET EXIT_CODE=0

cmake ^
    -G "Visual Studio 16 2019" ^
    -A x64 ^
    -DCMAKE_TOOLCHAIN_FILE="%PROJECT_ROOT%/src/realm-core/tools/vcpkg/ports/scripts/buildsystems/vcpkg.cmake" ^
    -DVCPKG_MANIFEST_DIR="%PROJECT_ROOT%/src/realm-core/tools/vcpkg" ^
    -DVCPKG_TARGET_TRIPLET="x64-windows-static" ^
    %PROJECT_ROOT%

IF %ErrorLevel% NEQ 0 (
 SET EXIT_CODE=%ErrorLevel%
 GOTO popd_all
)

cmake --build . --config MinSizeRel

IF %ErrorLevel% NEQ 0 (
 SET EXIT_CODE=%ErrorLevel%
 GOTO popd_all
)


@REM exit to caller's location with success
:popd_all
popd && goto popd_all || exit /b %EXIT_CODE%