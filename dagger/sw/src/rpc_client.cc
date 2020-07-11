#include "rpc_client.h"

#include <iostream>

#include <assert.h>

#include "logger.h"
#include "rpc_header.h"

#include<unistd.h>

#include <immintrin.h>

namespace frpc {

RpcClient::RpcClient(const Nic* nic, size_t nic_flow_id, uint16_t client_id):
        client_id_(client_id),
        nic_(nic),
        nic_flow_id_(nic_flow_id),
        rpc_id_cnt_(1),
        update_flag_(0),
        prev_rpc_id_(0),
        req_sent_(0),
        req_recved_(0) {
    tx_buff_ = nic_->get_tx_flow_buffer(nic_flow_id_);
    rx_buff_ = nic_->get_rx_flow_buffer(nic_flow_id_);
    // start with 1 so to trig polling HW with the first request
    update_flag_ = 1;
}

RpcClient::~RpcClient() {

}

uint32_t RpcClient::foo(uint32_t a, uint32_t b) {
    // Create RPC
    RpcReqPckt req_pckt __attribute__ ((aligned (64)));
    req_pckt.hdr.rpc_id          = client_id_ | static_cast<uint32_t>(
                                                            rpc_id_cnt_ << 16);
    req_pckt.hdr.fn_id           = 0; // TODO: make this flexible
    req_pckt.hdr.num_of_args     = 2;
    req_pckt.hdr.ctl.direction   = DirReq;
    req_pckt.hdr.ctl.update_flag = update_flag_;
    req_pckt.arg1                = a;
    req_pckt.arg2                = b;

#ifdef AVX2_WRITE
    // Set valid bit now
    req_pckt.hdr.ctl.valid = 1;
#else
    // Set valid bit later
    req_pckt.hdr.ctl.valid = 0;
#endif

    // Increment rpc_id and update_flag
    ++rpc_id_cnt_;
    update_flag_ ^= 1;

#ifdef AVX2_WRITE
    // Send request with AVX2 intrinsics
    // TODO: send also msb or use AVX-512
    _mm256_store_si256(reinterpret_cast<__m256i*>(tx_buff_),
                        *(reinterpret_cast<__m256i*>(&req_pckt)));
    _mm256_store_si256(reinterpret_cast<__m256i*>(tx_buff_ + 32),
                        *(reinterpret_cast<__m256i*>(&req_pckt)));
    _mm_mfence();
#ifdef NIC_CCIP_DMA
    // Explicitly notify NIC to initiate a DMA
    nic_->notify_nic_of_new_dma(nic_flow_id_);
#endif
#else
    // As alternative, send request with simple word-by-word writes
    *(reinterpret_cast<RpcReqPckt*>(tx_buff_)) = req_pckt;
    // TODO: x86/64 gives strong memory consistency;
    // do we still need this fence here?
    _mm_mfence();
    // Write valid bit
    (reinterpret_cast<RpcReqPckt*>(tx_buff_))->hdr.ctl.valid = 1;
#ifdef NIC_CCIP_DMA
    // Explicitly notify NIC to initiate a DMA
    _mm_mfence();
    nic_->notify_nic_of_new_dma(nic_flow_id_);
#endif
#endif

    ++req_sent_;

    // Spin-wait here for the response
    volatile RpcRespPckt* resp_pckt =
                            reinterpret_cast<volatile RpcRespPckt*>(rx_buff_);
    while (resp_pckt->hdr.ctl.valid == 0 || resp_pckt->hdr.rpc_id == prev_rpc_id_);
    prev_rpc_id_ = resp_pckt->hdr.rpc_id;
    ++req_recved_;

    assert(resp_pckt->hdr.rpc_id == req_pckt.hdr.rpc_id);
    return resp_pckt->ret_val;
}

uint32_t RpcClient::boo(uint32_t a) {
    // Create RPC
    RpcReqPckt req_pckt __attribute__ ((aligned (64)));
    req_pckt.hdr.rpc_id          = client_id_ | static_cast<uint32_t>(
                                                            rpc_id_cnt_ << 16);
    req_pckt.hdr.fn_id           = 1; // TODO: make this flexible
    req_pckt.hdr.num_of_args     = 1;
    req_pckt.hdr.ctl.direction   = DirReq;
    req_pckt.hdr.ctl.update_flag = update_flag_;
    req_pckt.arg1                = a;
    req_pckt.arg2                = ARG_NOT_DEFINED;

#ifdef AVX2_WRITE
    // Set valid bit now
    req_pckt.hdr.ctl.valid = 1;
#else
    // Set valid bit later
    req_pckt.hdr.ctl.valid = 0;
#endif

    // Increment rpc_id and update_flag
    ++rpc_id_cnt_;
    update_flag_ ^= 1;

#ifdef AVX2_WRITE
    // Send request with AVX2 intrinsics
    // TODO: send also msb or use AVX-512
    _mm256_store_si256(reinterpret_cast<__m256i*>(tx_buff_),
                        *(reinterpret_cast<__m256i*>(&req_pckt)));
    _mm256_store_si256(reinterpret_cast<__m256i*>(tx_buff_ + 32),
                        *(reinterpret_cast<__m256i*>(&req_pckt)));
    _mm_mfence();
#ifdef NIC_CCIP_DMA
    // Explicitly notify NIC to initiate a DMA
    nic_->notify_nic_of_new_dma(nic_flow_id_);
#endif
#else
    // As alternative, send request with simple word-by-word writes
    *(reinterpret_cast<RpcReqPckt*>(tx_buff_)) = req_pckt;
    // TODO: x86/64 gives strong memory consistency;
    // do we still need this fence here?
    _mm_mfence();
    // Write valid bit
    (reinterpret_cast<RpcReqPckt*>(tx_buff_))->hdr.ctl.valid = 1;
#ifdef NIC_CCIP_DMA
    // Explicitly notify NIC to initiate a DMA
    _mm_mfence();
    nic_->notify_nic_of_new_dma(nic_flow_id_);
#endif
#endif

    ++req_sent_;

    // Spin-wait here for the response
    volatile RpcRespPckt* resp_pckt =
                            reinterpret_cast<volatile RpcRespPckt*>(rx_buff_);
    while (resp_pckt->hdr.ctl.valid == 0 || resp_pckt->hdr.rpc_id == prev_rpc_id_);
    prev_rpc_id_ = resp_pckt->hdr.rpc_id;
    ++req_recved_;

    assert(resp_pckt->hdr.rpc_id == req_pckt.hdr.rpc_id);
    return resp_pckt->ret_val;
}

}  // namespace frpc
