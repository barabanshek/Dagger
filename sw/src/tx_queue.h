/**
 * @file tx_queue.h
 * @brief Implementation of the transmission queue.
 * @author Nikita Lazarev
 */
#ifndef _TX_QUEUE_H_
#define _TX_QUEUE_H_

#include <stddef.h>
#include <stdint.h>

#include <bitset>
#include <cassert>

namespace dagger {

/// TX queue implementation. The queue provides the critical path interface with
/// the hardware for outgoing RPC requests.
class alignas(4096) TxQueue {
 public:
  /// Default instantiation.
  TxQueue();

  /// Instantiate the queue based on the @param tx_flow_buff shared memory
  /// buffer.
  TxQueue(volatile char* tx_flow_buff, size_t bucket_size_bytes, size_t l_depth);

  /// Forbid copying and assignment of the queue as the abstraction here is that
  /// only a single queue might exist per hardware flow.
  TxQueue(const TxQueue&) = delete;

  virtual ~TxQueue();

  /// Initialize the queue.
  void init();

  /// Critical path function to get the head location in the queue for the
  /// upcoming write access.
  inline volatile char* get_write_ptr(uint8_t& change_bit)
      __attribute__((always_inline)) {
    assert(tx_q_ != nullptr);
    assert(change_bit_set_ != nullptr);

    change_bit = change_bit_set_[tx_q_head_];

    volatile char* ptr = tx_q_ + tx_q_head_ * bucket_size_;

    // Incremet head and flip change bit.
    change_bit_set_[tx_q_head_] ^= 1;
    // do {
    tx_q_head_ += 1;
    if (tx_q_head_ == depth_) {
      tx_q_head_ = 0;
    }
    //} while (free_bit_[tx_q_head_] != 1);

    return ptr;
  }

 private:
  // Underlying nic buffer.
  volatile char* tx_flow_buff_;

  // Queue sizes.
  size_t bucket_size_;
  size_t l_depth_;
  size_t depth_;

  // Tx queue.
  volatile char* tx_q_;
  size_t tx_q_head_;
  size_t tx_q_tail_;
  // To allow hw to track updates
  //   - used only with polling hw
  uint8_t* change_bit_set_;
  // uint8_t* free_bit_;

  // Completion queue.
  volatile char* cq_;
};

}  // namespace dagger

#endif
