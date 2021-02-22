# Set minimum CMake version
cmake_minimum_required(VERSION 3.1...3.16)

# Set project name
project(CLIChess VERSION 1.0 LANGUAGES CXX)

# Set C++ version
set (CMAKE_CXX_STANDARD 17)

add_subdirectory(src)