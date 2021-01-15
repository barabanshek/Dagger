PREPEND(PREP_SOURCES ${ROOT_DIR} ${SOURCES})

# Generate RPC stubs
SET(KVS_IDL_FILENAME ${CMAKE_CURRENT_SOURCE_DIR}/../kvs_client/kvs.dproto)
execute_process(COMMAND python3 rpc_gen.py ${KVS_IDL_FILENAME} ${CMAKE_CURRENT_BINARY_DIR}
                WORKING_DIRECTORY ${RPC_CODEGEN_PATH}
                RESULT_VARIABLE STUB_CODEGEN_RESULT)
if(NOT STUB_CODEGEN_RESULT EQUAL "0")
        message(FATAL_ERROR "failed to generate RPC stubs")
endif()

include_directories(${CMAKE_CURRENT_BINARY_DIR})
link_directories(${CMAKE_CURRENT_BINARY_DIR})

# Build a special ldagger for memcached that contains cpp wrapper symbols
add_library(dagger-memcached SHARED ${PREP_SOURCES} cpp/memcached_cpp_wrapper.cc)
target_compile_definitions(dagger-memcached PRIVATE PROFILE_LATENCY=1)
target_link_libraries(dagger-memcached ${FPGA_LIBS} ${LIBRARIES} -shared)

# Build memcached server
SET(MEMCACHED_MAKE_CMD CPPFLAGS="-I${CMAKE_CURRENT_SOURCE_DIR}/cpp"
	                   CPPFLAGS+="-I${CMAKE_CURRENT_BINARY_DIR}"
                       CPPFLAGS+="-I${CMAKE_CURRENT_SOURCE_DIR}/../../src"
	                   LDFLAGS="-L${CMAKE_CURRENT_BINARY_DIR}"
	                   LIBS="-ldagger-memcached"
	                   LIBS+="-lhugetlbfs"
	                   LIBS+="-levent"
	                   LIBS+="-pthread")

execute_process(COMMAND autoreconf -f -i
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/memcached
                RESULT_VARIABLE MEMCACHED_CONFIGURE_RESULT)
if(NOT MEMCACHED_CONFIGURE_RESULT EQUAL "0")
        message(FATAL_ERROR "failed to configure memcached")
endif()

execute_process(COMMAND ./configure
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/memcached
                RESULT_VARIABLE MEMCACHED_CONFIGURE_RESULT)
if(NOT MEMCACHED_CONFIGURE_RESULT EQUAL "0")
        message(FATAL_ERROR "failed to configure memcached")
endif()

add_custom_target(memcached_server ALL
                  /usr/bin/make -f "${CMAKE_CURRENT_SOURCE_DIR}/memcached/Makefile" ${MEMCACHED_MAKE_CMD}
                  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/memcached)
