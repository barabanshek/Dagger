#include "rpc_threaded_server_wrapper.h"

#include "rpc_threaded_server.h"

#include <vector>

#include <iostream>

static frpc::RpcThreadedServer server(0x00000, 1);

int rpc_server_thread_wrapper_init_and_start_server() {
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

int rpc_server_thread_wrapper_register_new_listening_thread(int (*foo)(int, int)) {
    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(foo));
    int res = server.run_new_listening_thread(fn_ptr);
    if (res != 0)
        return res;

    return 0;
}
