#ifndef _RPC_SERVER_THREAD_H_
#define _RPC_SERVER_THREAD_H_

#include <atomic>
#include <thread>
#include <vector>

#include "nic.h"
#include "tx_queue.h"
#include "rx_queue.h"

namespace frpc {

class RpcServerThread {
public:
    RpcServerThread(const Nic* nic,
                    size_t nic_flow_id,
                    uint16_t thread_id,
                    const std::vector<const void*>& rpc_fn_ptr);
    ~RpcServerThread();

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

    // RPC function pointer
    std::vector<const void*> rpc_fn_ptr_;

    // Thread
    std::thread thread_;
    std::atomic<bool> stop_signal_;

};

}  // namespace frpc

#endif  // _RPC_SERVER_THREAD_H_
