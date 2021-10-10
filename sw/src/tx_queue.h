#ifndef _TX_QUEUE_H_
#define _TX_QUEUE_H_

#include <stddef.h>
#include <stdint.h>

#include <bitset>
#include <cassert>

namespace frpc {

/// Tx queue implementation
///
class alignas(4096) TxQueue {
public:
    TxQueue();
    TxQueue(char* tx_flow_buff, size_t bucket_size_bytes, size_t l_depth);
    TxQueue(const TxQueue&) = delete;

    virtual ~TxQueue();

    void init();

    inline char* get_write_ptr(uint8_t& change_bit) __attribute__((always_inline)) {
        assert(tx_q_ != nullptr);
        assert(change_bit_set_ != nullptr);

        change_bit = change_bit_set_[tx_q_head_];

        char* ptr = tx_q_ + tx_q_head_*bucket_size_;

        // Incremet head and flip change bit
        change_bit_set_[tx_q_head_] ^= 1;
        //do {
        tx_q_head_ += 1;
        if (tx_q_head_ == depth_) {
            tx_q_head_ = 0;
        }
        //} while (free_bit_[tx_q_head_] != 1);

        return ptr;
    }

private:
    // Underlying Nic buffer
    char* tx_flow_buff_;

    // Queue sizes
    size_t bucket_size_;
    size_t l_depth_;
    size_t depth_;

    // Tx queue
    char* tx_q_;
    size_t tx_q_head_;
    size_t tx_q_tail_;
    // To allow hw to track updates
    //   - used only with polling hw
    uint8_t* change_bit_set_;
    //uint8_t* free_bit_;

    // Completion queue
    char* cq_;
};

}  // namespace frpc

#endif
