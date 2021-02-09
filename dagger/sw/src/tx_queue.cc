#include "tx_queue.h"

#include <unistd.h>

namespace frpc {

TxQueue::TxQueue():
    tx_flow_buff_(nullptr),
    bucket_size_(0),
    l_depth_(0),
    depth_(0),
    tx_q_(nullptr),
    tx_q_head_(0),
    tx_q_tail_(0),
    change_bit_set_(nullptr),
    cq_(nullptr) {

}

TxQueue::TxQueue(char* tx_flow_buff, size_t bucket_size_bytes, size_t l_depth, bool thread_safe):
    tx_flow_buff_(tx_flow_buff),
    bucket_size_(bucket_size_bytes),
    l_depth_(l_depth),
    tx_q_head_(0),
    tx_q_tail_(0),
    change_bit_set_(nullptr),
    cq_(nullptr),
    thread_safe_(thread_safe) {
    // Allocate tx and completion queues
    tx_q_ = tx_flow_buff_;
    cq_ = tx_flow_buff_ + bucket_size_*l_depth_;

    depth_ = 1 << l_depth_;
}

TxQueue& TxQueue::operator=(const TxQueue& tx_queue) {
    tx_flow_buff_ = tx_queue.tx_flow_buff_;
    bucket_size_ = tx_queue.bucket_size_;
    l_depth_ = tx_queue.l_depth_;
    depth_ = tx_queue.depth_;
    tx_q_ = tx_queue.tx_q_;
    tx_q_head_ = tx_queue.tx_q_head_;
    tx_q_tail_ = tx_queue.tx_q_tail_;
    change_bit_set_ = tx_queue.change_bit_set_;
    cq_ = tx_queue.cq_;
    thread_safe_ =tx_queue.thread_safe_;

    return *this;
}

TxQueue::~TxQueue() {
    if (change_bit_set_ != nullptr) {
        delete[] change_bit_set_;
    }
}

void TxQueue::init() {
    int page_size = getpagesize();
    assert(page_size == 4096);

    change_bit_set_ = reinterpret_cast<uint8_t*>(aligned_alloc(4096, depth_*sizeof(uint8_t)));
    // free_bit_ = reinterpret_cast<uint8_t*>(aligned_alloc(4096, depth_*sizeof(uint8_t)));
    for (size_t i=0; i<depth_; ++i) {
        change_bit_set_[i] = 1;
        //free_bit_[i] = 1;
    }
}

}  // namespace frpc
