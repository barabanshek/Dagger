#include <csignal>
#include <cassert>
#include <iomanip>
#include <iostream>

#include "hash.h"
#include "mehcached.h"

#include "rpc_call.h"
#include "rpc_server_callback.h"
#include "rpc_threaded_server.h"
#include "rpc_types.h"
#include "CLI11.hpp"

// HW parameters
#define NIC_ADDR 0x00000

// Global mica mehcached object
static std::vector<mehcached_table*> tables;

static RpcRetCode set(CallHandler handler, SetRequest args, SetResponse* ret);
static RpcRetCode get(CallHandler handler, GetRequest args, GetResponse* ret);
static RpcRetCode populate(CallHandler handler, PopulateRequest args, PopulateResponse* ret);

// Ctl-C handler
static volatile int keepRunning = 1;

void intHandler(int dummy) {
    keepRunning = 0;
}

void perf_callback(const std::vector<uint64_t>& counters) {
    uint64_t rps_in = counters[1];
    uint64_t rps_out = counters[0];
    if (rps_in > 0) {
        std::cout << std::fixed << std::setprecision(2) << "Dropped requests: "
                  << 100*(rps_in - rps_out)/(double)rps_in << "%" << std::endl;
    }
}

int main(int argc, char* argv[]) {
    // Parse input
    CLI::App app{"MICA server"};
    size_t num_of_threads;
    app.add_option("-t, --threads", num_of_threads, "number of threads")->required();

    CLI11_PARSE(app, argc, argv);

    // Set-up MICA KVS
    const size_t num_items = 16 * 1048576;  // 16.7M
    const size_t num_partitions = num_of_threads;
    size_t alloc_overhead = sizeof(struct mehcached_item);
    const size_t key_length = 16;//MEHCACHED_ROUNDUP8(8);
    const size_t value_length = 16;//MEHCACHED_ROUNDUP8(8);

    const size_t page_size = 1048576 * 2;
    const size_t num_numa_nodes = 1;
    const size_t num_pages_to_try = 2048*num_partitions;    // 16384
    const size_t num_pages_to_reserve = 2048*num_partitions;    // 16384

    mehcached_shm_init(page_size, num_numa_nodes, num_pages_to_try, num_pages_to_reserve);

    // Allocate MICA partitions
    for (size_t i=0; i<num_partitions; ++i) {
        mehcached_table* tbl = new mehcached_table();
        size_t numa_nodes[] = {(size_t)-1};
        mehcached_table_init(tbl,
                             (num_items + MEHCACHED_ITEMS_PER_BUCKET - 1) / MEHCACHED_ITEMS_PER_BUCKET / num_partitions,
                             1,
                             num_items * (alloc_overhead + key_length + value_length + (num_partitions - 1)) / 1 / num_partitions,
                             false,
                             false,
                             false,
                             numa_nodes[0],
                             numa_nodes,
                             MEHCACHED_MTH_THRESHOLD_FIFO);
        assert(tbl);

        tables.push_back(tbl);
    }

    // Set-up Dagger
    dagger::RpcThreadedServer server(NIC_ADDR, num_of_threads);

    // Init
    int res = server.init_nic();
    if (res != 0)
        return res;

    // Start server with perf enabled
    res = server.start_nic();
    if (res != 0)
        return res;

    // set and enable perf
    res = server.run_perf_thread({true, true, true}, &perf_callback);
    if (res != 0)
        return res;

    // Open connections
    for (int i=0; i<num_of_threads; ++i) {
        dagger::IPv4 client_addr("192.168.0.2", 3136);
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
    fn_ptr.push_back(reinterpret_cast<const void*>(&populate));

    dagger::RpcServerCallBack server_callback(fn_ptr);

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

    std::cout << "------- Server is stopped -------" << std::endl;

    for (auto t: tables) {
        mehcached_print_stats(t);
        mehcached_table_free(t);
        delete t;
    }

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

static RpcRetCode set(CallHandler handler, SetRequest args, SetResponse* ret) {
    char* key = args.key;
    char* value = args.value;

    uint64_t key_hash = hash(reinterpret_cast<const uint8_t*>(key), strlen(key));
    if (!mehcached_set(0,
                       tables[handler.thread_id],
                       key_hash, 
                       reinterpret_cast<const uint8_t*>(key),
                       strlen(key),
                       reinterpret_cast<const uint8_t*>(value),
                       strlen(value),
                       0,
                       true)) {
        ret->timestamp = args.timestamp;
        sprintf(ret->status, "ERROR");
        return RpcRetCode::Success;
    }

    ret->timestamp = args.timestamp;
    sprintf(ret->status, "OK");
    return RpcRetCode::Success;
}

static RpcRetCode get(CallHandler handler, GetRequest args, GetResponse* ret) {
    char* key = args.key;
    char value[64];
    size_t value_length = 64;

    uint64_t key_hash = hash(reinterpret_cast<const uint8_t*>(key), strlen(key));
    if (!mehcached_get(0,
                       tables[handler.thread_id],
                       key_hash,
                       reinterpret_cast<const uint8_t*>(key),
                       strlen(key),
                       reinterpret_cast<uint8_t*>(&value[0]),
                       &value_length,
                       NULL,
                       false)) {
        ret->timestamp = args.timestamp;
        ret->value[0] = '\0';
        return RpcRetCode::Success;
    }

    //
    //std::cout << "value= " << value << std::endl;

    ret->timestamp = args.timestamp;
    sprintf(ret->value, value);
    return RpcRetCode::Success;
}

static RpcRetCode populate(CallHandler handler, PopulateRequest args, PopulateResponse* ret) {
    const char* dataset_filename = args.dataset;
    std::cout << "loading the dataset " << dataset_filename << std::endl;

    FILE* fp;
    char* line = NULL;
    size_t len = 0;
    ssize_t read;

    fp = fopen(dataset_filename, "r");
    if (fp == NULL) {
        sprintf(ret->status, "Failed to open dataset file\r");
        return RpcRetCode::Success;
    }

    // get sizes
    if (getline(&line, &len, fp) == -1) {
        sprintf(ret->status, "First line is not found\r");
        return RpcRetCode::Success;
    }
    size_t key_size = atoi(line);

    if (getline(&line, &len, fp) == -1) {
        sprintf(ret->status, "Second line is not found\r");
        return RpcRetCode::Success;
    }
    size_t value_size = atoi(line);

    if (getline(&line, &len, fp) == -1) {
        sprintf(ret->status, "Third line is not found\r");
        return RpcRetCode::Success;
    }
    size_t number_of_samples = atoi(line);

    std::cout << "  key size: " << key_size << std::endl;
    std::cout << "  value size: " << value_size << std::endl;
    std::cout << "  number of samples: " << number_of_samples << std::endl;

    size_t i = 0;
    char* key = new char[key_size+10];
    char* value = new char[value_size+10];
    while ((read = getline(&line, &len, fp)) != -1) {
        memcpy(key, line, key_size);
        key[key_size] = '\0';

        memcpy(value, line + key_size + 1, value_size);
        value[value_size] = '\0';

        uint64_t key_hash = hash(reinterpret_cast<const uint8_t*>(key), strlen(key));
        if (i%1000 == 0) {
            std::cout << "inserting <" << key << ", " << value << ">, hash= " << key_hash << std::endl;
        }
        if (!mehcached_set(0,
                           tables[handler.thread_id],
                           key_hash, 
                           reinterpret_cast<const uint8_t*>(key),
                           strlen(key),
                           reinterpret_cast<const uint8_t*>(value),
                           strlen(value),
                           0,
                           true)) {
            sprintf(ret->status, "Failed to loa dataset, loaded %zu\r", i);
            delete[] key;
            delete[] value;
            return RpcRetCode::Success;
        }

        ++i;
    }

    // Try random keys
    sprintf(key, "_______4");
    char value1[64];
    size_t value_length = 64;
    uint64_t key_hash = hash(reinterpret_cast<const uint8_t*>(key), strlen(key));
    if (!mehcached_get(0,
                       tables[handler.thread_id],
                       key_hash,
                       reinterpret_cast<const uint8_t*>(key),
                       strlen(key),
                       reinterpret_cast<uint8_t*>(&value1[0]),
                       &value_length,
                       NULL,
                       false)) {
        std::cout << "try= " << key << " - not found!" << std::endl;
    }
    std::cout << "try= " << key << "," << value1 << std::endl;

    delete[] key;
    delete[] value;

    if (i != number_of_samples) {
        sprintf(ret->status, "dataset corrupted\r");
        return RpcRetCode::Success;
    }

    sprintf(ret->status, "%zu values loaded\r", i);
    return RpcRetCode::Success;
}
