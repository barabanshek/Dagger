#include <iostream>

#include <cstdlib>
#include <unistd.h>

#include "rpc_threaded_server.h"

// HW parameters
#define NIC_ADDR 0x00000

// RPC functions
static uint32_t foo(uint32_t a, uint32_t b);
static uint32_t boo(uint32_t a);

static int mc_call();

uint64_t rdtsc(){
    unsigned int lo, hi;
    __asm__ __volatile__ ("rdtsc" : "=a" (lo), "=d" (hi));
    return ((uint64_t)hi << 32) | lo;
}

int main(int argc, char* argv[]) {
    size_t num_of_threads = atoi(argv[1]);

    frpc::RpcThreadedServer server(NIC_ADDR, num_of_threads);

    // Init
    int res = server.init_nic();
    if (res != 0)
        return res;

    // Start server with perf enabled
    res = server.start_nic(true);
    if (res != 0)
        return res;

    // Run memory contention threads
    //std::vector<std::thread> mc_threads;
    //for (int i=0; i<4; ++i) {
    //    std::thread thr = std::thread(&mc_call);
    //    mc_threads.push_back(std::move(thr));
    //}

    // Register RPC functions
    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(&foo));
    fn_ptr.push_back(reinterpret_cast<const void*>(&boo));

    for (int i=0; i<num_of_threads; ++i) {
        res = server.run_new_listening_thread(fn_ptr);
        if (res != 0)
            return res;
    }

    std::cout << "------- Server is running... -------" << std::endl;
    sleep(120); // Run server for 10 sec

    res = server.stop_all_listening_threads();
    if (res != 0)
        return res;

    std::cout << "Server is stopped!" << std::endl;

    // Check for HW errors
    res = server.check_hw_errors();
    if (res != 0)
        std::cout << "HW errors found, check error log" << std::endl;
    else
        std::cout << "No HW errors found" << std::endl;

    // Stop NIC
    res = server.stop_nic();
    if (res != 0)
        return res;

    return 0;
}

static uint32_t foo(uint32_t a, uint32_t b) {
    //std::cout << "foo is called with a= " << a << ", b= " << b << std::endl;
    return a + b;
}

static uint32_t boo(uint32_t a) {
    //std::cout << "boo is called with a= " << a << std::endl;
    return a + 10;
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
