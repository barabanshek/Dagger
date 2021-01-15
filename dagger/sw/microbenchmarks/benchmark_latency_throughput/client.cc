#include <unistd.h>

#include <algorithm>
#include <cassert>
#include <cinttypes>
#include <cstdlib>
#include <iostream>
#include <thread>
#include <vector>

#include "rpc_call.h"
#include "rpc_client.h"
#include "rpc_client_pool.h"
#include "rpc_types.h"
#include "utils.h"

// HW parameters
#define NIC_ADDR 0x20000

static int run_benchmark(frpc::RpcClient* rpc_client,
                             int thread_id,
                             size_t num_iterations,
                             size_t req_delay,
                             double cycles_in_ns,
                             int function_to_call);

static double rdtsc_in_ns() {
    uint64_t a = frpc::utils::rdtsc();
    sleep(1);
    uint64_t b = frpc::utils::rdtsc();

    return (b - a)/1000000000.0;
}

// <number of threads, number of requests per thread, RPC issue delay, function>
enum TestType {performance, correctness};

int main(int argc, char* argv[]) {
    double cycles_in_ns = rdtsc_in_ns();
    std::cout << "Cycles in ns: " << cycles_in_ns << std::endl;

    // Parse input
    size_t num_of_threads = atoi(argv[1]);
    size_t num_of_requests = atoi(argv[2]);
    size_t req_delay = atoi(argv[3]);
    int function_to_call = 0;
    if (strcmp(argv[4], "-loopback") == 0)
        function_to_call = 0;
    else if (strcmp(argv[4], "-add") == 0)
        function_to_call = 1;
    else if (strcmp(argv[4], "-sign") == 0)
        function_to_call = 2;
    else if (strcmp(argv[4], "-xor") == 0)
        function_to_call = 3;
    else if (strcmp(argv[4], "-getUserData") == 0)
        function_to_call = 4;
    else {
        std::cout << "wrong parameter: function name" << std::endl;
        return 1;
    }

    frpc::RpcClientPool<frpc::RpcClient> rpc_client_pool(NIC_ADDR,
                                                         num_of_threads);

    // Init client pool
    int res = rpc_client_pool.init_nic();
    if (res != 0)
        return res;

    // Start NIC
    res = rpc_client_pool.start_nic();
    if (res != 0)
        return res;

    // Enable perf
    res = rpc_client_pool.run_perf_thread({true, true, true}, nullptr);
    if (res != 0)
        return res;

    sleep(1);

    // Run client threads
    std::vector<std::thread> threads;
    for (int thread_id=0; thread_id<num_of_threads; ++thread_id) {
        frpc::RpcClient* rpc_client = rpc_client_pool.pop();
        assert(rpc_client != nullptr);

        // Open connection
        frpc::IPv4 server_addr("192.168.0.1", 3136);
        if (rpc_client->connect(server_addr, thread_id) != 0) {
            std::cout << "Failed to open connection on client" << std::endl;
            exit(1);
        } else {
            std::cout << "Connection is open on client" << std::endl;
        }

        std::thread thr = std::thread(&run_benchmark,
                                      rpc_client,
                                      thread_id,
                                      num_of_requests,
                                      req_delay,
                                      cycles_in_ns,
                                      function_to_call);
        threads.push_back(std::move(thr));
    }

    for (auto& thr: threads) {
        thr.join();
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

static bool sortbysec(const uint64_t &a, const uint64_t &b) {
    return a < b;
}

static int run_benchmark(frpc::RpcClient* rpc_client,
                         int thread_id,
                         size_t num_iterations,
                         size_t req_delay,
                         double cycles_in_ns,
                         int function_to_call) {
    // Make an RPC call
    for(int i=0; i<num_iterations; ++i) {
        switch (function_to_call) {
            case 0: rpc_client->loopback({frpc::utils::rdtsc(), i}); break;

            case 1: rpc_client->add({frpc::utils::rdtsc(), i, i+1}); break;

            case 2: rpc_client->sign({frpc::utils::rdtsc(),
                                     0xaabbccdd,
                                     0x11223344,
                                     i, i+1, i+2, i+3}); break;

            case 3: rpc_client->xor_({frpc::utils::rdtsc(),
                                     i, i+1, i+2, i+3, i+4, i+5}); break;

            case 4: {
                UserName request;
                request.timestamp = frpc::utils::rdtsc();
                sprintf(request.first_name, "Buffalo");
                sprintf(request.given_name, "Bill");

                rpc_client->getUserData(request);
                break;
            }
        }

        // Blocking delay to control rps rate
        for (int delay=0; delay<req_delay; ++delay) {
            asm("");
        }
    }

    // Wait a bit
    sleep(5);

    // Get data
    auto cq = rpc_client->get_completion_queue();
    size_t cq_size = cq->get_number_of_completed_requests();
    std::cout << "Thread #" << thread_id << ": CQ size= " << cq_size << std::endl;

#ifdef VERBOSE_RPCS
    // Output data
    for (int i=0; i<cq_size; ++i) {
        switch (function_to_call) {
            case 0:
            case 1:
            case 3: {
                std::cout << reinterpret_cast<NumericalResult*>(cq->pop_response().argv)->ret_val << std::endl;
                break;
            }

            case 2: {
                std::cout << reinterpret_cast<Signature*>(cq->pop_response().argv)->result << std::endl;
                break;
            }

            case 4: {
                std::cout << reinterpret_cast<UserData*>(cq->pop_response().argv)->data << std::endl;
                break;
            }
        }
    }
#endif

    // Get latency profile
    auto latency_records = cq->get_latency_records();

    std::sort(latency_records.begin(), latency_records.end(), sortbysec);

    if (latency_records.size() != 0) {
        std::cout << "***** latency results for thread #" << thread_id
                  << " *****" << std::endl;
        std::cout << "  total records= " << latency_records.size() << std::endl;
        std::cout << "  median= "
                  << latency_records[latency_records.size()*0.5]/cycles_in_ns
                  << " ns" << std::endl;
        std::cout << "  90th= "
                  << latency_records[latency_records.size()*0.9]/cycles_in_ns
                  << " ns" << std::endl;
        std::cout << "  99th= "
                  << latency_records[latency_records.size()*0.99]/cycles_in_ns
                  << " ns" << std::endl;
    }

    return 0;
}
