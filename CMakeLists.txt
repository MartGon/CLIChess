# Set minimum CMake version
cmake_minimum_required(VERSION 3.1...3.16)

# Set project name
project(CLIChess VERSION 1.0 LANGUAGES CXX C)

# Set C++ version
set (CMAKE_CXX_STANDARD 17)

# Compile definitions
add_compile_definitions(RESOURCES_DIR="${CMAKE_SOURCE_DIR}/resources/")

add_subdirectory(src)