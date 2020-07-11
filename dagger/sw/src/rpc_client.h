#ifndef _RPC_CLIENT_H_
#define _RPC_CLIENT_H_

#include "nic.h"

namespace frpc {

class RpcClient {
public:
    RpcClient(const Nic* nic, size_t nic_flow_id, uint16_t client_id);
    ~RpcClient();

    // RPC call
    // * blocking
    // * polling-based
    uint32_t foo(uint32_t a, uint32_t b);
    uint32_t boo(uint32_t a);

private:
    // client_id - a part of rpc_id
    uint16_t client_id_;

    // NIC
    const Nic* nic_;
    size_t nic_flow_id_;

    // NIC buffers
    char* tx_buff_;
    volatile char* rx_buff_;

    // rpc_id counter - not really needed for blocking calls
    uint16_t rpc_id_cnt_;

    // update_flag_ - only for polling hardware
    uint8_t update_flag_;
    uint32_t prev_rpc_id_;

    // Statistics
    uint64_t req_sent_;
    uint64_t req_recved_;

};

}  // namespace frpc

#endif
