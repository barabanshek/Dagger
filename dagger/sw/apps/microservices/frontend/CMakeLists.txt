include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/..)
link_directories(${CMAKE_CURRENT_BINARY_DIR}/../../..)

set(CLIENT_SRC frontend.cc)
add_executable(frontend ${CLIENT_SRC})
target_compile_definitions(frontend PRIVATE PROFILE_LATENCY=1)
target_link_libraries(frontend -pthread -ldagger)
