#!/bin/bash

./apps/microservices/check_in_service/check_in_service 1 0 2>&1 | tee check_in_service.log &
CHECH_IN_SERVICE_PID=$!

./apps/microservices/flight_service/flight_service 1 0 2>&1 | tee flight_service.log &
FLIGHT_SERVICE_PID=$!

./apps/microservices/baggage_service/baggage_service 1 2>&1 | tee baggage_service.log&
BAGGAGE_SERVICE_PID=$!

./apps/microservices/passport_service/passport_service 1 0 2>&1 | tee passport_service.log&
PASSPORT_SERVICE_PID=$!

./apps/microservices/citizens_service/citizens_service 1 2>&1 | tee citizens_service.log&
CITIZENS_SERVICE_PID=$!

./apps/microservices/airport_db/airport_db_service 1 2>&1 | tee airport_db_service.log&
AIRPORT_DB_SERVICE_PID=$!

trap ctrl_c INT

function ctrl_c() {
	echo "** Trapped CTRL-C, killing apps"
	kill -2 $CHECH_IN_SERVICE_PID
	kill -2 $FLIGHT_SERVICE_PID
	kill -2 $BAGGAGE_SERVICE_PID
	kill -2 $PASSPORT_SERVICE_PID
	kill -2 $CITIZENS_SERVICE_PID
	kill -2 $AIRPORT_DB_SERVICE_PID
}

# Idle wait all services are terminated
wait $CHECH_IN_SERVICE_PID
wait $FLIGHT_SERVICE_PID
wait $BAGGAGE_SERVICE_PID
wait $PASSPORT_SERVICE_PID
wait $CITIZENS_SERVICE_PID
wait $AIRPORT_DB_SERVICE_PID

# ./apps/microservices/frontend/frontend 1 100000 1000000
