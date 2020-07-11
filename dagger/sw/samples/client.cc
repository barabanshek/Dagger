#include <iostream>
#include <thread>

#include <assert.h>
#include <inttypes.h>
#include <unistd.h>

#include "rpc_client.h"
#include "rpc_client_nonblocking.h"
#include "rpc_client_pool.h"

// HW parameters
#define NIC_ADDR 0x00000

// Thread pool parameters
#define NUMBER_OF_THREADS 4
#define NUM_ITERATIONS 10000000

static int mc_call();
static int benchmark_latency(frpc::RpcClient* rpc_client,
                             int thread_id,
                             size_t num_iterations);
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

int main() {
    std::cout << "Cycles in ns: " << rdtsc_in_ns() << std::endl;

    frpc::RpcClientPool<frpc::RpcClient> rpc_client_pool(NIC_ADDR,
                                                         NUMBER_OF_THREADS);

    // Init client pool
    int res = rpc_client_pool.init_nic();
    if (res != 0)
        return res;

    // Start NIC with perf enabled
    res = rpc_client_pool.start_nic(true);
    if (res != 0)
        return res;

    // Run memory contention threads
    //std::vector<std::thread> mc_threads;
    //for (int i=0; i<4; ++i) {
    //    std::thread thr = std::thread(&mc_call);
    //    mc_threads.push_back(std::move(thr));
    //}

    // Run client threads
    std::vector<std::thread> threads;
    for (int i=0; i<NUMBER_OF_THREADS; ++i) {
        frpc::RpcClient* rpc_client = rpc_client_pool.pop();
        assert(rpc_client != nullptr);

        std::thread thr = std::thread(&benchmark_latency,
                                      rpc_client,
                                      i,
                                      NUM_ITERATIONS);
        threads.push_back(std::move(thr));
    }

    for (auto& thr: threads) {
        thr.join();
    }

    //for (auto& thr: mc_threads) {
    //    thr.join();
    //}

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

// Memory contention function
static int mc_call() {
    std::cout << "***************** memory contention workload started ********************" << std::endl;
    // Allocate huge array for memory intensive workload
    size_t dummy_array_size = 5000000000;
    volatile uint8_t* dummy_array = new uint8_t[dummy_array_size];

    // Memory intensive workload
    uint64_t a = rdtsc();
    for (size_t i=0; i<5000000000; ++i) {
        dummy_array[i] = i & 0xff;
    }
    uint64_t b = rdtsc();

    int res = 0;
    for (size_t i=0; i<1000; ++i) {
        res += dummy_array[rand() % dummy_array_size];
    }
    std::cout << "***************** memory contention workload finished: " << (b - a) << " ********************" << std::endl;
    return res;
}

static int benchmark_latency(frpc::RpcClient* rpc_client,
                             int thread_id,
                             size_t num_iterations) {
    uint64_t* request_hist = new uint64_t[num_iterations];
    uint64_t* request_data = new uint64_t[num_iterations];
    uint64_t* request_return = new uint64_t[num_iterations];

    for (int i=0; i<num_iterations+1; ++i) {
        request_data[i] = rand() % 1000000000;
    }

    // Make an RPC call
    for(int i=0; i<num_iterations; ++i) {
        uint64_t a = rdtsc();
        request_return[i] = rpc_client->foo(request_data[i] + thread_id,
                                            request_data[i+1] + i);
        uint64_t b = rdtsc();

        request_hist[i] = b - a;

        // Blocking delay to control rps rate
        //for (int delay=0; delay<10000; ++delay) {
        //    asm("");
        //}
    }

    // Check for correctness
    bool error = false;
    for(int i=0; i<num_iterations; ++i) {
        uint64_t expected = request_data[i] + thread_id + request_data[i+1] + i;
        if (request_return[i] != expected) {
            std::cout << "Error found in thread " << thread_id
                      << " for element " << i
                      << ": " << request_return[i] << " != " << expected
                      << std::endl;
            error = true;
        }
    }
    if (error) {
        std::cout << "Errors found in RPC processing for thread "
                  << thread_id << std::endl;
    } else {
        std::cout << "No errors found in thread " << thread_id << std::endl;
    }

    // Drop latency results to a file
    dumpToFile("latency_cycles.txt", request_hist, num_iterations, thread_id);

    delete[] request_hist;
    delete[] request_data;
    delete[] request_return;
    return 0;
}
