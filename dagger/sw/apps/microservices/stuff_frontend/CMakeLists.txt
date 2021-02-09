include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/..)
link_directories(${CMAKE_CURRENT_BINARY_DIR}/../../..)

set(CLIENT_SRC stuff_frontend.cc)
add_executable(stuff_frontend ${CLIENT_SRC})
target_compile_definitions(stuff_frontend PRIVATE PROFILE_LATENCY=1)
target_link_libraries(stuff_frontend -pthread -ldagger)
