#include <signal.h>
#include <unistd.h>

#include <algorithm>
#include <cassert>
#include <cinttypes>
#include <cstdlib>
#include <iostream>
#include <thread>
#include <vector>

#include "service_utils.h"

#include "CitizenService_rpc_server_callback.h"
#include "CitizenService_rpc_types.h"

#include "rpc_call.h"
#include "rpc_client_pool.h"
#include "rpc_threaded_server.h"

//
// Main part
//
#define SERVER_NIC_ADDR 0x1C000

static constexpr char* passport_host_addr = "0.0.0.6";

static RpcRetCode legal_check(CallHandler handler, CitizenData req, LegalStatus* resp);

// Ctl-C handler
static volatile int keepRunning = 1;
void intHandler(int dummy) {
    keepRunning = 0;
}

int main(int argc, char* argv[]) {
    size_t num_of_threads = atoi(argv[1]);

    // Run server
    frpc::RpcThreadedServer server(SERVER_NIC_ADDR, num_of_threads);

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
        frpc::IPv4 passport_addr(passport_host_addr, 3136);
        if (server.connect(passport_addr, 0, 0) != 0) {
            std::cout << "Citizens_service> failed to open connection on server" << std::endl;
            exit(1);
        } else {
            std::cout << "Citizens_service> connection is open on server" << std::endl;
        }
    }

    // Register RPC functions
    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(&legal_check));

    frpc::RpcServerCallBack server_callback(fn_ptr);

    for (int i=0; i<num_of_threads; ++i) {
        res = server.run_new_listening_thread(&server_callback);
        if (res != 0)
            return res;
    }

    std::cout << "------- Citizens_service is running... -------" << std::endl;

    std::cout << "Citizens_service> Press Ctrl+C to stop..." << std::endl;
    signal(SIGINT, intHandler);

    while(keepRunning) {
        sleep(1);
    }

    res = server.stop_all_listening_threads();
    if (res != 0)
        return res;

    std::cout << "------- Citizens_service is stopped! -------" << std::endl;

    // Check for HW errors
    res = server.check_hw_errors();
    if (res != 0)
        std::cout << "Citizens_service> HW errors found in server, check error log" << std::endl;
    else
        std::cout << "Citizens_service> no HW errors found in server" << std::endl;

    // Stop NIC
    res = server.stop_nic();
    if (res != 0)
        return res;

    return 0;
}

static RndGen rnd_gen(987654321);

static RpcRetCode legal_check(CallHandler handler, CitizenData req, LegalStatus* resp) {
#ifdef _SERVICE_VERBOSE_
    std::cout << "#" << req.trace_id << " Citizens_service> legal_check received for <"
              << req.first_name << ", " << req.last_name << ">" << std::endl;
#endif

    // Dummy delay
    constexpr size_t delay_var = 5000;
    constexpr size_t delay_mean = 500;
    size_t dummy_delay = delay_mean + rnd_gen.next_u32() % delay_var;
    for (size_t delay=0; delay<dummy_delay; ++delay) {
        asm("");
    }

    // Return
    resp->timestamp = req.timestamp;
    resp->trace_id = req.trace_id;
    sprintf(resp->status, "OK");

    return RpcRetCode::Success;
}
