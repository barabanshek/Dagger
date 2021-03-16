#include <signal.h>
#include <unistd.h>

#include <algorithm>
#include <cassert>
#include <cinttypes>
#include <cstdlib>
#include <iostream>
#include <thread>
#include <vector>

#include "PassportService_rpc_server_callback.h"
#include "PassportService_rpc_types.h"
#include "../citizens_service/CitizenService_rpc_client.h"
#include "../citizens_service/CitizenService_rpc_types.h"

#include "rpc_call.h"
#include "rpc_client_pool.h"
#include "rpc_threaded_server.h"

//
// Main part
//
#define SERVER_NIC_ADDR 0x14000
#define CLIENT_NIC_ADDR 0x18000

static constexpr char* check_in_host_addr = "0.0.0.2";

static RpcRetCode check_flight(CallHandler handler, FlightData req, FlightStatus* resp);
static RpcRetCode check_baggage(CallHandler handler, PassengerData req, BaggageStatus* resp);
static RpcRetCode check_passport(CallHandler handler, PassengerData req, PassportStatus* resp);
static RpcRetCode register_passenger(CallHandler handler, RegPassengerData req, RegStatus* resp);

static constexpr char* citizen_service_host_addr = "0.0.0.7";
frpc::RpcClient* citizen_service;

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

    // Open connections with the up-stream service (check_in_service)
    for (int i=0; i<num_of_threads; ++i) {
        frpc::IPv4 check_in_addr(check_in_host_addr, 3136);
        if (server.connect(check_in_addr, 2, 0) != 0) {
            std::cout << "Passport_service> failed to open connection on server" << std::endl;
            exit(1);
        } else {
            std::cout << "Passport_service> connection is open on server" << std::endl;
        }
    }

    // Register RPC functions
    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(&check_flight));
    fn_ptr.push_back(reinterpret_cast<const void*>(&check_baggage));
    fn_ptr.push_back(reinterpret_cast<const void*>(&check_passport));
    fn_ptr.push_back(reinterpret_cast<const void*>(&register_passenger));

    frpc::RpcServerCallBack server_callback(fn_ptr);

    for (int i=0; i<num_of_threads; ++i) {
        res = server.run_new_listening_thread(&server_callback);
        if (res != 0)
            return res;
    }

    // Init client pool
    static frpc::RpcClientPool<frpc::RpcClient> rpc_client_pool(CLIENT_NIC_ADDR,
                                                                num_of_threads);

    res = rpc_client_pool.init_nic();
    if (res != 0)
        return res;

    res = rpc_client_pool.start_nic();
    if (res != 0)
        return res;

//    res = rpc_client_pool.run_perf_thread({true, true, true}, nullptr);
//    if (res != 0)
//        return res;

    // Flight service
    citizen_service = rpc_client_pool.pop();
    assert(citizen_service != nullptr);
    frpc::IPv4 citizen_service_addr(citizen_service_host_addr, 3136);
    if (citizen_service->connect(citizen_service_addr, 0) != 0) {
        std::cout << "Check_in_service> failed to open connection with citizen_service" << std::endl;
        return 1;
    } else {
        std::cout << "Check_in_service> connection is open with citizen_service" << std::endl;
    }

    std::cout << "------- Passport_service is running... -------" << std::endl;

    std::cout << "Passport_service> Press Ctrl+C to stop..." << std::endl;
    signal(SIGINT, intHandler);

    while(keepRunning) {
        sleep(1);
    }

    res = server.stop_all_listening_threads();
    if (res != 0)
        return res;

    std::cout << "------- Passport_service is stopped! -------" << std::endl;

    // Check for HW errors
    res = server.check_hw_errors();
    if (res != 0)
        std::cout << "Passport_service> HW errors found in server, check error log" << std::endl;
    else
        std::cout << "Passport_service> no HW errors found in server" << std::endl;

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

static RpcRetCode check_flight(CallHandler handler, FlightData req, FlightStatus* resp) {
    assert(false);
}

static RpcRetCode check_baggage(CallHandler handler, PassengerData req, BaggageStatus* resp) {
    assert(false);
}

static constexpr size_t t_delay = 3000;
static constexpr size_t t_out = 1000;

static RpcRetCode check_passport(CallHandler handler, PassengerData req, PassportStatus* resp) {
#ifdef _SERVICE_VERBOSE_
    std::cout << "#" << req.trace_id << " Passport_service> check_passport received for <"
              << req.first_name << ", " << req.last_name << ">" << std::endl;
#endif

    // Get cq's
    auto citizen_service_cq = citizen_service->get_completion_queue();
    assert(citizen_service_cq != nullptr);

    // Check legal status
    CitizenData ct_req;
    ct_req.timestamp = req.timestamp;
    ct_req.trace_id = req.trace_id;
    strcpy(ct_req.first_name, req.first_name);
    strcpy(ct_req.last_name, req.last_name);
    citizen_service->legal_check(ct_req);

    // Block here
    size_t t = 0;
    while(citizen_service_cq->get_number_of_completed_requests() == 0 && t < t_out) {
        ++t;
        for(size_t i=0; i<t_delay; ++i) {
            asm("");
        }
    }

    if (citizen_service_cq->get_number_of_completed_requests() == 0) {
        resp->timestamp = req.timestamp;
        resp->trace_id = req.trace_id;
        sprintf(resp->status, "C_TOUT");

        return RpcRetCode::Success;
    }

    auto legal_status = reinterpret_cast<LegalStatus*>(citizen_service_cq->pop_response().argv);

    if (strcmp(legal_status->status, "OK") != 0) {
        resp->timestamp = req.timestamp;
        resp->trace_id = req.trace_id;
        sprintf(resp->status, "FAIL");

        return RpcRetCode::Success;
    }

    // Return
    resp->timestamp = req.timestamp;
    resp->trace_id = req.trace_id;
    sprintf(resp->status, "OK");

    return RpcRetCode::Success;
}

static RpcRetCode register_passenger(CallHandler handler, RegPassengerData req, RegStatus* resp) {
    assert(false);
}
