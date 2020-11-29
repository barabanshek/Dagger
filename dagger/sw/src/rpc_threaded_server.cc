#include "rpc_threaded_server.h"

#include "nic_ccip_dma.h"
#include "nic_ccip_polling.h"
#include "nic_ccip_mmio.h"
#include "logger.h"

namespace frpc {

RpcThreadedServer::RpcThreadedServer(uint64_t base_nic_addr, size_t max_num_of_threads):
        max_num_of_threads_(max_num_of_threads),
        base_nic_addr_(base_nic_addr),
        thread_cnt_(0),
        nic_is_started_(false) {
}

RpcThreadedServer::~RpcThreadedServer() {
    // Stop all threads
    if (threads_.size() > 0) {
        stop_all_listening_threads();
    }

    // Stop NIC
    if (nic_is_started_) {
        stop_nic();
    }
}

int RpcThreadedServer::init_nic() {
    // Create Nic
    // Define Nic interface with CPU
#ifdef NIC_CCIP_POLLING
    #pragma message "compiling Nic to run in polling mode"
    // Simple case so far: number of NIC flows = max_num_of_threads_
    nic_ = std::unique_ptr<Nic>(
                    new NicPollingCCIP(base_nic_addr_, max_num_of_threads_, true));
#elif NIC_CCIP_MMIO
    // MMIO intefrace only works either with write-combine buffering or AVX
    // intrinsics
    #pragma message "compiling Nic to run in MMIO mode"
    // Simple case so far: number of NIC flows = max_num_of_threads_
    nic_ = std::unique_ptr<Nic>(
                    new NicMmioCCIP(base_nic_addr_, max_num_of_threads_, true));
#elif NIC_CCIP_DMA
    #pragma message "compiling Nic to run in DMA mode"
    // Simple case so far: number of NIC flows = max_num_of_threads_
    nic_ = std::unique_ptr<Nic>(
                    new NicDmaCCIP(base_nic_addr_, max_num_of_threads_, true));
#else
    #error Nic CCI-P mode is not specified
#endif

    int res = nic_->connect_to_nic();
    if (res != 0)
        return res;
    FRPC_INFO("Connected to NIC\n");

    res = nic_->initialize_nic();
    if (res != 0)
        return res;

    res = nic_->configure_data_plane();
    if (res != 0)
        return res;

    return 0;
}

int RpcThreadedServer::start_nic(bool perf) {
    int res = nic_->start(perf);
    if (res != 0) {
        FRPC_ERROR("Failed to start NIC\n");
        return res;
    }

    nic_is_started_ = true;
    FRPC_INFO("NIC is started\n");
    return 0;
}

int RpcThreadedServer::stop_nic() {
    int res = nic_->stop();
    if (res != 0) {
        FRPC_ERROR("Failed to stop NIC\n");
        return res;
    }

    nic_is_started_ = false;
    FRPC_INFO("Server NIC is stopped\n");
    return 0;
}

int RpcThreadedServer::check_hw_errors() const {
    return nic_->check_hw_errors();
}

int RpcThreadedServer::run_new_listening_thread(
                            const RpcServerCallBack_Base* rpc_callback) {
    std::unique_lock<std::mutex> lck(mtx_);

    if (thread_cnt_ < max_num_of_threads_) {
        threads_.push_back(std::unique_ptr<RpcServerThread>(
                        new RpcServerThread(nic_.get(),
                                            thread_cnt_,
                                            thread_cnt_,
                                            rpc_callback)));
        threads_.back().get()->start_listening();
        ++thread_cnt_;
        return 0;
    } else {
        FRPC_ERROR("Max number of rpc threads is reached: %zu\n", max_num_of_threads_);
        return 1;
    }
}

int RpcThreadedServer::stop_all_listening_threads() {
    for (auto& thread: threads_) {
        thread->stop_listening();
    }

    threads_.clear();
    thread_cnt_ = 0;
    return 0;
}

}  // namespace frpc
