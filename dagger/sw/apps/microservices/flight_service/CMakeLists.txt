# Generate RPC stubs
execute_process(COMMAND python3 rpc_gen.py ${CMAKE_CURRENT_SOURCE_DIR}/flight_service.dproto ${CMAKE_CURRENT_BINARY_DIR}
                WORKING_DIRECTORY ${RPC_CODEGEN_PATH}
                RESULT_VARIABLE STUB_CODEGEN_RESULT)
if(NOT STUB_CODEGEN_RESULT EQUAL "0")
        message(FATAL_ERROR "failed to generate RPC stubs")
endif()

include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/..)
link_directories(${CMAKE_CURRENT_BINARY_DIR}/../../..)

set(CLIENT_SRC flight_service.cc)
add_executable(flight_service ${CLIENT_SRC})
target_compile_definitions(flight_service PRIVATE PROFILE_LATENCY=1)
target_link_libraries(flight_service -pthread -ldagger)
