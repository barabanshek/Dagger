# Generate RPC stubs
execute_process(COMMAND python3 rpc_gen.py ${CMAKE_CURRENT_SOURCE_DIR}/airport_db_service.dproto ${CMAKE_CURRENT_BINARY_DIR}
                WORKING_DIRECTORY ${RPC_CODEGEN_PATH}
                RESULT_VARIABLE STUB_CODEGEN_RESULT)
if(NOT STUB_CODEGEN_RESULT EQUAL "0")
        message(FATAL_ERROR "failed to generate RPC stubs")
endif()

include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/..)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../mica/mica)
link_directories(${CMAKE_CURRENT_BINARY_DIR}/../../..)

add_definitions(-pthread)
add_definitions(-g -Wall -Wextra -Wsign-conversion -Winline -Wno-unused-function)
add_definitions(-Wconversion)
add_definitions(-O9)
add_definitions(-msse4.2 -march=corei7)

set(MICA_SOURCES ${MICA_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/../../mica/mica/hash.c)
set(MICA_SOURCES ${MICA_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/../../mica/mica/shm.c)

set(LIBRARIES ${LIBRARIES} rt m pthread)

set(CLIENT_SRC airport_db_service.cc ${MICA_SOURCES})
add_executable(airport_db_service ${CLIENT_SRC})
target_compile_definitions(airport_db_service PRIVATE PROFILE_LATENCY=1)
target_compile_definitions(airport_db_service PRIVATE NO_MD4=1)
target_link_libraries(airport_db_service -pthread -ldagger)
