#!/bin/bash
set -euo pipefail

# CI script: configure, build, and test a C++ project with CMake/CTest.
# Exits immediately on error (set -e). Provides clear success/failure messages.

CI_STATUS=0

error_handler() {
    rc=$?
    cmd="${BASH_COMMAND:-unknown}"
    echo "ERROR: Command '${cmd}' failed with exit code ${rc} at line ${1:-?}" >&2
    CI_STATUS=$rc
}
trap 'error_handler ${LINENO}' ERR

finish() {
    if [ "${CI_STATUS}" -eq 0 ]; then
        echo "CI SUCCESS: Configuration, build, and tests completed successfully."
    else
        echo "CI FAILURE: See details above." >&2
        exit "${CI_STATUS}"
    fi
}
trap finish EXIT

echo "CI: Removing existing 'build' directory..."
rm -rf build

echo "CI: Creating and entering 'build' directory..."
mkdir -p build
cd build

echo "CI: Running CMake configuration (cmake ..)..."
cmake ..

echo "CI: Building project (cmake --build . --config Debug)..."
cmake --build . --config Debug

echo "CI: Running tests (ctest -C Debug --output-on-failure)..."
ctest -C Debug --output-on-failure