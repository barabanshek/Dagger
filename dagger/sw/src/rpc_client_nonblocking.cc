#include "rpc_client_nonblocking.h"

#include <immintrin.h>

#include <cassert>

#include "config.h"
#include "logger.h"
#include "utils.h"

namespace frpc {

RpcClientNonBlock::RpcClientNonBlock(const Nic* nic, size_t nic_flow_id, uint16_t client_id):
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
    char* tx_ptr = tx_queue_.get_write_ptr(change_bit);
    if (tx_ptr >= nic_->get_tx_buff_end()) {
        FRPC_ERROR("Nic tx buffer overflow \n");
        assert(false);
    }
    assert(reinterpret_cast<size_t>(tx_ptr) % nic_->get_mtu_size_bytes() == 0);

    // Make RPC id
    uint32_t rpc_id = client_id_ | static_cast<uint32_t>(rpc_id_cnt_ << 16);

    // Send request
#ifdef NIC_CCIP_POLLING
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.rpc_id          = rpc_id;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.num_of_args     = 2;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.fn_id           = 0;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.direction   = DirReq;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.update_flag = change_bit;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->arg1                = a;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->arg2                = b;
    _mm_mfence();
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.valid = 1;
#elif NIC_CCIP_MMIO
    RpcReqPckt request __attribute__ ((aligned (64)));

    request.hdr.rpc_id          = rpc_id;
    request.hdr.num_of_args     = 2;
    request.hdr.fn_id           = 0;
    request.hdr.ctl.direction   = DirReq;
    request.hdr.ctl.valid       = 1;
    request.arg1                = a;
    request.arg2                = b;

    // MMIO only supports AVX writes
    _mm256_store_si256(reinterpret_cast<__m256i*>(tx_ptr),
                       *(reinterpret_cast<__m256i*>(&request)));
    _mm256_store_si256(reinterpret_cast<__m256i*>(tx_ptr + 32),
                       *(reinterpret_cast<__m256i*>(&request)));
    _mm_mfence();
#elif NIC_CCIP_DMA
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.rpc_id          = rpc_id;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.num_of_args     = 2;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.fn_id           = 0;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.direction   = DirReq;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.update_flag = change_bit;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->arg1                = a;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->arg2                = b;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.valid       = 1;
    _mm_mfence();

    if (batch_counter == cfg::nic::tx_batch_size - 1) {
        nic_->notify_nic_of_new_dma(nic_flow_id_, current_batch_ptr);

        current_batch_ptr += cfg::nic::tx_batch_size;
        if (current_batch_ptr == ((1 << cfg::nic::l_tx_queue_size) / cfg::nic::tx_batch_size)*cfg::nic::tx_batch_size) {
            current_batch_ptr = 0;
        }

        batch_counter = 0;
    } else {
        ++batch_counter;
    }
#else
    #error NIC CCI-P mode is not defined
#endif

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
    char* tx_ptr = tx_queue_.get_write_ptr(change_bit);
    if (tx_ptr >= nic_->get_tx_buff_end()) {
        FRPC_ERROR("Nic tx buffer overflow \n");
        assert(false);
    }
    assert(reinterpret_cast<size_t>(tx_ptr) % nic_->get_mtu_size_bytes() == 0);

    // Make RPC id
    uint32_t rpc_id = client_id_ | static_cast<uint32_t>(rpc_id_cnt_ << 16);

    // Send request
#ifdef NIC_CCIP_POLLING
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.rpc_id          = rpc_id;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.num_of_args     = 1;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.fn_id           = 1;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.direction   = DirReq;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.update_flag = change_bit;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->arg1                = a;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->arg2                = ARG_NOT_DEFINED;
    _mm_mfence();
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.valid = 1;
#elif NIC_CCIP_MMIO
    RpcReqPckt request __attribute__ ((aligned (64)));

    request.hdr.rpc_id          = rpc_id;
    request.hdr.num_of_args     = 1;
    request.hdr.fn_id           = 1;
    request.hdr.ctl.direction   = DirReq;
    request.hdr.ctl.valid       = 1;
    request.arg1                = a;
    request.arg2                = ARG_NOT_DEFINED;

    // MMIO only supports AVX writes
    _mm256_store_si256(reinterpret_cast<__m256i*>(tx_ptr),
                       *(reinterpret_cast<__m256i*>(&request)));
    _mm256_store_si256(reinterpret_cast<__m256i*>(tx_ptr + 32),
                       *(reinterpret_cast<__m256i*>(&request)));
    _mm_mfence();
#elif NIC_CCIP_DMA
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.rpc_id          = rpc_id;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.num_of_args     = 1;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.fn_id           = 1;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.direction   = DirReq;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.update_flag = change_bit;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->arg1                = a;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->arg2                = ARG_NOT_DEFINED;
    (reinterpret_cast<RpcReqPckt*>(tx_ptr))->hdr.ctl.valid       = 1;
    _mm_mfence();

    if (batch_counter == cfg::nic::tx_batch_size - 1) {
        nic_->notify_nic_of_new_dma(nic_flow_id_, current_batch_ptr);

        current_batch_ptr += cfg::nic::tx_batch_size;
        if (current_batch_ptr == (1 << cfg::nic::l_tx_queue_size)) {
            current_batch_ptr = 0;
        }

        batch_counter = 0;
    } else {
        ++batch_counter;
    }
#else
    #error NIC CCI-P mode is not defined
#endif

#ifdef PROFILE_LATENCY
    // Add to latency hash table
    uint64_t hash = a;
    lat_prof_timestamp[hash] = frpc::utils::rdtsc();
#endif

    ++rpc_id_cnt_;

    return 0;
}

}  // namespace frpc
