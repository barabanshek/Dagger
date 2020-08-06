#ifndef _RX_QUEUE_H_
#define _RX_QUEUE_H_

#include <stddef.h>
#include <stdint.h>

#include <bitset>
#include <cassert>

namespace frpc {

/// Tx queue implementation
///
class RxQueue {
public:
    RxQueue();
    RxQueue(volatile char* rx_flow_buff, size_t bucket_size_bytes, size_t l_depth);
    RxQueue(const RxQueue&) = delete;

    virtual ~RxQueue();

    void init();

    inline char* get_read_ptr(uint32_t& rpc_id) __attribute__((always_inline)) {
        assert(rpc_id_set_ != nullptr);
        assert(rx_q_ != nullptr);

        char* ptr = const_cast<char*>(rx_q_ + rx_q_tail_*bucket_size_);
        rpc_id = rpc_id_set_[rx_q_tail_];
        return ptr;
    }

    inline void update_rpc_id(uint32_t rpc_id) __attribute__((always_inline)) {
        assert(rpc_id_set_ != nullptr);
        assert(rx_q_ != nullptr);

        rpc_id_set_[rx_q_tail_] = rpc_id;
        ++rx_q_tail_;
        if (rx_q_tail_ == depth_) {
            rx_q_tail_ = 0;
        }
    }

private:
    // Underlying Nic buffer
    volatile char* rx_flow_buff_;

    // Queue sizes
    size_t bucket_size_;
    size_t depth_;
    size_t l_depth_;

    // Rx queue
    volatile char* rx_q_;
    size_t rx_q_tail_;
    uint32_t* rpc_id_set_;

};

}  // namespace frpc

#endif
