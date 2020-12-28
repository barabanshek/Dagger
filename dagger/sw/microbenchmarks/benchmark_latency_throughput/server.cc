#include <unistd.h>

#include <cstdlib>
#include <iostream>

#include "rpc_call.h"
#include "rpc_server_callback.h"
#include "rpc_threaded_server.h"
#include "rpc_types.h"

// HW parameters
#define NIC_ADDR 0x00000

// RPC functions
static frpc::RpcRetCode loopback(LoopBackArgs args, NumericalResult* ret);

static frpc::RpcRetCode add(AddArgs args, NumericalResult* ret);

static frpc::RpcRetCode sign(SigningArgs args, Signature* ret);

static frpc::RpcRetCode xor_(XorArgs args, NumericalResult* ret);

static frpc::RpcRetCode getUserData(UserName args, UserData* ret);

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
    fn_ptr.push_back(reinterpret_cast<const void*>(&getUserData));

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

static frpc::RpcRetCode loopback(LoopBackArgs args, NumericalResult* ret) {
#ifdef VERBOSE_RPCS
    std::cout << "loopback is called with " << args.data << std::endl;
#endif
    ret->ret_val = args.timestamp;
    return frpc::RpcRetCode::Success;
}

static frpc::RpcRetCode add(AddArgs args, NumericalResult* ret) {
#ifdef VERBOSE_RPCS
    std::cout << "add is called with " << args.a << ", " << args.b << std::endl;
#endif
    ret->ret_val = args.timestamp;
    return frpc::RpcRetCode::Success;
}

static frpc::RpcRetCode sign(SigningArgs args, Signature* ret) {
#ifdef VERBOSE_RPCS
    std::cout << "sign is called with " << args.hash_lsb << ", " << args.hash_msb << ": <"
              << args.key_0 << " " << args.key_1 << " " << args.key_2 << " "
              << args.key_3 << ">" << std::endl;
#endif
    ret->result = args.timestamp;
    return frpc::RpcRetCode::Success;
}

static frpc::RpcRetCode xor_(XorArgs args, NumericalResult* ret) {
#ifdef VERBOSE_RPCS
    std::cout << "xor_ is called with " << args.a << " " << args.b << " "
              << args.c << " " << args.d << " " << args.e << " "
              << args.f << std::endl;
#endif
    ret->ret_val = args.timestamp;
    return frpc::RpcRetCode::Success;
}

static frpc::RpcRetCode getUserData(UserName args, UserData* ret) {
#ifdef VERBOSE_RPCS
    std::cout << "getUserData is called with " << args.first_name << " "
              << args.given_name << " " << std::endl;
#endif

    ret->timestamp = args.timestamp;
    sprintf(ret->data, "some data");

    return frpc::RpcRetCode::Success;
}
