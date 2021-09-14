cmake ^
    -G "Visual Studio 16 2019" ^
    -T host=x86 ^
    -A x64 ^
    ..\

cmake --build .