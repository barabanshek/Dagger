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

#include "AirpordDbService_rpc_server_callback.h"
#include "AirpordDbService_rpc_types.h"

#include "rpc_call.h"
#include "rpc_client_pool.h"
#include "rpc_threaded_server.h"

#include "hash.h"
#include "mehcached.h"

//
// Main part
//
#define SERVER_NIC_ADDR 0x24000

static constexpr char* check_in_host_addr = "0.0.0.2";
static constexpr char* stuff_frontend_host_addr = "0.0.0.8";
static constexpr int stuff_fronten_c_id = 7;

static RpcRetCode check_flight(CallHandler handler, FlightData req, FlightStatus* resp);
static RpcRetCode check_baggage(CallHandler handler, PassengerData req, BaggageStatus* resp);
static RpcRetCode check_passport(CallHandler handler, PassengerData req, PassportStatus* resp);
static RpcRetCode register_passenger(CallHandler handler, RegPassengerData req, RegStatus* resp);
static RpcRetCode get_flight(CallHandler handler, FlightData req, PassengerData* resp);

// Global mica mehcached object
static std::vector<mehcached_table*> tables;

static int mica_set(size_t thread_id, uint8_t key, char* value);
static int mica_get(size_t thread_id, uint8_t key, uint8_t* value);

// Ctl-C handler
static volatile int keepRunning = 1;
void intHandler(int dummy) {
    keepRunning = 0;
}

int main(int argc, char* argv[]) {
    size_t num_of_threads = atoi(argv[1]);

    // Setup MICA backend
    const size_t num_items = 16 * 1048576;  // 16.7M
    const size_t num_partitions = num_of_threads;
    size_t alloc_overhead = sizeof(struct mehcached_item);
    const size_t key_length = 8;
    const size_t value_length = 32;

    const size_t page_size = 1048576 * 2;
    const size_t num_numa_nodes = 1;
    const size_t num_pages_to_try = 1024;
    const size_t num_pages_to_reserve = 1024;

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
        frpc::IPv4 check_in_addr(check_in_host_addr, 3136);
        if (server.connect(check_in_addr, 3, 0) != 0) {
            std::cout << "Airport_service> failed to open connection on server" << std::endl;
            exit(1);
        } else {
            std::cout << "Airport_service> connection is open on server" << std::endl;
        }
    }

    // Open connections with the up-stream service (stuff_frontend)
    frpc::IPv4 stuff_frontend_addr(stuff_frontend_host_addr, 3136);
    if (server.connect(stuff_frontend_addr, stuff_fronten_c_id, 0) != 0) {
        std::cout << "Airport_service> failed to open connection on server" << std::endl;
        exit(1);
    } else {
        std::cout << "Airport_service> connection is open on server" << std::endl;
    }

    // Register RPC functions
    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(&check_flight));
    fn_ptr.push_back(reinterpret_cast<const void*>(&check_baggage));
    fn_ptr.push_back(reinterpret_cast<const void*>(&check_passport));
    fn_ptr.push_back(reinterpret_cast<const void*>(&register_passenger));
    fn_ptr.push_back(reinterpret_cast<const void*>(&get_flight));

    frpc::RpcServerCallBack server_callback(fn_ptr);

    for (int i=0; i<num_of_threads; ++i) {
        res = server.run_new_listening_thread(&server_callback);
        if (res != 0)
            return res;
    }

    std::cout << "------- Airport_service is running... -------" << std::endl;

    std::cout << "Airport_service> Press Ctrl+C to stop..." << std::endl;
    signal(SIGINT, intHandler);

    while(keepRunning) {
        sleep(1);
    }

    res = server.stop_all_listening_threads();
    if (res != 0)
        return res;

    std::cout << "------- Airport_service is stopped! -------" << std::endl;

    // Check for HW errors
    res = server.check_hw_errors();
    if (res != 0)
        std::cout << "Airport_service> HW errors found in server, check error log" << std::endl;
    else
        std::cout << "Airport_service> no HW errors found in server" << std::endl;

    // Stop NIC
    res = server.stop_nic();
    if (res != 0)
        return res;

    // Stop MICA KVS
    for (auto t: tables) {
        mehcached_print_stats(t);
        mehcached_table_free(t);
        delete t;
    }

    return 0;
}

static RpcRetCode check_flight(CallHandler handler, FlightData req, FlightStatus* resp) {
    assert(false);
}

static RpcRetCode check_baggage(CallHandler handler, PassengerData req, BaggageStatus* resp) {
    assert(false);
}

static RpcRetCode check_passport(CallHandler handler, PassengerData req, PassportStatus* resp) {
    assert(false);
}

static RpcRetCode register_passenger(CallHandler handler, RegPassengerData req, RegStatus* resp) {
#ifdef _SERVICE_VERBOSE_
    std::cout << "#" << req.trace_id << " Airport_service> register_passenger received for <"
              << req.first_name << ", " << req.last_name << ">" << ", flight number #"
              << static_cast<int>(req.flight_number)
              << ", seat number #" << static_cast<int>(req.seat_number) << std::endl;
#endif
    // Set
    int res = mica_set(0, req.flight_number, req.first_name);
    if (res != 0) {
        resp->timestamp = req.timestamp;
        resp->trace_id = req.trace_id;
        sprintf(resp->status, "ERR");

        return RpcRetCode::Success;
    }

    // Return
    resp->timestamp = req.timestamp;
    resp->trace_id = req.trace_id;
    sprintf(resp->status, "OK");

    return RpcRetCode::Success;
}

static RpcRetCode get_flight(CallHandler handler, FlightData req, PassengerData* resp) {
#ifdef _SERVICE_VERBOSE_
    std::cout << "#" << req.trace_id << " Airport_service> get_flight received for flight number #"
              << static_cast<int>(req.flight_number) << std::endl;
#endif
    char value[64];
    int res = mica_get(0, req.flight_number, reinterpret_cast<uint8_t*>(&value[0]));
    if (res != 0) {
        resp->timestamp = req.timestamp;
        resp->trace_id = req.trace_id;
        sprintf(resp->first_name, "");
        sprintf(resp->last_name, "");

        return RpcRetCode::Success;
    }

    // Return
    resp->timestamp = req.timestamp;
    resp->trace_id = req.trace_id;
    sprintf(resp->first_name, &value[0]);
    sprintf(resp->last_name, &value[0]);

    return RpcRetCode::Success;
}



//
// Cache: MICA KVS
//
static int mica_set(size_t thread_id, uint8_t key, char* value) {
    size_t key_ = static_cast<size_t>(key);
    size_t key_length = 8;

    uint64_t key_hash = hash(reinterpret_cast<const uint8_t*>(&key_), key_length);

    if (!mehcached_set(0,
                       tables[thread_id],
                       key_hash, 
                       reinterpret_cast<const uint8_t*>(&key_),
                       key_length,
                       reinterpret_cast<const uint8_t*>(value),
                       strlen(value) + 1,
                       0,
                       true)) {
        return 1;
    }

    return 0;
}

static int mica_get(size_t thread_id, uint8_t key, uint8_t* value) {
    size_t key_ = static_cast<size_t>(key);
    size_t key_length = 8;
    size_t value_length = 64;

    uint64_t key_hash = hash(reinterpret_cast<const uint8_t*>(&key_), key_length);

    if (!mehcached_get(0,
                       tables[thread_id],
                       key_hash,
                       reinterpret_cast<const uint8_t*>(&key_),
                       key_length,
                       value,
                       &value_length,
                       NULL,
                       false)) {
        return 1;
    }

    return 0;
}
