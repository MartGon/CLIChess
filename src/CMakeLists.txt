add_executable(CLIChess 
    AWCMain.cpp    
    Console.cpp
    ConsoleCommand.cpp
)

target_include_directories(CLIChess PUBLIC include ${LUA_INCLUDE_DIR} ${SCRIPT_INCLUDE_DIR}  ${AWC_INCLUDE_DIR} ${UTILS_INCLUDE_DIR}) 
target_link_libraries(CLIChess ${SCRIPT_LIB_PATH} ${AWC_LIB_PATH} ${UTILS_LIB_PATH} ${LUA_LIB_PATH})