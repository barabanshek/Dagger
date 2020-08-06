#include "completion_queue.h"

#include "config.h"
#include "logger.h"
#include "utils.h"

#include "unistd.h"

namespace frpc {

CompletionQueue::CompletionQueue():
    rpc_client_id_(0),
    stop_signal_(0) {
}

CompletionQueue::CompletionQueue(size_t rpc_client_id, volatile char* rx_buff, size_t mtu_size_bytes):
    rpc_client_id_(rpc_client_id),
    stop_signal_(0) {
    // Allocate RX queue
    rx_queue_ = RxQueue(rx_buff, mtu_size_bytes, cfg::nic::l_rx_queue_size);
    rx_queue_.init();
}

CompletionQueue::~CompletionQueue() {
}

void CompletionQueue::bind() {
    stop_signal_ = 0;
    thread_ = std::thread(&CompletionQueue::_PullListen, this);
}

void CompletionQueue::unbind() {
    stop_signal_ = 1;
    thread_.join();
    FRPC_INFO("Completion queue is unbound from RPC client %d\n", rpc_client_id_);
}

#ifdef PROFILE_LATENCY
void CompletionQueue::init_latency_profile(uint64_t* timestamp_recv) {
    lat_prof_timestamp = timestamp_recv;
}
#endif

void CompletionQueue::_PullListen() {
    FRPC_INFO("Completion queue is bound to RPC client %d\n", rpc_client_id_);

    RpcRespPckt* resp_pckt;

    while (stop_signal_ == 0) {
        // wait response
        uint32_t rx_rpc_id;
        resp_pckt = reinterpret_cast<RpcRespPckt*>(rx_queue_.get_read_ptr(rx_rpc_id));

        while((resp_pckt->hdr.ctl.valid == 0 ||
               resp_pckt->hdr.rpc_id == rx_rpc_id) &&
              !stop_signal_);

        if (stop_signal_) continue;

#ifdef PROFILE_LATENCY
        // Mark recv time
        uint64_t hash = resp_pckt->ret_val;
        lat_prof_timestamp[hash] = frpc::utils::rdtsc();
#endif

        rx_queue_.update_rpc_id(resp_pckt->hdr.rpc_id);

        // Append to queue
        // TODO: there is a potential optimization here:
        //       the NIC hardware can directly write to this queue without
        //       the needs to explicitly copy data
        cq_lock_.lock();
        cq_.push_back(*const_cast<RpcRespPckt*>(resp_pckt));
        cq_lock_.unlock();
    }
}

size_t CompletionQueue::get_number_of_completed_requests() const {
    return cq_.size();
}

RpcRespPckt CompletionQueue::pop_response() {
    auto res = cq_.back();

    cq_lock_.lock();
    cq_.pop_back();
    cq_lock_.unlock();

    return res;
}

}  // namespace frpc
