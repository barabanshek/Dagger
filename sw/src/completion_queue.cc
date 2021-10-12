#include "completion_queue.h"

#include "config.h"
#include "logger.h"
#include "unistd.h"
#include "utils.h"

namespace dagger {

CompletionQueue::CompletionQueue() : rpc_client_id_(0), stop_signal_(0) {}

CompletionQueue::CompletionQueue(size_t rpc_client_id, volatile char* rx_buff,
                                 size_t mtu_size_bytes)
    : rpc_client_id_(rpc_client_id), stop_signal_(0) {
  // Allocate RX queue
  rx_queue_ = RxQueue(rx_buff, mtu_size_bytes, cfg::nic::l_rx_queue_size);
  rx_queue_.init();
}

CompletionQueue::~CompletionQueue() {}

void CompletionQueue::bind() {
  stop_signal_ = 0;
  thread_ = std::thread(&CompletionQueue::_PullListen, this);
}

void CompletionQueue::unbind() {
  stop_signal_ = 1;
  thread_.join();
  FRPC_INFO("Completion queue is unbound from RPC client %d\n", rpc_client_id_);
}

void CompletionQueue::_PullListen() {
  FRPC_INFO("Completion queue is bound to RPC client %d\n", rpc_client_id_);

  volatile RpcPckt* resp_pckt;

  while (stop_signal_ == 0) {
    // wait response
    uint32_t rx_rpc_id;
    resp_pckt =
        reinterpret_cast<volatile RpcPckt*>(rx_queue_.get_read_ptr(rx_rpc_id));

    while (
        (resp_pckt->hdr.ctl.valid == 0 || resp_pckt->hdr.rpc_id == rx_rpc_id) &&
        !stop_signal_)
      ;

    if (stop_signal_) continue;

    rx_queue_.update_rpc_id(resp_pckt->hdr.rpc_id);

    cq_lock_.lock();

#ifdef PROFILE_LATENCY
    // Record latency:
    // the RPC definition should contain a 64-bit integer as the first entry
    // e.g.
    // message Msg {
    //    int64 timestamp;
    // }
    // and it should be written with the current time stamp on the client when
    // issuing the request.
    uint32_t issuing_timestamp =
        *reinterpret_cast<volatile uint32_t*>(resp_pckt->argv);
    timestamps_.push_back(static_cast<uint32_t>(dagger::utils::rdtsc()) -
                          issuing_timestamp);
#endif

    // Append to queue
    // TODO: there is a potential optimization here:
    //       the NIC hardware can directly write to this queue without
    //       the needs to explicitly copy data
    cq_.push_back(*const_cast<RpcPckt*>(resp_pckt));

    cq_lock_.unlock();
  }
}

size_t CompletionQueue::get_number_of_completed_requests() const {
  return cq_.size();
}

RpcPckt CompletionQueue::pop_response() {
  auto res = cq_.back();

  cq_lock_.lock();
  cq_.pop_back();
  cq_lock_.unlock();

  return res;
}

void CompletionQueue::clear_queue() { cq_.clear(); }

#ifdef PROFILE_LATENCY
const std::vector<uint32_t>& CompletionQueue::get_latency_records() const {
  return timestamps_;
}

void CompletionQueue::clear_latency_records() { timestamps_.clear(); }
#endif

}  // namespace dagger
