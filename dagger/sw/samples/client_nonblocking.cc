#include <iostream>
#include <thread>

#include <assert.h>

#include <cstdlib>
#include <fstream>
#include <algorithm>
#include <inttypes.h>
#include <unistd.h>
#include <vector>
#include <unordered_map>

#include "rpc_client.h"
#include "rpc_client_nonblocking.h"
#include "rpc_client_pool.h"

// HW parameters
#define NIC_ADDR 0x20000

static int benchmark_latency(frpc::RpcClientNonBlock* rpc_client,
                             int thread_id,
                             size_t num_iterations,
                             size_t req_delay);
static void dumpToFile(const char* filename,
                       uint64_t* request_hist,
                       size_t num_iterations,
                       size_t thread_id);

uint64_t rdtsc(){
    unsigned int lo, hi;
    __asm__ __volatile__ ("rdtsc" : "=a" (lo), "=d" (hi));
    return ((uint64_t)hi << 32) | lo;
}

double rdtsc_in_ns() {
    uint64_t a = rdtsc();
    sleep(1);
    uint64_t b = rdtsc();

    return (b - a)/1000000000.0;
}

int main(int argc, char* argv[]) {
    std::cout << "Cycles in ns: " << rdtsc_in_ns() << std::endl;

    size_t num_of_threads = atoi(argv[1]);
    size_t num_of_requests = atoi(argv[2]);
    size_t req_delay = atoi(argv[3]);

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

    // Run client threads
    std::vector<std::thread> threads;
    for (int i=0; i<num_of_threads; ++i) {
        frpc::RpcClientNonBlock* rpc_client = rpc_client_pool.pop();
        assert(rpc_client != nullptr);

        std::thread thr = std::thread(&benchmark_latency,
                                      rpc_client,
                                      i,
                                      num_of_requests,
                                      req_delay);
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

pthread_mutex_t log_file_lock;
static void dumpToFile(const char* filename,
                       uint64_t* request_hist,
                       size_t num_iterations,
                       size_t thread_id) {
    size_t i = 0;

    pthread_mutex_lock(&log_file_lock);
    {
        FILE *fp;
        fp = fopen(filename, "a");
        fprintf(fp, ">>> Latencies for thread_id %zu>>\n", thread_id);
        for (i=0; i<num_iterations; ++i) {
            fprintf(fp, "%"PRIu64"\n", request_hist[i]);
        }

        fclose(fp);
    }
    pthread_mutex_unlock(&log_file_lock); 
}

//static uint64_t* latency_client_1, latency_client_2;

static std::unordered_map<uint32_t, uint64_t> dict;
static std::vector<std::pair<uint32_t, uint64_t>> latency_results;

static bool sortbysec(const std::pair<uint32_t,uint64_t> &a, 
              const std::pair<uint32_t,uint64_t> &b) 
{ 
    return (a.second < b.second); 
}

static int benchmark_latency(frpc::RpcClientNonBlock* rpc_client,
                             int thread_id,
                             size_t num_iterations,
                             size_t req_delay) {
    //uint64_t* request_data = new uint64_t[num_iterations];
    //uint64_t* latency_client_1 = new uint64_t[num_iterations + 100];
    //uint64_t* latency_client_2 = new uint64_t[num_iterations + 100];

    //for (int i=0; i<num_iterations+1; ++i) {
    //    request_data[i] = 10;//rand() % 1000000000;
    //    latency_client_1[i+10] = 0;
    //    latency_client_2[i+10] = 0;
    //}

    //std::unordered_map<uint32_t, uint32_t> rpc_history;
    //for(int i=0; i<num_iterations; ++i) {
    //    rpc_history[i] = request_data[i];
    //}

    
    //pc_client->init_latency(latency_client_1, latency_client_2);

    // Make an RPC call
    //size_t a = rdtsc();
    for(int i=0; i<num_iterations; ++i) {
        rpc_client->foo(i, 0/*request_data[i]*/);

       // Blocking delay to control rps rate
       for (int delay=0; delay<req_delay; ++delay) {
           asm("");
       }
    }
    //size_t b = rdtsc();
    //std::cout << "cycles: " << (b - a) << std::endl;

    sleep(5);

    // Get data
    auto cq = rpc_client->get_completion_queue();
    size_t cq_size = cq->get_number_of_completed_requests();
    std::cout << "CQ size= " << cq_size << std::endl;
    //for (int i=0; i<cq_size; ++i) {
    //    std::cout << "  return: " << cq->pop_response().ret_val << std::endl;
    //}

    //for (size_t i=10; i<NUM_ITERATIONS+10; ++i) {
    //    dict[i] = latency_client_1[i];
    //}

    //for (size_t i=10; i<NUM_ITERATIONS+10; ++i) {
    //    //auto it = dict.find(i);
    //    if (latency_client_1[i] != 0 && latency_client_2[i] != 0) {
    //        //std::cout << "KV: " << i.first << "->" << i.second << ":" << it->second << std::endl;
    //        latency_results.push_back(std::make_pair(i, latency_client_2[i] - latency_client_1[i]));
    //    }
    //}

    //for (auto i: latency_results) {
    //    std::cout << i << std::endl;
    //}
    //std::cout << "----------------" << std::endl;
    //std::sort(latency_results.begin(), latency_results.end(), sortbysec);
    //for (auto i: latency_results) {
    //    std::cout << i << std::endl;
    //}
    //std::cout << "----------------" << std::endl;

    //std::cout << "***** latency results *****" << std::endl;
    //std::cout << "  total records= " << latency_results.size() << std::endl;
    //std::cout << "  median= " << latency_results[latency_results.size()*0.5].second/2.4 << " ns" << std::endl;
    //std::cout << "  90th= " << latency_results[latency_results.size()*0.9].second/2.4 << " ns" << std::endl;
    //std::cout << "  99th= " << latency_results[latency_results.size()*0.99].second/2.4 << " ns" << std::endl;

    //std::cout << "lat1= " << dict[latency_results[latency_results.size()*0.9].first] << std::endl;
    //for (auto i: latency_client_2) {
    //    if (i.first == latency_results[latency_results.size()*0.9].first) {
    //        std::cout << "lat1= " << i.second << std::endl;
    //    }
    //}


    //size_t total_cycles = 0;
    //size_t num_packets = 0;
    //for(auto it = latency_client_2.begin(); it != latency_client_2.end(); ++it) {
    //    // std::cout << "cycles: " << (p.second - p.first) << std::endl;
    //    total_cycles += (it->second - latency_client_1[it->first]);
    //    ++num_packets;
    //}
    //double avg_cycles = total_cycles/num_packets;
    //std::cout << "avg cycles: " << avg_cycles << std::endl;
    //std::cout << "proper packets recorded: " << num_packets <<std::endl;

    // Check for correctness
    //bool error = false;
    //for(int i=0; i<cq_size; ++i) {
    //    uint64_t expected = rpc_history[]
    //    if (request_return[i] != expected) {
    //        std::cout << "Error found in thread " << thread_id
    //                  << " for element " << i
    //                  << ": " << request_return[i] << " != " << expected
    //                  << std::endl;
    //        error = true;
    //    }
    //}
    //if (error) {
    //    std::cout << "Errors found in RPC processing for thread "
    //              << thread_id << std::endl;
    //} else {
    //    std::cout << "No errors found in thread " << thread_id << std::endl;
    //}


    // Drop latency results to a file
    //dumpToFile("latency_cycles.txt", request_hist, num_iterations, thread_id);

    //delete[] request_hist;
    // /delete[] request_data;
    return 0;
}
