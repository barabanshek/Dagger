#ifndef _COMPLETION_QUEUE_H
#define _COMPLETION_QUEUE_H

#include <atomic>
#include <mutex>
#include <thread>
#include <vector>
#include <utility>

#include "rpc_header.h"
#include "rx_queue.h"

namespace frpc {

/// Completion queue for non-blocking RPCs
/// Currently requires a separate management thread
///
class CompletionQueue {
public:
    CompletionQueue();
    CompletionQueue(size_t rpc_client_id, volatile char* rx_buff, size_t mtu_size_bytes);
    ~CompletionQueue();

    void bind();
    void unbind();

    void init_latency(uint64_t* latency);

    size_t get_number_of_completed_requests() const;

    RpcRespPckt pop_response();

    uint64_t rdtsc(){
        unsigned int lo, hi;
        __asm__ __volatile__ ("rdtsc" : "=a" (lo), "=d" (hi));
        return ((uint64_t)hi << 32) | lo;
    }

private:
    void _PullListen();

private:
    size_t rpc_client_id_;

    // Rx queue
    RxQueue rx_queue_;

    // Thread
    std::thread thread_;
    std::atomic<bool> stop_signal_;

    // CQ
    std::vector<RpcRespPckt> cq_;

    // Sync
    std::mutex cq_lock_;

    //latency hash table
    uint64_t* latency;

    volatile char* rx_buff_;

};

}  // namespace frpc

#endif
