#include "rpc_server_thread.h"

#include <assert.h>

#include "config.h"
#include "rpc_header.h"
#include "logger.h"

#include <immintrin.h>

#include <unistd.h>

#include <iostream>

namespace frpc {

RpcServerThread::RpcServerThread(const Nic* nic,
                                 size_t nic_flow_id,
                                 uint16_t thread_id,
                                 const std::vector<const void*>& rpc_fn_ptr):
        thread_id_(thread_id),
        nic_(nic),
        nic_flow_id_(nic_flow_id),
        rpc_fn_ptr_(rpc_fn_ptr) {
    // Allocate queues
    tx_queue_ = TxQueue(nic_->get_tx_flow_buffer(nic_flow_id_), nic_->get_mtu_size_bytes(), cfg::nic::l_tx_queue_size);
    rx_queue_ = RxQueue(nic_->get_rx_flow_buffer(nic_flow_id_), nic_->get_mtu_size_bytes(), cfg::nic::l_rx_queue_size);

    FRPC_INFO("Thread %d is created\n", thread_id_);
}

RpcServerThread::~RpcServerThread() {

}

void RpcServerThread::start_listening() {
    stop_signal_ = 0;
    thread_ = std::thread(&RpcServerThread::_PullListen, this);
}

void RpcServerThread::stop_listening() {
    stop_signal_ = 1;
    thread_.join();
}

// Pull-based listening
void RpcServerThread::_PullListen() {
    FRPC_INFO("Thread %d is listening now...\n", thread_id_);

    //if (rx_buff_ >= nic_->get_rx_buff_end()) {
    //    FRPC_ERROR("Nic rx buffer overflow \n");
    //    assert(false);
    //}

    constexpr size_t batch_size = 1 << cfg::nic::l_rx_batch_size;

    RpcReqPckt* req_pckt;
    RpcRespPckt resp_pckt __attribute__ ((aligned (64)));

    while(!stop_signal_) {
        RpcReqPckt req_pckt_1[batch_size] __attribute__ ((aligned (64)));
        for(int i=0; i<batch_size && !stop_signal_; ++i) {
            // wait response
            uint32_t rx_rpc_id;
            req_pckt = reinterpret_cast<RpcReqPckt*>(rx_queue_.get_read_ptr(rx_rpc_id));
            while((req_pckt->hdr.ctl.valid == 0 ||
                   req_pckt->hdr.rpc_id == rx_rpc_id) &&
                  !stop_signal_) {
            }

            if (stop_signal_) continue;

            rx_queue_.update_rpc_id(req_pckt->hdr.rpc_id);

            req_pckt_1[i] = *req_pckt;

            //_mm256_store_si256(&req_pckt_1[i], *(reinterpret_cast<__m256i*>(req_pckt)));
            //_mm256_store_si256(reinterpret_cast<__m256i*>(&req_pckt_1[i] + 32),
            //                   *(reinterpret_cast<__m256i*>(req_pckt + 32)));

        }
        if (stop_signal_) continue;


        //RpcReqPckt* req_pckt_1_casted;
        //req_pckt_1_casted = reinterpret_cast<RpcReqPckt*>(req_pckt_1);
        //FRPC_FLOW("Thread %d received an RPC, fn_id= %d\n", thread_id_, req_pckt->hdr.fn_id);

        
        for(int i=0; i<batch_size; ++i) {
            // call function
            uint32_t ret_value = 0;
            if (req_pckt_1[i].hdr.fn_id == 0) {
                ret_value = (*reinterpret_cast<uint32_t(*)(uint32_t, uint32_t)>
                            (rpc_fn_ptr_[0]))(req_pckt_1[i].arg1, req_pckt_1[i].arg2);
            } else if (req_pckt_1[i].hdr.fn_id == 1) {
                ret_value = (*reinterpret_cast<uint32_t(*)(uint32_t)>
                            (rpc_fn_ptr_[1]))(req_pckt_1[i].arg1);
            } else {
                FRPC_ERROR("Thread %d received a wrong function_id= %d\n", thread_id_, req_pckt_1[i].hdr.fn_id);
                // TODO: what should we do in this case?
            }

            // Get current buffer pointer
            uint8_t change_bit;
            char* tx_ptr = tx_queue_.get_write_ptr(change_bit);
            //if (tx_ptr >= nic_->get_tx_buff_end()) {
            //    FRPC_ERROR("Nic tx buffer overflow \n");
            //    assert(false);
            //}
            //assert(reinterpret_cast<size_t>(tx_ptr) % nic_->get_mtu_size_bytes() == 0);

            // return value
            (reinterpret_cast<RpcRespPckt*>(tx_ptr))->hdr.num_of_args     = req_pckt_1[i].hdr.num_of_args;
            (reinterpret_cast<RpcRespPckt*>(tx_ptr))->hdr.rpc_id          = req_pckt_1[i].hdr.rpc_id;
            (reinterpret_cast<RpcRespPckt*>(tx_ptr))->hdr.fn_id           = req_pckt_1[i].hdr.fn_id;
            (reinterpret_cast<RpcRespPckt*>(tx_ptr))->hdr.ctl.direction   = DirResp;
            (reinterpret_cast<RpcRespPckt*>(tx_ptr))->hdr.ctl.update_flag = change_bit;
            (reinterpret_cast<RpcRespPckt*>(tx_ptr))->ret_val             = ret_value;
            _mm_mfence();
            (reinterpret_cast<RpcRespPckt*>(tx_ptr))->hdr.ctl.valid = 1;
        }

//#ifdef AVX2_WRITE
//        // Set valid bit now
//        resp_pckt.hdr.ctl.valid = 1;
//#else
//        // Set valid bit later
//        resp_pckt.hdr.ctl.valid = 0;
//#endif
//
//#ifdef AVX2_WRITE
//        // Send response with AVX2 intrinsics
//        // TODO: send also msb or use AVX-512
//        _mm256_store_si256(reinterpret_cast<__m256i*>(tx_ptr),
//                           *(reinterpret_cast<__m256i*>(&resp_pckt)));
//        _mm256_store_si256(reinterpret_cast<__m256i*>(tx_ptr + 32),
//                           *(reinterpret_cast<__m256i*>(&resp_pckt)));
//        _mm_mfence();
//#ifdef NIC_CCIP_DMA
//        // Explicitly notify NIC to initiate a DMA
//        nic_->notify_nic_of_new_dma(nic_flow_id_);
//#endif
//#else
//        // As alternative, send response with simple word-by-word writes
//        *(reinterpret_cast<RpcRespPckt*>(tx_ptr)) = resp_pckt;
//        // TODO: x86/64 gives strong memory consistency;
//        // do we still need this fence here?
//        _mm_mfence();
//        // Write valid bit
//        (reinterpret_cast<RpcRespPckt*>(tx_ptr))->hdr.ctl.valid = 1;
//#ifdef NIC_CCIP_DMA
//        // Explicitly notify NIC to initiate a DMA
//        _mm_mfence();
//        nic_->notify_nic_of_new_dma(nic_flow_id_);
//#endif
//#endif

    }

    FRPC_INFO("Thread %d is stoped\n", thread_id_);
}

}  // namespace frpc
