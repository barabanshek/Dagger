#include "rx_queue.h"

#include <unistd.h>

namespace frpc {

RxQueue::RxQueue()
    : rx_flow_buff_(nullptr),
      bucket_size_(0),
      depth_(0),
      l_depth_(0),
      rx_q_(nullptr),
      rx_q_tail_(0),
      rpc_id_set_(nullptr) {}

RxQueue::RxQueue(volatile char* rx_flow_buff, size_t bucket_size_bytes,
                 size_t l_depth)
    : rx_flow_buff_(rx_flow_buff),
      bucket_size_(bucket_size_bytes),
      l_depth_(l_depth),
      rpc_id_set_(nullptr),
      rx_q_tail_(0) {
  rx_q_ = rx_flow_buff_;
  depth_ = 1 << l_depth_;
}

RxQueue::~RxQueue() {
  if (rpc_id_set_ != nullptr) {
    delete[] rpc_id_set_;
  }
}

void RxQueue::init() {
  int page_size = getpagesize();
  assert(page_size == 4096);

  rpc_id_set_ = reinterpret_cast<uint32_t*>(
      aligned_alloc(page_size, depth_ * sizeof(uint32_t)));
  for (size_t i = 0; i < depth_; ++i) {
    rpc_id_set_[i] = -1;
  }
}

}  // namespace frpc
