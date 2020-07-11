#include "rpc_client_nonblocking.h"

#include <immintrin.h>

#include <cassert>
#include <iostream>

#include "config.h"
#include "logger.h"
#include "utils.h"

namespace frpc {

RpcClientNonBlock::RpcClientNonBlock(const Nic* nic, size_t nic_flow_id, uint16_t client_id):
        client_id_(client_id),
        nic_(nic),
        nic_flow_id_(nic_flow_id),
        tx_queue_(nullptr),
        cq_(nullptr),
        rpc_id_cnt_(0) {
    // Allocate tx-queue
    tx_queue_ = std::unique_ptr<TxQueue>(
                        new TxQueue(nic_->get_tx_flow_buffer(nic_flow_id_),
                                    nic_->get_mtu_size_bytes(),
                                    cfg::nic::l_tx_queue_size));    // TODO: either pointer of value, should be same as server

    // Allocate completion queue
    cq_ = std::unique_ptr<CompletionQueue>(
                        new CompletionQueue(nic_flow_id,
                                            nic_->get_rx_flow_buffer(nic_flow_id_),
                                            nic_->get_mtu_size_bytes()));
    cq_->bind();
}

RpcClientNonBlock::~RpcClientNonBlock() {
    cq_->unbind();
}

CompletionQueue* RpcClientNonBlock::get_completion_queue() const {
    return cq_.get();
}

#ifdef PROFILE_LATENCY
void RpcClientNonBlock::init_latency_profile(uint64_t* timestamp_send,
                                             uint64_t* timestamp_recv) {
    lat_prof_timestamp = timestamp_send;
    cq_->init_latency_profile(timestamp_recv);
}
#endif

int RpcClientNonBlock::foo(uint32_t a, uint32_t b) {
    // Get current buffer pointer
    uint8_t change_bit;
    char* tx_ptr = tx_queue_->get_write_ptr(change_bit);
    if (tx_ptr >= nic_->get_tx_buff_end()) {
        FRPC_ERROR("Nic tx buffer overflow \n");
        assert(false);
    }
    assert(reinterpret_cast<size_t>(tx_ptr) % nic_->get_mtu_size_bytes() == 0);

    // Make RPC id
    uint32_t rpc_id = client_id_ | static_cast<uint32_t>(rpc_id_cnt_ << 16);

    // Send request
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.rpc_id          = rpc_id;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.num_of_args     = 2;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.fn_id           = 0;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.direction   = DirReq;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.update_flag = change_bit;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->arg1                = a;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->arg2                = b;
    _mm_mfence();
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.valid = 1;

#ifdef PROFILE_LATENCY
    // Add to latency hash table
    uint64_t hash = a + b;
    lat_prof_timestamp[hash] = frpc::utils::rdtsc();
#endif

    ++rpc_id_cnt_;

    return 0;
}

int RpcClientNonBlock::boo(uint32_t a) {
    // Get current buffer pointer
    uint8_t change_bit;
    char* tx_ptr = tx_queue_->get_write_ptr(change_bit);
    if (tx_ptr >= nic_->get_tx_buff_end()) {
        FRPC_ERROR("Nic tx buffer overflow \n");
        assert(false);
    }
    assert(reinterpret_cast<size_t>(tx_ptr) % nic_->get_mtu_size_bytes() == 0);

    // Make RPC id
    uint32_t rpc_id = client_id_ | static_cast<uint32_t>(rpc_id_cnt_ << 16);

    // Send request
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.rpc_id          = rpc_id;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.num_of_args     = 1;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.fn_id           = 0;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.direction   = DirReq;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.update_flag = change_bit;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->arg1                = a;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->arg2                = ARG_NOT_DEFINED;
    _mm_mfence();
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.valid = 1;

#ifdef PROFILE_LATENCY
    // Add to latency hash table
    uint64_t hash = a;
    lat_prof_timestamp[hash] = frpc::utils::rdtsc();
#endif

    ++rpc_id_cnt_;

    return 0;
}

}  // namespace frpc
