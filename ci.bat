@echo off
setlocal

echo === CI: Start ===

REM Delete existing build directory if it exists
if exist "build" (
    echo Deleting existing build directory...
    rmdir /s /q "build"
    if errorlevel 1 (
        echo Failed to remove existing build directory.
        goto :fail
    )
) else (
    echo No existing build directory found.
)

REM Create and enter build directory
echo Creating build directory...
mkdir "build"
if errorlevel 1 (
    echo Failed to create build directory.
    goto :fail
)

echo Entering build directory...
pushd "build"
if errorlevel 1 (
    echo Failed to enter build directory.
    goto :fail
)

REM Configure with CMake
echo Configuring project with: cmake ..
cmake ..
if errorlevel 1 (
    echo CMake configuration failed.
    popd
    goto :fail
)

REM Build the project (ensure Debug configuration for MSVC)
echo Building project (Debug) with: cmake --build . --config Debug
cmake --build . --config Debug
if errorlevel 1 (
    echo Build failed.
    popd
    goto :fail
)

REM Run tests (Debug configuration required for Visual Studio generator)
echo Running tests with: ctest -C Debug --output-on-failure
ctest -C Debug --output-on-failure
if errorlevel 1 (
    echo Some tests failed.
    popd
    goto :fail
)

REM Return to repository root
echo Returning to repository root...
popd
if errorlevel 1 (
    echo Failed to return to repository root.
    goto :fail
)

echo === CI: Success ===
echo === CI: End ===
exit /b 0

:fail
echo === CI: Failure ===
echo See messages above for details.
echo === CI: End ===
exit /b 1