#include "tx_queue.h"

namespace frpc {

TxQueue::TxQueue():
    tx_flow_buff_(nullptr),
    bucket_size_(0),
    l_depth_(0),
    depth_(0),
    tx_q_head_(0),
    tx_q_tail_(0) {
}

TxQueue::TxQueue(char* tx_flow_buff, size_t bucket_size_bytes, size_t l_depth):
    tx_flow_buff_(tx_flow_buff),
    bucket_size_(bucket_size_bytes),
    l_depth_(l_depth),
    tx_q_head_(0),
    tx_q_tail_(0) {
    // Allocate tx and completion queues
    tx_q_ = tx_flow_buff_;
    cq_ = tx_flow_buff_ + bucket_size_*l_depth_;

    depth_ = 1 << l_depth_;

    change_bit_set_ = reinterpret_cast<uint8_t*>(aligned_alloc(4096, depth_*sizeof(uint8_t)));
   // free_bit_ = reinterpret_cast<uint8_t*>(aligned_alloc(4096, depth_*sizeof(uint8_t)));
    for (size_t i=0; i<depth_; ++i) {
        change_bit_set_[i] = 1;
        //free_bit_[i] = 1;
    }
}

TxQueue::~TxQueue() {

}

}  // namespace frpc
