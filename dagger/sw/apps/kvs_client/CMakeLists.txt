# Generate RPC stubs
SET(KVS_IDL_FILENAME ${CMAKE_CURRENT_SOURCE_DIR}/kvs.dproto)
execute_process(COMMAND python3 rpc_gen.py ${KVS_IDL_FILENAME} ${CMAKE_CURRENT_BINARY_DIR}
                WORKING_DIRECTORY ${RPC_CODEGEN_PATH}
                RESULT_VARIABLE STUB_CODEGEN_RESULT)
if(NOT STUB_CODEGEN_RESULT EQUAL "0")
        message(FATAL_ERROR "failed to generate RPC stubs")
endif()

include_directories(${CMAKE_CURRENT_BINARY_DIR})

link_directories(${CMAKE_CURRENT_BINARY_DIR}/../..)

# Build kvs client
set(KVS_CLIENT_SRC kvs_client.cc)
add_executable(dagger_kvs_client ${KVS_CLIENT_SRC})
target_compile_definitions(dagger_kvs_client PRIVATE PROFILE_LATENCY=1)
target_link_libraries(dagger_kvs_client -pthread -ldagger)

# Build kva benchmark client
#set(KVS_CLIENT_BENCHMARK_SRC kvs_client_benchmark.cc)
#add_executable(dagger_kvs_benchmark_client ${KVS_CLIENT_BENCHMARK_SRC})
#target_compile_definitions(dagger_kvs_benchmark_client PRIVATE PROFILE_LATENCY=1)
#target_link_libraries(dagger_kvs_benchmark_client -pthread -ldagger)
