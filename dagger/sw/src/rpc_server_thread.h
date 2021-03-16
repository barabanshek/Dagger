#ifndef _RPC_SERVER_THREAD_H_
#define _RPC_SERVER_THREAD_H_

#include <atomic>
#include <condition_variable>
#include <mutex>
#include <queue>
#include <thread>
#include <vector>
#include <utility>

#include "connection_manager.h"
#include "nic.h"
#include "rpc_header.h"
#include "rpc_call.h"
#include "rx_queue.h"
#include "tx_queue.h"

namespace frpc {

// Server callback interface
class RpcServerCallBack_Base {
public:
    RpcServerCallBack_Base(const std::vector<const void*>& rpc_fn_ptr):
        rpc_fn_ptr_(rpc_fn_ptr) {}
    virtual ~RpcServerCallBack_Base() {}

    virtual void operator()(const CallHandler handler,
                            const RpcPckt* rpc_in, TxQueue& tx_queue) const =0;

protected:
    const std::vector<const void*>& rpc_fn_ptr_;

};

class RpcServerThread {
public:
    // Run request processing in dispatch threads when worker_threads = 0,
    // run in worker threads otherwise; worker_threads specifies the size
    // of the worker thread pool
    RpcServerThread(const Nic* nic,
                    size_t nic_flow_id,
                    uint16_t thread_id,
                    const RpcServerCallBack_Base* callback,
                    size_t worker_threads = 0);
    virtual ~RpcServerThread();

    int register_connection(ConnectionId c_id, const IPv4& server_addr);
    int remove_connection(ConnectionId c_id);

    int start_listening(int pin_cpu);
    void stop_listening();

private:
    // Dispath thread
    void _PullListen();

    // Worker thread
    void _Worker(size_t worker_id);

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

    // Dispatch thread
    std::thread thread_;
    std::atomic<bool> stop_signal_;

    // Worker threads
    bool run_worker_threads_;
    size_t num_worker_threads_;
    size_t worker_job_queue_size_;
    std::vector<std::thread> worker_thread_pool_;
    std::mutex worker_thread_pool_lck_;
    std::condition_variable worker_thread_pool_cv_;
    std::queue<RpcPckt> worker_job_queue_;

    size_t max;

#ifdef NIC_CCIP_DMA
    uint32_t current_batch_ptr;
    size_t batch_counter;
#endif

};

}  // namespace frpc

#endif  // _RPC_SERVER_THREAD_H_
