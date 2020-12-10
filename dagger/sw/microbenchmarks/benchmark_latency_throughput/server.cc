#include <unistd.h>

#include <cstdlib>
#include <iostream>

#include "rpc_server_callback.h"
#include "rpc_threaded_server.h"

// HW parameters
#define NIC_ADDR 0x00000

// RPC functions
static uint64_t loopback(uint64_t timestamp, uint64_t data);
static uint64_t add(uint64_t timestamp, uint64_t a, uint64_t b);
static uint64_t sign(uint64_t timestamp, uint64_t hash_lsb, uint64_t hash_msb,
                     uint32_t key_0, uint32_t key_1, uint32_t key_2, uint32_t key_3);
static uint64_t xor_(uint64_t timestamp, uint64_t a, uint64_t b, uint64_t c,
                     uint64_t d, uint64_t e, uint32_t f);


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

    // Open connections
    for (int i=0; i<num_of_threads; ++i) {
        frpc::IPv4 client_addr("192.168.0.2", 3136);
        if (server.connect(client_addr, i, i) != 0) {
            std::cout << "Failed to open connection on server" << std::endl;
            exit(1);
        } else {
            std::cout << "Connection is open on server" << std::endl;
        }
    }

    // Register RPC functions
    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(&loopback));
    fn_ptr.push_back(reinterpret_cast<const void*>(&add));
    fn_ptr.push_back(reinterpret_cast<const void*>(&sign));
    fn_ptr.push_back(reinterpret_cast<const void*>(&xor_));

    frpc::RpcServerCallBack server_callback(fn_ptr);

    for (int i=0; i<num_of_threads; ++i) {
        res = server.run_new_listening_thread(&server_callback);
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

static uint64_t loopback(uint64_t timestamp, uint64_t data) {
#ifdef VERBOSE_RPCS
    std::cout << "loopback is called with " << data << std::endl;
#endif
    return timestamp;
}

static uint64_t add(uint64_t timestamp, uint64_t a, uint64_t b) {
#ifdef VERBOSE_RPCS
    std::cout << "add is called with " << a << ", " << b << std::endl;
#endif
    return timestamp;
}

static uint64_t sign(uint64_t timestamp, uint64_t hash_lsb, uint64_t hash_msb,
                     uint32_t key_0, uint32_t key_1, uint32_t key_2, uint32_t key_3) {
#ifdef VERBOSE_RPCS
    std::cout << "sign is called with " << hash_lsb << ", " << hash_msb << ": <"
              << key_0 << " " << key_1 << " " << key_2 << " " << key_3 << ">" << std::endl;
#endif
    return timestamp;
}

static uint64_t xor_(uint64_t timestamp, uint64_t a, uint64_t b, uint64_t c,
                     uint64_t d, uint64_t e, uint32_t f) {
#ifdef VERBOSE_RPCS
    std::cout << "xor_ is called with " << a << " " << b << " " << c << " "
                                        << d << " " << e << " " << f << std::endl;
#endif
    return timestamp;
}
