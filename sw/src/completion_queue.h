/**
 * @file completion_queue.h
 * @brief Completion queue for non-blocking RPCs.
 * @author Nikita Lazarev
 */
#ifndef _COMPLETION_QUEUE_H
#define _COMPLETION_QUEUE_H

#include <atomic>
#include <mutex>
#include <thread>
#include <utility>
#include <vector>

#include "rpc_header.h"
#include "rx_queue.h"

namespace dagger {

/// Completion queue for non-blocking RPCs. Currently requires a separate
/// management thread.
class CompletionQueue {
 public:
  CompletionQueue();

  /// Construct a new completion queue based on the rx buffer @param rx_buff
  CompletionQueue(size_t rpc_client_id, volatile char* rx_buff,
                  size_t mtu_size_bytes);
  ~CompletionQueue();

  /// Bind/Unbind completion queue to the thread
  void bind();
  void unbind();

  size_t get_number_of_completed_requests() const;

  RpcPckt pop_response();

  void clear_queue();

#ifdef PROFILE_LATENCY
  const std::vector<uint32_t>& get_latency_records() const;
  void clear_latency_records();
#endif

 private:
  void _PullListen();

 private:
  size_t rpc_client_id_;

  RxQueue rx_queue_;

  // Thread
  std::thread thread_;
  std::atomic<bool> stop_signal_;

  // CQ
  std::vector<RpcPckt> cq_;

#ifdef PROFILE_LATENCY
  // Timestamps
  std::vector<uint32_t> timestamps_;
#endif

  // Sync
  std::mutex cq_lock_;
};

}  // namespace dagger

#endif
