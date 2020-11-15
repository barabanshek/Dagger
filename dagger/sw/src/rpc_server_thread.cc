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
                                 const RpcServerCallBack_Base* callback):
        thread_id_(thread_id),
        nic_(nic),
        nic_flow_id_(nic_flow_id),
        server_callback_(callback) {
#ifdef NIC_CCIP_MMIO
    if (cfg::nic::l_tx_queue_size != 0) {
        FRPC_ERROR("In MMIO mode, only one entry in the tx queue is allowed\n");
    }
#endif

    // Allocate queues
    tx_queue_ = TxQueue(nic_->get_tx_flow_buffer(nic_flow_id_),
                        nic_->get_mtu_size_bytes(),
                        cfg::nic::l_tx_queue_size);
    tx_queue_.init();

    rx_queue_ = RxQueue(nic_->get_rx_flow_buffer(nic_flow_id_),
                        nic_->get_mtu_size_bytes(),
                        cfg::nic::l_rx_queue_size);
    rx_queue_.init();

#ifdef NIC_CCIP_DMA
    current_batch_ptr = 0;
    batch_counter = 0;
#endif

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

    RpcPckt* req_pckt;

    while(!stop_signal_) {
        RpcPckt req_pckt_1[batch_size] __attribute__ ((aligned (64)));
        for(int i=0; i<batch_size && !stop_signal_; ++i) {
            // wait response
            uint32_t rx_rpc_id;
            req_pckt = reinterpret_cast<RpcPckt*>(rx_queue_.get_read_ptr(rx_rpc_id));
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

        for(int i=0; i<batch_size; ++i) {
            server_callback_->operator()(req_pckt_1 + i, tx_queue_);
        }
    }

    FRPC_INFO("Thread %d is stopped\n", thread_id_);
}

}  // namespace frpc
