#include <unistd.h>

#include <cstdlib>
#include <iostream>

#include "rpc_threaded_server.h"

// HW parameters
#define NIC_ADDR 0x00000

// RPC functions
static uint32_t foo(uint32_t a, uint32_t b);
static uint32_t boo(uint32_t a);

static uint64_t rdtsc(){
    unsigned int lo, hi;
    __asm__ __volatile__ ("rdtsc" : "=a" (lo), "=d" (hi));
    return ((uint64_t)hi << 32) | lo;
}

// <max number of threads, run duration>
int main(int argc, char* argv[]) {
    size_t num_of_threads = atoi(argv[1]);
    size_t duration_of_run = atoi(argv[2]);

    frpc::RpcThreadedServer server(NIC_ADDR, num_of_threads);

    // Init
    int res = server.init_nic();
    if (res != 0)
        return res;

    // Start server with perf enabled
    res = server.start_nic(true);
    if (res != 0)
        return res;

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
    sleep(duration_of_run);

    res = server.stop_all_listening_threads();
    if (res != 0)
        return res;

    std::cout << "------- Server is stopped. -------" << std::endl;

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
    return a + b;
}

static uint32_t boo(uint32_t a) {
    return a;
}
