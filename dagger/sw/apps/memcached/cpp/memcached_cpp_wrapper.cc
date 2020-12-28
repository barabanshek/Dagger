#include "memcached_cpp_wrapper.h"

#include "rpc_server_callback.h"
#include "rpc_threaded_server.h"

#include <memory>
#include <iostream>
#include <vector>

static frpc::RpcThreadedServer server(0x00000, 8);

static std::vector<const void*> fn_ptr;
static std::unique_ptr<frpc::RpcServerCallBack> server_callback;

int memcached_wrapper_init_and_start_server() {
    // init
    int res = server.init_nic();
    if (res != 0)
        return res;
    // start
    res = server.start_nic(true);
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

int memcached_wrapper_register_new_listening_thread(int (*set)(struct SetRequest, SetResponse*),
                                                    int (*get)(struct GetRequest, GetResponse*)) {
    fn_ptr.push_back(reinterpret_cast<const void*>(set));
    fn_ptr.push_back(reinterpret_cast<const void*>(get));
    server_callback = std::unique_ptr<frpc::RpcServerCallBack>(
                                                new frpc::RpcServerCallBack(fn_ptr));

    int res = server.run_new_listening_thread(server_callback.get());
    if (res != 0) {
        std::cout << "Failed to run a new listening thread" << std::endl;
        return res;
    } else {
        std::cout << "New listening thread is running" << std::endl;
        return 0;
    }
}
