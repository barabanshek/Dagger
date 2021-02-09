#include <signal.h>
#include <unistd.h>

#include <algorithm>
#include <cassert>
#include <cinttypes>
#include <cstdlib>
#include <iostream>
#include <thread>
#include <vector>

#include "CheckInService_rpc_server_callback.h"
#include "CheckInService_rpc_types.h"
#include "../flight_service/FlightService_rpc_client.h"
#include "../flight_service/FlightService_rpc_types.h"

#include "rpc_call.h"
#include "rpc_client_pool.h"
#include "rpc_threaded_server.h"

//
// Main part
//
#define SERVER_NIC_ADDR 0x4000
#define CLIENT_NIC_ADDR 0x8000

frpc::RpcClient* flight_service;
frpc::RpcClient* baggage_service;
frpc::RpcClient* passport_service;
frpc::RpcClient* airport_db;

static constexpr char* frontend_host_addr = "0.0.0.0";
static constexpr char* flight_service_host_addr = "0.0.0.3";
static constexpr char* baggage_service_host_addr = "0.0.0.4";
static constexpr char* passport_service_host_addr = "0.0.0.5";
static constexpr char* airport_db_host_addr = "0.0.0.9";

static RpcRetCode register_passenger(CallHandler handler, RegistrationPassengerData req, RegistrationStatus* resp);

// Ctl-C handler
static volatile int keepRunning = 1;
void intHandler(int dummy) {
    keepRunning = 0;
}

int main(int argc, char* argv[]) {
    size_t num_of_threads = atoi(argv[1]);
    size_t num_of_working_threads = atoi(argv[2]);

    // Run server
    frpc::RpcThreadedServer server(SERVER_NIC_ADDR, num_of_threads, num_of_working_threads);

    int res = server.init_nic();
    if (res != 0)
        return res;

    res = server.start_nic();
    if (res != 0)
        return res;

//    res = server.run_perf_thread({true, true, true}, nullptr);
//    if (res != 0)
//        return res;

    // Open connections with the up-stream service (frontend)
    for (int i=0; i<num_of_threads; ++i) {
        frpc::IPv4 frontend_addr(frontend_host_addr, 3136);
        if (server.connect(frontend_addr, i, i) != 0) {
            std::cout << "Failed to open connection on server" << std::endl;
            exit(1);
        } else {
            std::cout << "Connection is open on server" << std::endl;
        }
    }

    // Register RPC functions
    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(&register_passenger));

    frpc::RpcServerCallBack server_callback(fn_ptr);

    for (int i=0; i<num_of_threads; ++i) {
        res = server.run_new_listening_thread(&server_callback);
        if (res != 0)
            return res;
    }

    // Init client pool
    static frpc::RpcClientPool<frpc::RpcClient> rpc_client_pool(CLIENT_NIC_ADDR,
                                                                4*num_of_threads);

    res = rpc_client_pool.init_nic();
    if (res != 0)
        return res;

    res = rpc_client_pool.start_nic();
    if (res != 0)
        return res;

//    res = rpc_client_pool.run_perf_thread({true, true, true}, nullptr);
//    if (res != 0)
//        return res;

    // Get services
    // Flight service
    flight_service = rpc_client_pool.pop();
    assert(flight_service != nullptr);
    frpc::IPv4 flight_service_addr(flight_service_host_addr, 3136);
    if (flight_service->connect(flight_service_addr, 0) != 0) {
        std::cout << "Check_in_service> failed to open connection with flight_service" << std::endl;
        return 1;
    } else {
        std::cout << "Check_in_service> connection is open with flight_service" << std::endl;
    }

    // Baggage service
    baggage_service = rpc_client_pool.pop();
    assert(baggage_service != nullptr);
    frpc::IPv4 baggage_service_addr(baggage_service_host_addr, 3136);
    if (baggage_service->connect(baggage_service_addr, 1) != 0) {
        std::cout << "Check_in_service> failed to open connection with baggage_service" << std::endl;
        return 1;
    } else {
        std::cout << "Check_in_service> connection is open with baggage_service" << std::endl;
    }

    // Passport service
    passport_service = rpc_client_pool.pop();
    assert(passport_service != nullptr);
    frpc::IPv4 passport_service_addr(passport_service_host_addr, 3136);
    if (passport_service->connect(passport_service_addr, 2) != 0) {
        std::cout << "Check_in_service> failed to open connection with passport_service" << std::endl;
        return 1;
    } else {
        std::cout << "Check_in_service> connection is open with passport_service" << std::endl;
    }

    // Airport db
    airport_db = rpc_client_pool.pop();
    assert(airport_db != nullptr);
    frpc::IPv4 airport_db_addr(airport_db_host_addr, 3136);
    if (airport_db->connect(airport_db_addr, 3) != 0) {
        std::cout << "Check_in_service> failed to open connection with airport_db" << std::endl;
        return 1;
    } else {
        std::cout << "Check_in_service> connection is open with airport_db" << std::endl;
    }

    std::cout << "------- Check_in_service is running... -------" << std::endl;

    std::cout << "Check_in_service> Press Ctrl+C to stop..." << std::endl;
    signal(SIGINT, intHandler);

    while(keepRunning) {
        sleep(1);
    }

    res = server.stop_all_listening_threads();
    if (res != 0)
        return res;

    std::cout << "------- Check_in_service is stopped! -------" << std::endl;

    // Check for HW errors
    res = server.check_hw_errors();
    if (res != 0)
        std::cout << "Check_in_service> HW errors found in server, check error log" << std::endl;
    else
        std::cout << "Check_in_service> no HW errors found in server" << std::endl;

    res = rpc_client_pool.check_hw_errors();
    if (res != 0)
        std::cout << "Check_in_service> HW errors found in client" << std::endl;
    else
        std::cout << "Check_in_service> no HW errors found in client" << std::endl;

    // TODO: close/remove connections
    //
    //

    // Stop NIC
    res = server.stop_nic();
    if (res != 0)
        return res;

    res = rpc_client_pool.stop_nic();
    if (res != 0)
        return res;

    return 0;
}


//
// Handle register_passenger requests
//
static constexpr size_t t_delay = 3000;
static constexpr size_t t_out = 20000;

static RpcRetCode register_passenger(CallHandler handler, RegistrationPassengerData req, RegistrationStatus* resp) {
#ifdef _SERVICE_VERBOSE_
    std::cout << "#" << req.trace_id << " Check_in_service> register_passenger received for <"
              << req.first_name << ", " << req.last_name << ">, flight number #"
              << static_cast<int>(req.flight_number) << std::endl;
#endif

    // Get cq's
    auto flight_service_cq = flight_service->get_completion_queue();
    assert(flight_service_cq != nullptr);

    auto baggage_service_cq = baggage_service->get_completion_queue();
    assert(baggage_service_cq != nullptr);

    auto passport_service_cq = passport_service->get_completion_queue();
    assert(passport_service_cq != nullptr);

    auto airport_db_cq = airport_db->get_completion_queue();
    assert(airport_db_cq != nullptr);

    // First, consult the flight service
    flight_service->check_flight({req.timestamp, req.trace_id, req.flight_number});

    // Next, consult the baggage service
    PassengerData bs_req;
    bs_req.timestamp = req.timestamp;
    bs_req.trace_id = req.trace_id;
    strcpy(bs_req.first_name, req.first_name);
    strcpy(bs_req.last_name, req.last_name);
    baggage_service->check_baggage(bs_req);

    // Next, consult the passport service
    PassengerData ps_req;
    ps_req.timestamp = req.timestamp;
    ps_req.trace_id = req.trace_id;
    strcpy(ps_req.first_name, req.first_name);
    strcpy(ps_req.last_name, req.last_name);
    passport_service->check_passport(ps_req);

    // We block here and wait for all responses
    size_t t = 0;
    while((flight_service_cq->get_number_of_completed_requests() == 0 ||
          baggage_service_cq->get_number_of_completed_requests() == 0 ||
          passport_service_cq->get_number_of_completed_requests() == 0) &&
          t < t_out) {
        ++t;
        for(size_t i=0; i<t_delay; ++i) {
            asm("");
        }
    }

    // Check if we got all the responses
    if (flight_service_cq->get_number_of_completed_requests() == 0) {
        // Return here
        resp->timestamp = req.timestamp;
        resp->trace_id = req.trace_id;
        sprintf(resp->status, "F_TOUT");
        resp->seat_number = 0;

        return RpcRetCode::Success;
    }

    if (baggage_service_cq->get_number_of_completed_requests() == 0) {
        // Return here
        resp->timestamp = req.timestamp;
        resp->trace_id = req.trace_id;
        sprintf(resp->status, "B_TOUT");
        resp->seat_number = 0;

        return RpcRetCode::Success;
    }

    if (passport_service_cq->get_number_of_completed_requests() == 0) {
        // Return here
        resp->timestamp = req.timestamp;
        resp->trace_id = req.trace_id;
        sprintf(resp->status, "P_TOUT");
        resp->seat_number = 0;

        return RpcRetCode::Success;
    }

    // Check flight status
    auto flight_status = reinterpret_cast<FlightStatus*>(flight_service_cq->pop_response().argv);
    if (strcmp(flight_status->status, "OK") != 0) {
        // Return here
        resp->timestamp = req.timestamp;
        resp->trace_id = req.trace_id;
        sprintf(resp->status, "FAIL_F");
        resp->seat_number = 0;

        return RpcRetCode::Success;
    }

    // Check passport status
    auto passport_status = reinterpret_cast<PassportStatus*>(passport_service_cq->pop_response().argv);
    if (strcmp(passport_status->status, "OK") != 0) {
        // Return here
        resp->timestamp = req.timestamp;
        resp->trace_id = req.trace_id;
        sprintf(resp->status, "FAIL_P");
        resp->seat_number = 0;

        return RpcRetCode::Success;
    }

    // Finally, register passenger
    uint8_t seat_number = flight_status->seat_number;

    RegPassengerData rp_req;
    rp_req.timestamp = req.timestamp;
    rp_req.trace_id = req.trace_id;
    strcpy(rp_req.first_name, req.first_name);
    strcpy(rp_req.last_name, req.last_name);
    rp_req.flight_number = req.flight_number;
    rp_req.seat_number = seat_number;
    airport_db->register_passenger(rp_req);

    // We block here and wait for all responses
    t = 0;
    while(airport_db_cq->get_number_of_completed_requests() == 0 && t < t_out) {
        ++t;
        for(size_t i=0; i<t_delay; ++i) {
            asm("");
        }
    }

    // Check airport status
    if (airport_db_cq->get_number_of_completed_requests() == 0) {
        // Return here
        resp->timestamp = req.timestamp;
        resp->trace_id = req.trace_id;
        sprintf(resp->status, "A_TOUT");
        resp->seat_number = 0;

        return RpcRetCode::Success;
    }

    auto airport_status = reinterpret_cast<RegStatus*>(airport_db_cq->pop_response().argv);
    if (strcmp(airport_status->status, "OK") != 0) {
        // Return here
        resp->timestamp = req.timestamp;
        resp->trace_id = req.trace_id;
        sprintf(resp->status, "FAIL_A");
        resp->seat_number = 0;

        return RpcRetCode::Success;
    }

    // Return
    resp->timestamp = req.timestamp;
    resp->trace_id = req.trace_id;
    sprintf(resp->status, "OK");
    resp->seat_number = seat_number;

    return RpcRetCode::Success;
}
