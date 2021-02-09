#include "rpc_server_thread.h"

#include <assert.h>

#include "config.h"
#include "rpc_header.h"
#include "logger.h"

#include <immintrin.h>

#include <unistd.h>

#include <iostream>

namespace frpc {

static constexpr size_t worker_job_queue_size_mult = 100000;

RpcServerThread::RpcServerThread(const Nic* nic,
                                 size_t nic_flow_id,
                                 uint16_t thread_id,
                                 const RpcServerCallBack_Base* callback,
                                 size_t worker_threads):
        thread_id_(thread_id),
        nic_(nic),
        nic_flow_id_(nic_flow_id),
        server_callback_(callback),
        num_worker_threads_(worker_threads) {
#ifdef NIC_CCIP_MMIO
    if (cfg::nic::l_tx_queue_size != 0) {
        FRPC_ERROR("In MMIO mode, only one entry in the tx queue is allowed\n");
    }
#endif

    if (num_worker_threads_ != 0) {
        // Run this server with working threads
        run_worker_threads_ = true;
        worker_job_queue_size_ = num_worker_threads_ * worker_job_queue_size_mult;
    } else {
        run_worker_threads_ = false;
        worker_job_queue_size_ = 0;
    }

    bool thread_safe_tx_queue = run_worker_threads_;

    // Allocate queues
    tx_queue_ = TxQueue(nic_->get_tx_flow_buffer(nic_flow_id_),
                        nic_->get_mtu_size_bytes(),
                        cfg::nic::l_tx_queue_size,
                        thread_safe_tx_queue);
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
    // Start dispatch thread
    stop_signal_ = 0;
    thread_ = std::thread(&RpcServerThread::_PullListen, this);

    // Pin dispatch thread to a certain CPU core
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

    // Start working threads if so requested
    // Worker threads run and wait on a condition_variable for new job
    if (run_worker_threads_) {
        FRPC_INFO("Thread %d is running in dispatch mode with %zu workers\n", thread_id_, num_worker_threads_);

        for (size_t i=0; i<num_worker_threads_; ++i) {
            worker_thread_pool_.push_back(std::thread(&RpcServerThread::_Worker,
                                                      this,
                                                      i));
        }
    } else {
        FRPC_INFO("Thread %d is running in combined dispatch-worker mode\n", thread_id_);
    }

    return 0;
}

void RpcServerThread::stop_listening() {
    stop_signal_ = 1;
    thread_.join();
}

// Pull-based listening
void RpcServerThread::_PullListen() {
    FRPC_INFO("Dispatch thread %d is listening now on CPU %d\n", thread_id_, sched_getcpu());
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
            if (run_worker_threads_) {
                // Check if there is room in the job queue
                while (worker_job_queue_.size() == worker_job_queue_size_) {
                    // We are full, need to wait a bit
                    usleep(1);
                }

                // Lock
                std::unique_lock<std::mutex> lck(worker_thread_pool_lck_);

                // Push job to the queue
                worker_job_queue_.push(*(req_pckt_1 + i));

                // Notify any free worker
                worker_thread_pool_cv_.notify_one();

            } else {
                server_callback_->operator()({thread_id_}, req_pckt_1 + i, tx_queue_);
            }
        }
    }

    FRPC_INFO("Dispatch thread %d is stopped\n", thread_id_);
}

void RpcServerThread::_Worker(size_t worker_id) {
    RpcPckt job;
    while (true) {
        {
            std::unique_lock<std::mutex> lck(worker_thread_pool_lck_);

            // Wait until job comes
            while(worker_job_queue_.empty()) {
                worker_thread_pool_cv_.wait(lck);
            }

            job = worker_job_queue_.front();
            worker_job_queue_.pop();
        }

        // Do the job
        server_callback_->operator()({thread_id_}, &job, tx_queue_);
    }
}

}  // namespace frpc
