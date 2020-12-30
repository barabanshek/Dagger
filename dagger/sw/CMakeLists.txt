cmake_minimum_required(VERSION 2.8)
project(F-RPC)

set(CMAKE_CXX_COMPILER g++)

add_definitions(-std=c++11 -O3 -march=native)
add_definitions(-Wall -Wextra -Wabi -Wsign-conversion -Wformat -Wformat-security)
# TODO: make it compilable with -Werror
#add_definitions(-Werror)
add_definitions(-pedantic)
add_definitions(-fstack-protector -fPIE -fPIC)
add_definitions(-Wno-unused-function)
add_definitions(-D_FORTIFY_SOURCE=2)

# Debug and logging
#add_definitions(-DFRPC_LOG_LEVEL=3)
#add_definitions(-DENABLE_DEBUG=1)
#add_definitions(-DENABLE_ASSERT=1)

# CCI-P config
add_definitions(-DNIC_CCIP_POLLING)
#add_definitions(-DNIC_CCIP_MMIO)
#add_definitions(-DNIC_CCIP_DMA)

set(LIBRARIES ${LIBRARIES} -z noexecstack)
set(LIBRARIES ${LIBRARIES} -z relro -z now)
set(LIBRARIES ${LIBRARIES} pthread -pie)
set(LIBRARIES ${LIBRARIES} -luuid)

# Testing
enable_testing()
find_package(GTest REQUIRED)

# FPGA OPAE
set(FPGA_LIBS -lopae-c)
set(ASE_LIBS -lopae-c-ase)

include_directories(${CMAKE_SOURCE_DIR}/src)
include_directories(${CMAKE_SOURCE_DIR}/src/nic_impl)

set(ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(RPC_CODEGEN_PATH ${ROOT_DIR}/codegen)

set(SOURCES
    src/nic_impl/nic_ccip.cc
    src/nic_impl/nic_ccip_polling.cc
    src/nic_impl/nic_ccip_mmio.cc
    src/nic_impl/nic_ccip_dma.cc
    src/rpc_server_thread.cc
    src/rpc_threaded_server.cc
    src/tx_queue.cc
    src/rx_queue.cc
    src/completion_queue.cc
    src/rpc_client_nonblocking_base.cc
    src/connection_manager.cc
    )

# Prepare afu_json_info.h
set(JSON_FILENAME ${CMAKE_SOURCE_DIR}/../hw/rtl/ccip_std_afu.json)
set(JSON_HEADER ${CMAKE_CURRENT_BINARY_DIR}/afu_json_info.h)
execute_process(COMMAND afu_json_mgr json-info --afu-json=${JSON_FILENAME} --c-hdr=${JSON_HEADER}
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                RESULT_VARIABLE JSON_GEN_RESULT)
if(NOT JSON_GEN_RESULT EQUAL "0")
        message(FATAL_ERROR "failed to generate AFU json")
endif()
include_directories(${CMAKE_CURRENT_BINARY_DIR})

#
# Aux functions
#
FUNCTION(PREPEND var prefix)
   SET(listVar "")
   FOREACH(f ${ARGN})
      LIST(APPEND listVar "${prefix}/${f}")
   ENDFOREACH(f)
   SET(${var} "${listVar}" PARENT_SCOPE)
ENDFUNCTION(PREPEND)

#
# Build ASE Dagger as a shared library
#
add_library(dagger_ase SHARED ${SOURCES})
target_compile_definitions(dagger_ase PRIVATE -DASE_SIMULATION)
target_link_libraries(dagger_ase ${ASE_LIBS} ${LIBRARIES} -shared)

#
# Build FPGA Dagger as a shared library
#
add_library(dagger SHARED ${SOURCES})
target_compile_definitions(dagger PRIVATE PROFILE_LATENCY=1)
target_link_libraries(dagger ${FPGA_LIBS} ${LIBRARIES} -shared)

#
# Build tests
#
add_subdirectory(tests)

#
# Build ASE samples
#
add_subdirectory(ase_samples)

#
# Build microbenchmarks
#
add_subdirectory(microbenchmarks)

#
# Build end-to-end applications
#
add_subdirectory(apps)