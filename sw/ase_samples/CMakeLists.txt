# Generate RPC stubs
execute_process(COMMAND python3 rpc_gen.py ${CMAKE_CURRENT_SOURCE_DIR}/rpc_def.dproto ${CMAKE_CURRENT_BINARY_DIR}
                WORKING_DIRECTORY ${RPC_CODEGEN_PATH}
                RESULT_VARIABLE STUB_CODEGEN_RESULT)
if(NOT STUB_CODEGEN_RESULT EQUAL "0")
        message(FATAL_ERROR "failed to generate RPC stubs")
endif()

include_directories(${CMAKE_CURRENT_BINARY_DIR})
link_directories(${CMAKE_CURRENT_BINARY_DIR}/..)

# Compile ASE samples
set(ASE_SAMPLE_SRC joint_ase_process.cc)
add_executable(dagger_ase_sample ${ASE_SAMPLE_SRC})
target_compile_definitions(dagger_ase_sample PUBLIC -DASE_SIMULATION)
target_link_libraries(dagger_ase_sample -pthread -ldagger_ase)
