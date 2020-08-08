#include <unistd.h>

#include <algorithm>
#include <cassert>
#include <cinttypes>
#include <cstdlib>
#include <iostream>
#include <thread>
#include <vector>

#include "rpc_client_nonblocking.h"
#include "rpc_client_pool.h"
#include "utils.h"

// HW parameters
#define NIC_ADDR 0x20000

static int run_set_benchmark(frpc::RpcClientNonBlock* rpc_client,
                             int thread_id,
                             size_t num_iterations,
                             size_t req_delay,
                             double cycles_in_ns);

static double rdtsc_in_ns() {
    uint64_t a = frpc::utils::rdtsc();
    sleep(1);
    uint64_t b = frpc::utils::rdtsc();

    return (b - a)/1000000000.0;
}

// <number of threads, number of requests per thread, RPC issue delay>
int main(int argc, char* argv[]) {
    double cycles_in_ns = rdtsc_in_ns();
    std::cout << "Cycles in ns: " << cycles_in_ns << std::endl;

    size_t num_of_threads = atoi(argv[1]);
    size_t num_of_requests = atoi(argv[2]);
    size_t req_delay = atoi(argv[3]);

    if (num_of_threads > 1) {
      std::cout << "Only one thread is currently supported" << std::endl;
      return 1;
    }

    frpc::RpcClientPool<frpc::RpcClientNonBlock> rpc_client_pool(NIC_ADDR,
                                                         num_of_threads);

    // Init client pool
    int res = rpc_client_pool.init_nic();
    if (res != 0)
        return res;

    // Start NIC with perf enabled
    res = rpc_client_pool.start_nic(true);
    if (res != 0)
        return res;

    sleep(1);

    // Run client threads
    std::vector<std::thread> threads;
    for (int i=0; i<num_of_threads; ++i) {
        frpc::RpcClientNonBlock* rpc_client = rpc_client_pool.pop();
        assert(rpc_client != nullptr);

        std::thread thr = std::thread(&run_set_benchmark,
                                      rpc_client,
                                      i,
                                      num_of_requests,
                                      req_delay,
                                      cycles_in_ns);
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

static bool sortbysec(const std::pair<uint32_t,uint64_t> &a,
              const std::pair<uint32_t,uint64_t> &b) {
    return (a.second < b.second);
}

static int run_set_benchmark(frpc::RpcClientNonBlock* rpc_client,
                         int thread_id,
                         size_t num_iterations,
                         size_t req_delay,
                         double cycles_in_ns) {
    uint64_t* timestamp_send = new uint64_t[2*num_iterations+100];
    uint64_t* timestamp_recv = new uint64_t[2*num_iterations+100];

    rpc_client->init_latency_profile(timestamp_send, timestamp_recv);

    // Make an RPC call
    for(int i=0; i<num_iterations; ++i) {
        // Set <key, value> <i, i+10>
        rpc_client->foo(i, i+10);

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
    std::cout << "Thread #" << thread_id
              << ": CQ size= " << cq_size << std::endl;
    //for (int i=0; i<cq_size; ++i) {
    //    std::cout << cq->pop_response().ret_val << std::endl;
    //}

    // Get latency profile
    std::vector<std::pair<uint32_t, uint64_t>> latency_results;
    for (size_t i=0; i<2*num_iterations+100; ++i) {
        if (timestamp_send[i] != 0 && timestamp_recv[i] != 0) {
            latency_results.push_back(std::make_pair(
                                    i, timestamp_recv[i] - timestamp_send[i]));
        }
    }

    std::sort(latency_results.begin(), latency_results.end(), sortbysec);

    std::cout << "***** latency results for thread #" << thread_id
              << " *****" << std::endl;
    std::cout << "  total records= " << latency_results.size() << std::endl;
    std::cout << "  median= "
              << latency_results[latency_results.size()*0.5].second/cycles_in_ns
              << " ns" << std::endl;
    std::cout << "  90th= "
              << latency_results[latency_results.size()*0.9].second/cycles_in_ns
              << " ns" << std::endl;
    std::cout << "  99th= "
              << latency_results[latency_results.size()*0.99].second/cycles_in_ns
              << " ns" << std::endl;

    delete[] timestamp_send;
    delete[] timestamp_recv;
    return 0;
}
