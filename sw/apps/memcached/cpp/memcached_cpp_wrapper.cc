#include "memcached_cpp_wrapper.h"

#include "rpc_server_callback.h"
#include "rpc_threaded_server.h"

#include <memory>
#include <iomanip>
#include <iostream>
#include <vector>

static frpc::RpcThreadedServer server(0x00000, 4);

static std::vector<const void*> fn_ptr;
static std::unique_ptr<frpc::RpcServerCallBack> server_callback;

void perf_callback(const std::vector<uint64_t>& counters) {
    uint64_t rps_in = counters[1];
    uint64_t rps_out = counters[0];
    if (rps_in > 0) {
        std::cout << std::fixed << std::setprecision(2) << "Dropped requests: "
                  << 100*(rps_in - rps_out)/(double)rps_in << "%" << std::endl;
    }
}

int memcached_wrapper_init_and_start_server() {
    // init
    int res = server.init_nic();
    if (res != 0)
        return res;

    // start
    res = server.start_nic();
    if (res != 0)
        return res;

    // set and enable perf
    res = server.run_perf_thread({true, true, true}, &perf_callback);
    if (res != 0)
        return res;

    return 0;
}

int memcached_wrapper_open_connection(const char* client_ip,
                                      uint16_t client_port,
                                      uint32_t c_id) {
    frpc::IPv4 client_addr(client_ip, client_port);
    if (server.connect(client_addr, c_id, c_id) != 0) {
        std::cout << "Failed to open connection on server" << std::endl;
        return 1;
    } else {
        std::cout << "Connection is open on server" << std::endl;
        return 0;
    }
}

int memcached_wrapper_register_functions(int (*set)(struct CallHandler,
                                                    struct SetRequest,
                                                    struct SetResponse*),
                                         int (*get)(struct CallHandler,
                                                    struct GetRequest,
                                                    struct GetResponse*),
                                         int (*populate)(struct CallHandler,
                                                         struct PopulateRequest,
                                                         struct PopulateResponse*)) {
    fn_ptr.push_back(reinterpret_cast<const void*>(set));
    fn_ptr.push_back(reinterpret_cast<const void*>(get));
    fn_ptr.push_back(reinterpret_cast<const void*>(populate));
    server_callback = std::unique_ptr<frpc::RpcServerCallBack>(
                                                new frpc::RpcServerCallBack(fn_ptr));

    return 0;
}

int memcached_wrapper_run_new_listening_thread(int pin_cpu) {
    int res = server.run_new_listening_thread(server_callback.get(), pin_cpu);
    if (res != 0) {
        std::cout << "Failed to run a new listening thread" << std::endl;
        return res;
    } else {
        std::cout << "New listening thread is running" << std::endl;
        return 0;
    }
}

int memcached_wrapper_set_lb(int lb) {
    server.set_lb(lb);
    return 0;
}
