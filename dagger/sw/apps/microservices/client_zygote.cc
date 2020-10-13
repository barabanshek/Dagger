#include <stdio.h>

#include <iostream>

#include "rpc_client_nonblocking.h"
#include "rpc_client_pool.h"

#define NIC_ADDR 0x20000

// <number of clients>
int main(int argc, char* argv[]) {
    size_t num_of_clients = atoi(argv[1]);

    frpc::RpcClientPool<frpc::RpcClientNonBlock> rpc_client_pool(NIC_ADDR,
                                                         num_of_clients);

    // Init client pool
    int res = rpc_client_pool.init_nic();
    if (res != 0)
        return res;

    // Start NIC with perf enabled
    res = rpc_client_pool.start_nic(true);
    if (res != 0)
        return res;

    std::cout << "ZYGOTE > nic is initialized and running" << std::endl;

    for (int i=0; i<num_of_clients; ++i) {
        std::cout << "ZYGOTE > forking to client #" << i << std::endl;
    }

    return 0;
}
