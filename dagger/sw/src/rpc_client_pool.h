#ifndef _RPC_CLIENT_POOL_
#define _RPC_CLIENT_POOL_

#include <memory>
#include <vector>
#include <mutex>

#include "nic.h"
#include "nic_ccip_dma.h"
#include "nic_ccip_polling.h"
#include "nic_ccip_mmio.h"
#include "logger.h"

namespace frpc {

template <class T>
class RpcClientPool {
public:
    RpcClientPool() = default;
    RpcClientPool(uint64_t base_nic_addr, size_t max_pool_size):
        max_pool_size_(max_pool_size),
        base_nic_addr_(base_nic_addr),
        rpc_client_cnt_(0),
        nic_is_started_(false) {
    }

    ~RpcClientPool() {
        if (nic_is_started_) {
            stop_nic();
        }
    }

    int init_nic(int bus) {
        // Create Nic
#ifdef ASE_SIMULATION
    // If running is ASE, create a slave Nic
    #pragma message "compiling client in ASE mode, running nic in slave mode"

    // Define Nic interface with CPU
    #ifdef NIC_CCIP_POLLING
        #pragma message "compiling Nic to run in polling mode"
        // Simple case so far: number of NIC flows = max_pool_size_
        nic_ = std::unique_ptr<Nic>(
                        new NicPollingCCIP(base_nic_addr_, max_pool_size_, false));
    #elif NIC_CCIP_MMIO
        // MMIO intefrace only works either with write-combine buffering or AVX
        // intrinsics
        #pragma message "compiling Nic to run in MMIO mode"
        // Simple case so far: number of NIC flows = max_pool_size_
        nic_ = std::unique_ptr<Nic>(
                        new NicMmioCCIP(base_nic_addr_, max_pool_size_, false));
    #elif NIC_CCIP_DMA
        #pragma message "compiling Nic to run in DMA mode"
        // Simple case so far: number of NIC flows = max_pool_size_
        nic_ = std::unique_ptr<Nic>(
                        new NicDmaCCIP(base_nic_addr_, max_pool_size_, false));
    #else
        #error Nic CCI-P mode is not specified
    #endif

#else
    #pragma message "compiling client in HW mode, running nic in master mode"

    // Define Nic interface with CPU
    #ifdef NIC_CCIP_POLLING
        #pragma message "compiling Nic to run in polling mode"
        // Simple case so far: number of NIC flows = max_pool_size_
        nic_ = std::unique_ptr<Nic>(
                        new NicPollingCCIP(base_nic_addr_, max_pool_size_, true));
    #elif NIC_CCIP_MMIO
        // MMIO intefrace only works either with write-combine buffering or AVX
        // intrinsics
        #pragma message "compiling Nic to run in MMIO mode"
        // Simple case so far: number of NIC flows = max_pool_size_
        nic_ = std::unique_ptr<Nic>(
                        new NicMmioCCIP(base_nic_addr_, max_pool_size_, true));
    #elif NIC_CCIP_DMA
        #pragma message "compiling Nic to run in DMA mode"
        // Simple case so far: number of NIC flows = max_pool_size_
        nic_ = std::unique_ptr<Nic>(
                        new NicDmaCCIP(base_nic_addr_, max_pool_size_, true));
    #else
        #error Nic CCI-P mode is not specified
    #endif

#endif

        // Connect to NIC
#ifdef PLATFORM_PAC_A10
        int res = nic_->connect_to_nic(bus);
#elif PLATFORM_BDX
        int res = nic_->connect_to_nic();
#else
        #error Platform is not specified
#endif
        if (res != 0)
            return res;
        FRPC_INFO("Connected to NIC\n");

        // Host networking addresses
        PhyAddr cl_phy_addr = {0x1A, 0x2B, 0x3C, 0x4D, 0x5E, 0x6D};
        IPv4 cl_ipv4_addr("192.168.0.1", 0);

        res = nic_->initialize_nic(cl_phy_addr, cl_ipv4_addr);
        if (res != 0)
            return res;

        res = nic_->configure_data_plane();
        if (res != 0)
            return res;

        return 0;
    }

    int start_nic() {
        int res = nic_->start();
        if (res != 0) {
            FRPC_ERROR("Failed to start NIC\n");
            return res;
        }

        nic_is_started_ = true;
        FRPC_INFO("NIC is started\n");
        return 0;
    }

    int stop_nic() {
        int res = nic_->stop();
        if (res != 0) {
            FRPC_ERROR("Failed to stop NIC\n");
            return res;
        }

        nic_is_started_ = false;
        FRPC_INFO("Client NIC is stopped\n");
        return 0;
    }

    int check_hw_errors() const {
        return nic_->check_hw_errors();
    }

    // Run perf thread on the nic
    int run_perf_thread(NicPerfMask perf_mask,
                        void(*callback)(const std::vector<uint64_t>&)) {
        return nic_->run_perf_thread(perf_mask, callback);
    }

    // Pop the next rpc clent; this method is thread-safe
    T* pop() {
        std::unique_lock<std::mutex> lck(mtx_);

        if (rpc_client_cnt_ < max_pool_size_) {
            // Directly map rpc clients to the NIC flows for now
            rpc_client_pool.push_back(std::unique_ptr<T>(
                                            new T(nic_.get(),
                                                  rpc_client_cnt_,
                                                  rpc_client_cnt_)));
            ++rpc_client_cnt_;
            return rpc_client_pool.back().get();
        } else {
            FRPC_ERROR("Max number of rpc clients is reached: %zu\n",
                                                        max_pool_size_);
            return nullptr;
        }
    }

private:
    size_t max_pool_size_;
    uint64_t base_nic_addr_;

    // The NIC is shared by all RpcClients in the pool
    // and owned by the RpcClientPool class
    std::unique_ptr<Nic> nic_;

    // Rpc client pool
    std::vector<std::unique_ptr<T>> rpc_client_pool;

    // Rpc client counter
    size_t rpc_client_cnt_;

    // Sync
    std::mutex mtx_;

    // Status
    bool nic_is_started_;

};

}  // namespace frpc

#endif
