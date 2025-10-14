cmake_minimum_required(VERSION 3.16)
project(csad2025KI407OstashevskyiVolodymyr19 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add source files here
# Example:
# add_executable(${PROJECT_NAME} main.cpp)

# Enable warnings
if(MSVC)
    add_compile_options(/W4)
else()
    add_compile_options(-Wall -Wextra -pedantic)
endif()