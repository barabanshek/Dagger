#include <csignal>
#include <cassert>
#include <iostream>

#include "hash.h"
#include "mehcached.h"

#include "rpc_call.h"
#include "rpc_server_callback.h"
#include "rpc_threaded_server.h"
#include "rpc_types.h"

// HW parameters
#define NIC_ADDR 0x00000

// Global mica mehcached object
static mehcached_table *table;

static frpc::RpcRetCode set(SetRequest args, SetResponse* ret);
static frpc::RpcRetCode get(GetRequest args, GetResponse* ret);

// Ctl-C handler
static volatile int keepRunning = 1;

void intHandler(int dummy) {
    keepRunning = 0;
}

int main(int argc, char* argv[]) {
    // Set-up MICA KVS
    const size_t page_size = 1048576 * 2;
    const size_t num_numa_nodes = 1;
    const size_t num_pages_to_try = 128;//1024;
    const size_t num_pages_to_reserve = 128;//1024;

    mehcached_shm_init(page_size, num_numa_nodes, num_pages_to_try, num_pages_to_reserve);

    mehcached_table table_o;
    table = &table_o;
    size_t numa_nodes[] = {(size_t)-1};
    mehcached_table_init(table, 1, 1, 256, false, false, false, numa_nodes[0], numa_nodes, MEHCACHED_MTH_THRESHOLD_FIFO);
    assert(table);

    // Set-up Dagger
    size_t num_of_threads = atoi(argv[1]);
    bool with_perf = false;
    if (argc == 3 && strcmp(argv[2], "--stat") == 0) {
        with_perf = true;
    }

    frpc::RpcThreadedServer server(NIC_ADDR, num_of_threads);

    // Init
    int res = server.init_nic();
    if (res != 0)
        return res;

    // Start server with perf enabled
    res = server.start_nic(with_perf);
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
    fn_ptr.push_back(reinterpret_cast<const void*>(&set));
    fn_ptr.push_back(reinterpret_cast<const void*>(&get));

    frpc::RpcServerCallBack server_callback(fn_ptr);

    for (int i=0; i<num_of_threads; ++i) {
        res = server.run_new_listening_thread(&server_callback);
        if (res != 0)
            return res;
    }

    std::cout << "------- Server is running -------" << std::endl;

    std::cout << "Press Ctrl+C to stop..." << std::endl;
    signal(SIGINT, intHandler);

    while (keepRunning) {
        sleep(1);
    }

    res = server.stop_all_listening_threads();
    if (res != 0)
        return res;

    std::cout << "------- Server is stopped. -------" << std::endl;

    mehcached_print_stats(table);
    mehcached_table_free(table);

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

static frpc::RpcRetCode set(SetRequest args, SetResponse* ret) {
    char* key = args.key;
    char* value = args.value;

    uint64_t key_hash = hash(reinterpret_cast<const uint8_t*>(key), strlen(key));
    if (!mehcached_set(0,
                       table,
                       key_hash, 
                       reinterpret_cast<const uint8_t*>(key),
                       strlen(key),
                       reinterpret_cast<const uint8_t*>(value),
                       strlen(value),
                       0,
                       false)) {
        ret->timestamp = args.timestamp;
        sprintf(ret->value, "ERROR");
        return frpc::RpcRetCode::Success;
    }

    ret->timestamp = args.timestamp;
    sprintf(ret->value, "OK");
    return frpc::RpcRetCode::Success;
}

static frpc::RpcRetCode get(GetRequest args, GetResponse* ret) {
    char* key = args.key;
    char value[64];
    size_t value_length = 64;

    uint64_t key_hash = hash(reinterpret_cast<const uint8_t*>(key), strlen(key));
    if (!mehcached_get(0,
                       table,
                       key_hash,
                       reinterpret_cast<const uint8_t*>(key),
                       strlen(key),
                       reinterpret_cast<uint8_t*>(&value[0]),
                       &value_length,
                       NULL,
                       false)) {
        ret->timestamp = args.timestamp;
        ret->value[0] = '\0';
        return frpc::RpcRetCode::Success;
    }

    ret->timestamp = args.timestamp;
    sprintf(ret->value, value);
    return frpc::RpcRetCode::Success;
}
