# Generate RPC stubs
execute_process(COMMAND python3 rpc_gen.py ${CMAKE_CURRENT_SOURCE_DIR}/lat_thr.dproto ${CMAKE_CURRENT_BINARY_DIR}
                WORKING_DIRECTORY ${RPC_CODEGEN_PATH}
                RESULT_VARIABLE STUB_CODEGEN_RESULT)
if(NOT STUB_CODEGEN_RESULT EQUAL "0")
        message(FATAL_ERROR "failed to generate RPC stubs")
endif()

include_directories(${CMAKE_CURRENT_BINARY_DIR})
link_directories(${CMAKE_CURRENT_BINARY_DIR}/../..)

# Build benchmark client
set(BENCH_CLIENT_SRC client.cc)
add_executable(dagger_benchmark_client ${BENCH_CLIENT_SRC})
target_compile_definitions(dagger_benchmark_client PRIVATE PROFILE_LATENCY=1)
#target_compile_definitions(dagger_benchmark_client PRIVATE VERBOSE_RPCS=1)
target_link_libraries(dagger_benchmark_client -pthread -ldagger)

# Build benchmark server
set(BENCH_SERVER_SRC server.cc)
add_executable(dagger_benchmark_server ${BENCH_SERVER_SRC})
target_compile_definitions(dagger_benchmark_server PRIVATE PROFILE_LATENCY=1)
#target_compile_definitions(dagger_benchmark_server PRIVATE VERBOSE_RPCS=1)
target_link_libraries(dagger_benchmark_server -pthread -ldagger)
