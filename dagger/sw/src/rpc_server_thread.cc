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

int RpcServerThread::register_connection(ConnectionId c_id, const IPv4& server_addr) {
    return nic_->add_connection(c_id, server_addr, 0);
}

int RpcServerThread::remove_connection(ConnectionId c_id) {
    return nic_->close_connection(c_id);
}

int RpcServerThread::start_listening(int pin_cpu) {
    stop_signal_ = 0;
    thread_ = std::thread(&RpcServerThread::_PullListen, this);

    // Pin thread to a certain CPU core
    if (pin_cpu != -1) {
        cpu_set_t cpuset;
        CPU_ZERO(&cpuset);
        CPU_SET(pin_cpu, &cpuset);
        int rc = pthread_setaffinity_np(thread_.native_handle(),
                                        sizeof(cpu_set_t), &cpuset);
        if (rc != 0) {
            FRPC_ERROR("Failed to pin thread %d to CPU %d\n", thread_id_, pin_cpu);
            return 1;
        }
    }

    return 0;
}

void RpcServerThread::stop_listening() {
    stop_signal_ = 1;
    thread_.join();
}

// Pull-based listening
void RpcServerThread::_PullListen() {
    FRPC_INFO("Thread %d is listening now on CPU %d\n", thread_id_, sched_getcpu());
    //if (rx_buff_ >= nic_->get_rx_buff_end()) {
    //    FRPC_ERROR("Nic rx buffer overflow \n");
    //    assert(false);
    //}

    constexpr size_t batch_size = 1 << cfg::nic::l_rx_batch_size;

    volatile RpcPckt* req_pckt;

    while(!stop_signal_) {
        RpcPckt req_pckt_1[batch_size] __attribute__ ((aligned (64)));
        for(int i=0; i<batch_size && !stop_signal_; ++i) {
            // wait response
            uint32_t rx_rpc_id;
            req_pckt = reinterpret_cast<volatile RpcPckt*>(rx_queue_.get_read_ptr(rx_rpc_id));
            while((req_pckt->hdr.ctl.valid == 0 ||
                   req_pckt->hdr.rpc_id == rx_rpc_id) &&
                  !stop_signal_) {
            }

            if (stop_signal_) continue;

            rx_queue_.update_rpc_id(req_pckt->hdr.rpc_id);

            req_pckt_1[i] = *const_cast<RpcPckt*>(req_pckt);

            //_mm256_store_si256(&req_pckt_1[i], *(reinterpret_cast<__m256i*>(req_pckt)));
            //_mm256_store_si256(reinterpret_cast<__m256i*>(&req_pckt_1[i] + 32),
            //                   *(reinterpret_cast<__m256i*>(req_pckt + 32)));

        }
        if (stop_signal_) continue;

        for(int i=0; i<batch_size; ++i) {
        //    std::cout << "DEBUG: recv packet: ********* "
        //        << "\n hdr.ctl.req_type: " << (int)((req_pckt_1 + i)->hdr.ctl.req_type)
        //        << "\n hdr.ctl.valid: " << (int)((req_pckt_1 + i)->hdr.ctl.valid)
        //        << "\n hdr.argl: " << (int)((req_pckt_1 + i)->hdr.argl)
        //        << "\n hdr.c_id: " << (int)((req_pckt_1 + i)->hdr.c_id)
        //        << "\n hdr.rpc_id: " << (int)((req_pckt_1 + i)->hdr.rpc_id)
        //        << "\n hdr.fn_id: " << (int)((req_pckt_1 + i)->hdr.fn_id)
        //        << "\n argv: ";
        //    for (int j=0; j<cfg::sys::cl_size_bytes - rpc_header_size_bytes; ++j) {
        //        std::cout << (int)(((req_pckt_1 + i)->argv)[j]) << " ";
        //    }
        //    std::cout << "\n **************** " << std::endl;

            server_callback_->operator()({thread_id_}, req_pckt_1 + i, tx_queue_);
        }
    }

    FRPC_INFO("Thread %d is stopped\n", thread_id_);
}

}  // namespace frpc
