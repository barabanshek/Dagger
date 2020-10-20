//
// Intel OPAE ASE simulator does not allow running multiple applications at
// the same time. This wrapper runs both client and server in a single UNIX
// process.
//
// NOTE: there is not such issue when running under a real FPGA, so client and
// server can be used as independent standalone processes.
//

#include <iostream>
#include <vector>
#include <thread>

#include <assert.h>
#include <unistd.h>

#define FRPC_LOG_LEVEL_GLOBAL FRPC_LOG_LEVEL_INFO

#include "rpc_client.h"
#include "rpc_client_nonblocking.h"
#include "rpc_client_pool.h"
#include "rpc_threaded_server.h"

#define NUMBER_OF_THREADS 1

static int run_server();
static int run_client();

int main() {
    std::thread server_thread = std::thread(&run_server);
    std::thread client_thread = std::thread(&run_client);

    client_thread.join();
    server_thread.join();

    return 0;
}

//
// Server part
//
#define SERVER_NIC_ADDR 0x20000

static uint32_t foo(uint32_t a, uint32_t b);
static uint32_t boo(uint32_t a);

static int run_server() {
    frpc::RpcThreadedServer server(SERVER_NIC_ADDR, NUMBER_OF_THREADS);

    // Init
    int res = server.init_nic();
    if (res != 0)
        return res;

    // Start NIC with perf enabled
    res = server.start_nic(true);
    if (res != 0)
        return res;

    // Register RPC functions
    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(&foo));
    fn_ptr.push_back(reinterpret_cast<const void*>(&boo));

    for (int i=0; i<NUMBER_OF_THREADS; ++i) {
        res = server.run_new_listening_thread(fn_ptr);
        if (res != 0)
            return res;
    }

    std::cout << "------- Server is running... -------" << std::endl;
    sleep(40); // Run server for 10 sec

    res = server.stop_all_listening_threads();
    if (res != 0)
        return res;

    std::cout << "Server is stopped!" << std::endl;

    // Stop NIC
    res = server.stop_nic();
    if (res != 0)
        return res;

    sleep(5);

    return 0;
}

// RPC function #0
static uint32_t foo(uint32_t a, uint32_t b) {
    std::cout << "foo is called with a= " << a << ", b= " << b << std::endl;
    return a + b;
}
    
// RPC function #1
static uint32_t boo(uint32_t a) {
    std::cout << "boo is called with a= " << a << std::endl;
    return a + 10;
}


//
// Client part
//
#define CLIENT_NIC_ADDR 0x00000
#define NUM_OF_REQUESTS 20

static int client(frpc::RpcClientNonBlock* rpc_client, size_t thread_id, size_t num_of_requests) {
    // Get completion queue
    frpc::CompletionQueue* cq = rpc_client->get_completion_queue();
    assert(cq != nullptr);

    // Make an RPC call
    for (int i=0; i<num_of_requests; ++i) {
        int res = rpc_client->foo(thread_id*10 + i, 12);
        assert(res == 0);

        usleep(100000);

        for (int delay=0; delay<13; ++delay) {
            asm("");
        }
    }

    // Wait a bit
    sleep(30);

    // Read completion queue
    size_t n_of_cq_entries = cq->get_number_of_completed_requests();
    std::cout << "Thread " << thread_id << ", CQ entries: " << n_of_cq_entries << std::endl;
    for (int i=0; i<n_of_cq_entries; ++i) {
        std::cout << "Thread " << thread_id << ", RPC returned: " << 
                         *reinterpret_cast<uint32_t*>(cq->pop_response().argv) << std::endl;
    }

    return 0;
}

static int run_client() {
    frpc::RpcClientPool<frpc::RpcClientNonBlock> rpc_client_pool(CLIENT_NIC_ADDR,
                                                                 NUMBER_OF_THREADS);

    // Init client pool
    int res = rpc_client_pool.init_nic();
    if (res != 0)
        return res;

    // Start NIC
    res = rpc_client_pool.start_nic(true);
    if (res != 0)
        return res;

    // Get client
    std::vector<std::thread> threads;
    for (int i=0; i<NUMBER_OF_THREADS; ++i) {
        frpc::RpcClientNonBlock* rpc_client = rpc_client_pool.pop();
        assert(rpc_client != nullptr);

        std::thread thr = std::thread(&client,
                                      rpc_client,
                                      i,
                                      NUM_OF_REQUESTS);
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

    sleep(5);

    return 0;
}
