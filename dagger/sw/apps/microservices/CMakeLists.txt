# Copy deployment script
execute_process(COMMAND cp run_services.sh ${CMAKE_CURRENT_BINARY_DIR}
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                RESULT_VARIABLE CP_RESULT)

#add_definitions(-D_SERVICE_VERBOSE_)

add_subdirectory(frontend)
add_subdirectory(check_in_service)
add_subdirectory(flight_service)
add_subdirectory(baggage_service)
add_subdirectory(passport_service)
add_subdirectory(airport_db)
add_subdirectory(citizens_service)
add_subdirectory(stuff_frontend)
