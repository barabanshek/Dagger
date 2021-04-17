#include <unistd.h>

#include <csignal>
#include <cstdlib>
#include <iostream>

#include "rpc_call.h"
#include "rpc_server_callback.h"
#include "rpc_threaded_server.h"
#include "rpc_types.h"
#include "CLI11.hpp"

// HW parameters
#define NIC_ADDR 0x20000

// Ctl-C handler
static volatile int keepRunning = 1;
void intHandler(int dummy) {
    keepRunning = 0;
}

// RPC functions
static RpcRetCode loopback(CallHandler handler, LoopBackArgs args, NumericalResult* ret);

static RpcRetCode add(CallHandler handler, AddArgs args, NumericalResult* ret);

static RpcRetCode sign(CallHandler handler, SigningArgs args, Signature* ret);

static RpcRetCode xor_(CallHandler handler, XorArgs args, NumericalResult* ret);

static RpcRetCode getUserData(CallHandler handler, UserName args, UserData* ret);

// <max number of threads, run duration>
int main(int argc, char* argv[]) {
    // Parse input
    CLI::App app{"Benchmark Server"};

    size_t num_of_threads;
    app.add_option("-t, --threads", num_of_threads, "number of threads")->required();
    int load_balancer;
    app.add_option("-l, --load-balancer", load_balancer, "load balancer")->required();

    CLI11_PARSE(app, argc, argv);

    // Server
    frpc::RpcThreadedServer server(NIC_ADDR, num_of_threads);

    // Init
    int res = server.init_nic();
    if (res != 0)
        return res;

    // Start server
    res = server.start_nic();
    if (res != 0)
        return res;

    // Enable perf
    res = server.run_perf_thread({true, true, true, true}, nullptr);
    if (res != 0)
        return res;

    // Open connections
    for (int i=0; i<num_of_threads; ++i) {
        frpc::IPv4 client_addr("192.168.0.1", 3136);
        if (server.connect(client_addr, i, i) != 0) {
            std::cout << "Failed to open connection on server" << std::endl;
            exit(1);
        } else {
            std::cout << "Connection is open on server" << std::endl;
        }
    }

    // Select
    server.set_lb(load_balancer);

    // Register RPC functions
    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(&loopback));
    fn_ptr.push_back(reinterpret_cast<const void*>(&add));
    fn_ptr.push_back(reinterpret_cast<const void*>(&sign));
    fn_ptr.push_back(reinterpret_cast<const void*>(&xor_));
    fn_ptr.push_back(reinterpret_cast<const void*>(&getUserData));

    frpc::RpcServerCallBack server_callback(fn_ptr);

    for (int i=0; i<num_of_threads; ++i) {
        res = server.run_new_listening_thread(&server_callback);
        if (res != 0)
            return res;
    }

    std::cout << "------- Server is running... -------" << std::endl;

    std::cout << "Press Ctrl+C to stop..." << std::endl;
    signal(SIGINT, intHandler);

    while (keepRunning) {
        sleep(1);
    }

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

static RpcRetCode loopback(CallHandler handler, LoopBackArgs args, NumericalResult* ret) {
#ifdef VERBOSE_RPCS
    std::cout << "loopback is called on thread " << handler.thread_id << " with "
                                                 << args.data << std::endl;
#endif
    ret->ret_val = args.timestamp;
    return RpcRetCode::Success;
}

static RpcRetCode add(CallHandler handler, AddArgs args, NumericalResult* ret) {
#ifdef VERBOSE_RPCS
    std::cout << "add is called on thread " << handler.thread_id << " with "
                                            << args.a << ", " << args.b << std::endl;
#endif
    ret->ret_val = args.timestamp;
    return RpcRetCode::Success;
}

static RpcRetCode sign(CallHandler handler, SigningArgs args, Signature* ret) {
#ifdef VERBOSE_RPCS
    std::cout << "sign is called on thread " << handler.thread_id << " with "
              << args.hash_lsb << ", " << args.hash_msb << ": <"
              << args.key_0 << " " << args.key_1 << " " << args.key_2 << " "
              << args.key_3 << ">" << std::endl;
#endif
    ret->result = args.timestamp;
    return RpcRetCode::Success;
}

static RpcRetCode xor_(CallHandler handler, XorArgs args, NumericalResult* ret) {
#ifdef VERBOSE_RPCS
    std::cout << "xor_ is called on thread " << handler.thread_id << " with "
              << args.a << " " << args.b << " "
              << args.c << " " << args.d << " " << args.e << " "
              << args.f << std::endl;
#endif
    ret->ret_val = args.timestamp;
    return RpcRetCode::Success;
}

static RpcRetCode getUserData(CallHandler handler, UserName args, UserData* ret) {
#ifdef VERBOSE_RPCS
    std::cout << "getUserData is called on thread " << handler.thread_id << " with "
              << args.first_name << " " << args.given_name << " " << std::endl;
#endif

    ret->timestamp = args.timestamp;
    sprintf(ret->data, "some data");

    return RpcRetCode::Success;
}
