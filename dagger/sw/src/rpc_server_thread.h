#ifndef _RPC_SERVER_THREAD_H_
#define _RPC_SERVER_THREAD_H_

#include <atomic>
#include <thread>
#include <vector>
#include <utility>

#include "connection_manager.h"
#include "nic.h"
#include "rpc_header.h"
#include "rx_queue.h"
#include "tx_queue.h"

namespace frpc {

// Server callback interface
class RpcServerCallBack_Base {
public:
    RpcServerCallBack_Base(const std::vector<const void*>& rpc_fn_ptr):
        rpc_fn_ptr_(rpc_fn_ptr) {}
    virtual ~RpcServerCallBack_Base() {}

    virtual void operator()(const RpcPckt* rpc_in, TxQueue& tx_queue) const =0;

protected:
    const std::vector<const void*>& rpc_fn_ptr_;

};

class RpcServerThread {
public:
    RpcServerThread(const Nic* nic,
                    size_t nic_flow_id,
                    uint16_t thread_id,
                    const RpcServerCallBack_Base* callback);
    virtual ~RpcServerThread();

    int register_connection(ConnectionId c_id, const IPv4& server_addr);
    int remove_connection(ConnectionId c_id);

    void start_listening();
    void stop_listening();

private:
    void _PullListen();

private:
    uint16_t thread_id_;

    // Nic
    const Nic* nic_;
    size_t nic_flow_id_;

    // Tx and RX queue
    TxQueue tx_queue_;
    RxQueue rx_queue_;

    // RPC callback object
    const RpcServerCallBack_Base* server_callback_;

    // Thread
    std::thread thread_;
    std::atomic<bool> stop_signal_;

#ifdef NIC_CCIP_DMA
    uint32_t current_batch_ptr;
    size_t batch_counter;
#endif

};

}  // namespace frpc

#endif  // _RPC_SERVER_THREAD_H_
