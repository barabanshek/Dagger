/**
 * @file rx_queue.h
 * @brief Implementation of the receive queue.
 * @author Nikita Lazarev
 */
#ifndef _RX_QUEUE_H_
#define _RX_QUEUE_H_

#include <stddef.h>
#include <stdint.h>

#include <bitset>
#include <cassert>

namespace dagger {

/// RX queue implementation. The queue provides the critical path interface with
/// the hardware for incoming RPC requests.
class alignas(4096) RxQueue {
 public:
  /// Default instantiation.
  RxQueue();

  /// Instantiate the queue based on the @param rx_flow_buff shared memory
  /// buffer.
  RxQueue(volatile char* rx_flow_buff, size_t bucket_size_bytes,
          size_t l_depth);

  /// Forbid copying and assignment of the queue as the abstraction here is that
  /// only a single queue might exist per hardware flow.
  RxQueue(const RxQueue&) = delete;

  virtual ~RxQueue();

  /// Initialize the queue.
  void init();

  /// Critical path function to get the tail location in the queue for the
  /// upcoming read access.
  inline volatile char* get_read_ptr(uint32_t& rpc_id)
      __attribute__((always_inline)) {
    assert(rpc_id_set_ != nullptr);
    assert(rx_q_ != nullptr);

    volatile char* ptr = rx_q_ + rx_q_tail_ * bucket_size_;
    rpc_id = rpc_id_set_[rx_q_tail_];
    return ptr;
  }

  /// Critical path function to update the rpc_id (for polling) and increment
  /// the tail pointer.
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
  // Underlying nic buffer.
  volatile char* rx_flow_buff_;

  // Queue sizes.
  size_t bucket_size_;
  size_t depth_;
  size_t l_depth_;

  // Rx queue.
  volatile char* rx_q_;
  size_t rx_q_tail_;
  uint32_t* rpc_id_set_;
};

}  // namespace dagger

#endif
