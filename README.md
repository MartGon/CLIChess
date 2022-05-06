# CLIChess (Command Line Interface Chess)

## Description

This is an implementation of the classic game chess using [AWC libraries](https://github.com/MartGon/AWC). The game provides a very basic command line interface through a rather minimal C++ code, whereas most of the game logic is implemented using Lua scripts.

# ![clichess1](https://github.com/MartGon/CLIChess/blob/main/docs/clichess2.png?raw=true)

## How to build

You will need the following tools:

- C++17 compatible compiler
- CMake 

You will also need to build the [AWC libraries](https://github.com/MartGon/AWC)

After meeting those requirements, you can run the following commands:


`mkdir build && cd build`

```
cmake -D LUA_INCLUDE_DIR=${AWC_DIR}/deps/lua/src -D SCRIPT_INCLUDE_DIR=${AWC_DIR}/src/Script/include/ -D AWC_INCLUDE_DIR=${AWC_DIR}/src/AWC/include/ \
-D UTILS_INCLUDE_DIR=${AWC_DIR}/src/Utils/include -D SCRIPT_LIB_PATH=${AWC_DIR}/build/src/Script/libScript.a -D LUA_LIB_PATH=${AWC_DIR}/build/deps/lua/libLua.a \
-D AWC_LIB_PATH=/${AWC_DIR}/build/src/AWC/libAWC.a -D UTILS_LIB_PATH=${AWC_DIR}/build/src/Utils/libUtils.a \
```
 `

`make -j 4`

where `${AWC_DIR}` is the root directory of the [AWC libraries](https://github.com/MartGon/AWC)

## How to use

After launching the game, you can enter *help* to get a list of available commands. As usual, white moves first.

## About

Made as functionality test.