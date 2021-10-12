#include "tx_queue.h"

#include <unistd.h>

namespace dagger {

TxQueue::TxQueue()
    : tx_flow_buff_(nullptr),
      bucket_size_(0),
      l_depth_(0),
      depth_(0),
      tx_q_(nullptr),
      tx_q_head_(0),
      tx_q_tail_(0),
      change_bit_set_(nullptr),
      cq_(nullptr) {}

TxQueue::TxQueue(volatile char* tx_flow_buff, size_t bucket_size_bytes, size_t l_depth)
    : tx_flow_buff_(tx_flow_buff),
      bucket_size_(bucket_size_bytes),
      l_depth_(l_depth),
      tx_q_head_(0),
      tx_q_tail_(0),
      change_bit_set_(nullptr),
      cq_(nullptr) {
  // Allocate tx and completion queues.
  tx_q_ = tx_flow_buff_;
  cq_ = tx_flow_buff_ + bucket_size_ * l_depth_;

  depth_ = 1 << l_depth_;
}

TxQueue::~TxQueue() {
  if (change_bit_set_ != nullptr) {
    delete[] change_bit_set_;
  }
}

void TxQueue::init() {
  int page_size = getpagesize();
  assert(page_size == 4096);

  change_bit_set_ =
      reinterpret_cast<uint8_t*>(aligned_alloc(4096, depth_ * sizeof(uint8_t)));
  // free_bit_ = reinterpret_cast<uint8_t*>(aligned_alloc(4096,
  // depth_*sizeof(uint8_t)));
  for (size_t i = 0; i < depth_; ++i) {
    change_bit_set_[i] = 1;
    // free_bit_[i] = 1;
  }
}

}  // namespace dagger
