PREPEND(PREP_SOURCES ${ROOT_DIR} ${SOURCES})

set(UNIT_TEST_SOURCES
    unit_tests/main_test.cc
    unit_tests/connection_manager_tests.cc)

set(SYSTEM_TEST_SOURCES
    system_tests_fpga/main_test.cc
    system_tests_fpga/nic_tests.cc
    system_tests_fpga/client_pool_tests.cc
    system_tests_fpga/threaded_server_tests.cc
    system_tests_fpga/single_threaded_rpc_tests.cc
    system_tests_fpga/multi_threaded_rpc_tests.cc)

# Generate RPC stubs for system tests
execute_process(COMMAND python3 rpc_gen.py ${CMAKE_CURRENT_SOURCE_DIR}/test.dproto ${CMAKE_CURRENT_BINARY_DIR}
                WORKING_DIRECTORY ${RPC_CODEGEN_PATH}
                RESULT_VARIABLE STUB_CODEGEN_RESULT)
if(NOT STUB_CODEGEN_RESULT EQUAL "0")
        message(FATAL_ERROR "failed to generate RPC stubs")
endif()

include_directories(${CMAKE_CURRENT_BINARY_DIR})

# Build unit tests
add_executable(dagger_unit_tests ${PREP_SOURCES} ${UNIT_TEST_SOURCES})
target_compile_definitions(dagger_unit_tests PRIVATE FRPC_LOG_LEVEL=0)
target_link_libraries(dagger_unit_tests ${GTEST_LIBRARIES} ${FPGA_LIBS} ${LIBRARIES})

# Build system tests
add_executable(dagger_sys_tests ${PREP_SOURCES} ${SYSTEM_TEST_SOURCES})
target_compile_definitions(dagger_sys_tests PRIVATE FRPC_LOG_LEVEL=0)
target_link_libraries(dagger_sys_tests ${GTEST_LIBRARIES} ${FPGA_LIBS} ${LIBRARIES})
