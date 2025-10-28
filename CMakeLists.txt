# Minimum CMake version and project declaration
cmake_minimum_required(VERSION 3.16)
project(csad2025KI407OstashevskyiVolodymyr19 LANGUAGES CXX)

# -------------------------------------------------------
# Configure general C++ settings
# -------------------------------------------------------
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# -------------------------------------------------------
# Compiler warning flags for MSVC and other compilers
# -------------------------------------------------------
set(WARNINGS_MSVC "/W4")
set(WARNINGS_OTHER -Wall -Wextra -pedantic)

# Helper function to apply common warning flags to a target
function(add_common_warnings target)
    target_compile_options(${target} PRIVATE
        $<$<CXX_COMPILER_ID:MSVC>:${WARNINGS_MSVC}>
        $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:${WARNINGS_OTHER}>
    )
endfunction()

# -------------------------------------------------------
# Gather project source files (main executable and optional library)
# - main.cpp will be used to create the executable
# - any other .cpp files in the project root (excluding tests) will be
#   compiled into a library so tests and the main executable can link to it
# -------------------------------------------------------
file(GLOB_RECURSE ALL_CPP CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/*.cpp")
# Collect test sources separately
file(GLOB_RECURSE TEST_SOURCES CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/tests/*.cpp")

# Remove test sources from the main project source list
set(PROJECT_SOURCES ${ALL_CPP})
foreach(tst IN LISTS TEST_SOURCES)
    list(REMOVE_ITEM PROJECT_SOURCES ${tst})
endforeach()

# Ensure main.cpp exists in the root; create main executable from it
set(MAIN_CPP "${CMAKE_SOURCE_DIR}/main.cpp")
if(NOT EXISTS "${MAIN_CPP}")
    message(FATAL_ERROR "Expected main.cpp in project root but it was not found: ${MAIN_CPP}")
endif()
add_executable(${PROJECT_NAME}_exe "${MAIN_CPP}")
add_common_warnings(${PROJECT_NAME}_exe)
target_include_directories(${PROJECT_NAME}_exe PRIVATE "${CMAKE_SOURCE_DIR}")

# If there are other project .cpp files (not main.cpp and not tests), make a library
list(REMOVE_ITEM PROJECT_SOURCES "${MAIN_CPP}")
if(PROJECT_SOURCES)
    add_library(${PROJECT_NAME}_lib STATIC ${PROJECT_SOURCES})
    add_common_warnings(${PROJECT_NAME}_lib)
    target_include_directories(${PROJECT_NAME}_lib PUBLIC "${CMAKE_SOURCE_DIR}")
    # Link the library into the main executable
    target_link_libraries(${PROJECT_NAME}_exe PRIVATE ${PROJECT_NAME}_lib)
endif()

# -------------------------------------------------------
# GoogleTest: try to find installed package, otherwise fetch it via FetchContent
# -------------------------------------------------------
find_package(GTest QUIET)

if(NOT GTest_FOUND)
    include(FetchContent)
    # Fetch a stable GTest release if not available on the system
    FetchContent_Declare(
        googletest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG        release-1.12.1
    )
    # Avoid overriding user's compiler flags on Windows
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(googletest)
endif()

# -------------------------------------------------------
# Unit test target: compile all tests in tests/ and link with GTest and project library
# -------------------------------------------------------
enable_testing()

if(TEST_SOURCES)
    add_executable(unit_tests ${TEST_SOURCES})
    add_common_warnings(unit_tests)
    target_include_directories(unit_tests PRIVATE "${CMAKE_SOURCE_DIR}")

    # Link project library if it exists
    if(TARGET ${PROJECT_NAME}_lib)
        target_link_libraries(unit_tests PRIVATE ${PROJECT_NAME}_lib)
    endif()

    # Link Google Test (handle both namespace and non-namespace target names)
    if(TARGET GTest::gtest_main)
        target_link_libraries(unit_tests PRIVATE GTest::gtest_main)
    elseif(TARGET gtest_main)
        target_link_libraries(unit_tests PRIVATE gtest_main)
    else()
        message(FATAL_ERROR "gtest target not available")
    endif()

    # Register test with CTest
    add_test(NAME unit_tests COMMAND unit_tests)

    # Convenience target to run tests via ctest
    add_custom_target(run_tests
        COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
        DEPENDS unit_tests
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
else()
    message(STATUS "No test sources found in 'tests/' - skipping unit test target creation.")
endif()

# -------------------------------------------------------
# Install rules (optional)
# -------------------------------------------------------
install(TARGETS ${PROJECT_NAME}_exe RUNTIME DESTINATION bin)
if(TARGET ${PROJECT_NAME}_lib)
    install(TARGETS ${PROJECT_NAME}_lib ARCHIVE DESTINATION lib)
endif()