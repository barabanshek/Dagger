#include <unistd.h>

#include <algorithm>
#include <cassert>
#include <cinttypes>
#include <cstdlib>
#include <iostream>
#include <thread>
#include <vector>

#include "service_utils.h"

#include "rpc_call.h"
#include "rpc_client_pool.h"

#include "../airport_db/AirpordDbService_rpc_client.h"
#include "../airport_db/AirpordDbService_rpc_types.h"

// Ctl-C handler
static volatile int keepRunning = 1;

void intHandler(int dummy) {
    keepRunning = 0;
}

//
// Main Part
//
#define NIC_ADDR 0x20000
static constexpr char* airport_db_host_addr = "0.0.0.9";
static constexpr int c_id = 7;

int main(int argc, char* argv[]) {
    double cycles_in_ns = rdtsc_in_ns();
    std::cout << "Cycles in ns: " << cycles_in_ns << std::endl;

    // Run RPC clients
    frpc::RpcClientPool<frpc::RpcClient> rpc_client_pool(NIC_ADDR, 1);

    int res = rpc_client_pool.init_nic();
    if (res != 0)
        return res;

    res = rpc_client_pool.start_nic();
    if (res != 0)
        return res;

//    res = rpc_client_pool.run_perf_thread({true, true, true}, nullptr);
//    if (res != 0)
//        return res;

    frpc::IPv4 server_addr(airport_db_host_addr, 3136);
    frpc::RpcClient* rpc_client = rpc_client_pool.pop();
    assert(rpc_client != nullptr);

    if (rpc_client->connect(server_addr, c_id) != 0) {
        std::cout << "Failed to open connection on client" << std::endl;
        exit(1);
    } else {
        std::cout << "Connection is open on client" << std::endl;
    }

    // Shell loop
    while (keepRunning) {
        char cmd[100];

        std::cout << "> ";
        std::cin.getline(cmd, sizeof(cmd));

        uint8_t flight_number = atoi(cmd);

        rpc_client->get_flight({frpc::utils::rdtsc(), gen_trace_id(), flight_number});

        auto cq = rpc_client->get_completion_queue();
        while (cq->get_number_of_completed_requests() == 0) {
            usleep(1000);
        }

        PassengerData* p_data = reinterpret_cast<PassengerData*>(cq->pop_response().argv);
        std::cout << "returned> " << p_data->first_name << " " << p_data->last_name  << std::endl;
    }

    // Check for HW errors
    res = rpc_client_pool.check_hw_errors();
    if (res != 0)
        std::cout << "HW errors found, check error log" << std::endl;
    else
        std::cout << "No HW errors found" << std::endl;

    // Stop NIC
    res = rpc_client_pool.stop_nic();
    if (res != 0)
        return res;

    return 0;
}
