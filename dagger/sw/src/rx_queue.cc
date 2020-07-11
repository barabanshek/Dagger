#include "rx_queue.h"

#include <assert.h>

namespace frpc {

RxQueue::RxQueue():
    rx_flow_buff_(nullptr),
    bucket_size_(0),
    depth_(0),
    l_depth_(0),
    //tx_q_head_(0),
    rx_q_tail_(0) {
}

RxQueue::RxQueue(volatile char* rx_flow_buff, size_t bucket_size_bytes, size_t l_depth):
    rx_flow_buff_(rx_flow_buff),
    bucket_size_(bucket_size_bytes),
    l_depth_(l_depth),
    //tx_q_head_(0),
    rx_q_tail_(0) {
    // Allocate tx and completion queues
    rx_q_ = rx_flow_buff_;

    depth_ = 1 << l_depth_;

    rpc_id_set_ = reinterpret_cast<uint32_t*>(aligned_alloc(4096, depth_*sizeof(uint8_t)));
    for (size_t i=0; i<depth_; ++i) {
        rpc_id_set_[i] = -1;
    }
}

RxQueue::~RxQueue() {

}

}  // namespace frpc
