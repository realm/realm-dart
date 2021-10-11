@REM This scripts assumes in-source building where the project directory is one dir up. 
@REM Output is in PROJECT_DIR\binary directory 
@REM example usage: ....\realm-dart\build>..\scripts\build.bat

cmake ^
    -G "Visual Studio 16 2019" ^
    -T host=x86 ^
    -A x64 ^
    ..\

cmake --build . --config MinSizeRel