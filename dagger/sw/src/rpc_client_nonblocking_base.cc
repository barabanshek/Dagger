#include "rpc_client_nonblocking_base.h"

#include <immintrin.h>

#include <cassert>

#include "config.h"
#include "logger.h"
#include "utils.h"

#include <iostream>

namespace frpc {

RpcClientNonBlock_Base::RpcClientNonBlock_Base(const Nic* nic, size_t nic_flow_id, uint16_t client_id):
        client_id_(client_id),
        nic_(nic),
        nic_flow_id_(nic_flow_id),
        cq_(nullptr),
        rpc_id_cnt_(0) {
#ifdef NIC_CCIP_MMIO
    if (cfg::nic::l_tx_queue_size != 0) {
        FRPC_ERROR("In MMIO mode, only one entry in the tx queue is allowed\n");
        assert(false);
    }
#endif

    // Allocate tx-queue
    tx_queue_ = TxQueue(nic_->get_tx_flow_buffer(nic_flow_id_),
                        nic_->get_mtu_size_bytes(),
                        cfg::nic::l_tx_queue_size);
    tx_queue_.init();

    // Allocate completion queue
    cq_ = std::unique_ptr<CompletionQueue>(
                        new CompletionQueue(nic_flow_id,
                                            nic_->get_rx_flow_buffer(nic_flow_id_),
                                            nic_->get_mtu_size_bytes()));
    cq_->bind();

#ifdef NIC_CCIP_DMA
    current_batch_ptr = 0;
    batch_counter = 0;
#endif
}

RpcClientNonBlock_Base::~RpcClientNonBlock_Base() {
    cq_->unbind();
}

CompletionQueue* RpcClientNonBlock_Base::get_completion_queue() const {
    return cq_.get();
}

#ifdef PROFILE_LATENCY
void RpcClientNonBlock_Base::init_latency_profile(uint64_t* timestamp_send,
                                             uint64_t* timestamp_recv) {
    lat_prof_timestamp = timestamp_send;
    cq_->init_latency_profile(timestamp_recv);
}
#endif


}  // namespace frpc
