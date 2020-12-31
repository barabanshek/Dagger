# Generate RPC stubs
SET(KVS_IDL_FILENAME ${CMAKE_CURRENT_SOURCE_DIR}/../kvs_client/kvs.dproto)
execute_process(COMMAND python3 rpc_gen.py ${KVS_IDL_FILENAME} ${CMAKE_CURRENT_BINARY_DIR}
                WORKING_DIRECTORY ${RPC_CODEGEN_PATH}
                RESULT_VARIABLE STUB_CODEGEN_RESULT)
if(NOT STUB_CODEGEN_RESULT EQUAL "0")
        message(FATAL_ERROR "failed to generate RPC stubs")
endif()

include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/mica)

add_definitions(-pthread)
add_definitions(-g -Wall -Wextra -Wsign-conversion -Winline -Wno-unused-function)
add_definitions(-Wconversion)
add_definitions(-O9)
add_definitions(-msse4.2 -march=corei7)

link_directories(${CMAKE_CURRENT_BINARY_DIR})
link_directories(${CMAKE_CURRENT_BINARY_DIR}/../..)

# Build mica server
# common source files
set(MICA_SOURCES ${MICA_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/mica/hash.c)
set(MICA_SOURCES ${MICA_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/mica/city.c)
set(MICA_SOURCES ${MICA_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/mica/shm.c)

# common libraries
set(LIBRARIES ${LIBRARIES} rt m pthread)

# mica server
add_executable(dagger_mica_server mica_server.cc ${MICA_SOURCES})
target_compile_definitions(dagger_mica_server PRIVATE NO_MD4=1)
target_link_libraries(dagger_mica_server ${LIBRARIES} -ldagger)
