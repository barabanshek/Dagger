/**
 * @file rpc_client_pool.h
 * @brief Our own implementation of the RPC client pool.
 * @author Nikita Lazarev
 */
#ifndef _RPC_CLIENT_POOL_
#define _RPC_CLIENT_POOL_

#include <memory>
#include <mutex>
#include <vector>

#include "logger.h"
#include "nic.h"
#include "nic_ccip_dma.h"
#include "nic_ccip_mmio.h"
#include "nic_ccip_polling.h"

namespace dagger {

/// A pool of RPC clients. All the clients in the pool share the same nic. This
/// class is the "owner" of the nic, i.e. it is responsible for initialization
/// and configuration of the hardware for the RPC clients which it manages.
template <class T>
class RpcClientPool {
 public:
  RpcClientPool() = default;

  /// Create the RPC client pool object with the given capacity and
  /// based on the nic with the hardware MMIO address @param base_nic_addr.
  RpcClientPool(uint64_t base_nic_addr, size_t max_pool_size)
      : max_pool_size_(max_pool_size),
        base_nic_addr_(base_nic_addr),
        rpc_client_cnt_(0),
        nic_is_started_(false) {}

  ~RpcClientPool() {
    if (nic_is_started_) {
      stop_nic();
    }
  }

  /// This function initializes the backend's nic depending on the exact type of
  /// the nic. The function performs four actions to initialize the nic.
  int init_nic(int bus) {
    // (1) Create nic for all clients in the pool.
#ifdef ASE_SIMULATION
// If running is ASE, create a slave nic. We need this as in the ASE mode,
// multiple nics share the same FPGA.
#  pragma message "compiling client in ASE mode, running nic in slave mode"

// Define Nic interface with CPU
#  ifdef NIC_CCIP_POLLING
#    pragma message "compiling Nic to run in polling mode"
    // Simple case so far: number of NIC flows = max_pool_size_.
    nic_ = std::unique_ptr<Nic>(
        new NicPollingCCIP(base_nic_addr_, max_pool_size_, false));
#  elif NIC_CCIP_MMIO
// MMIO intefrace only works either with write-combine buffering or AVX
// intrinsics.
#    pragma message "compiling Nic to run in MMIO mode"
    // Simple case so far: number of NIC flows = max_pool_size_.
    nic_ = std::unique_ptr<Nic>(
        new NicMmioCCIP(base_nic_addr_, max_pool_size_, false));
#  elif NIC_CCIP_DMA
#    pragma message "compiling Nic to run in DMA mode"
    // Simple case so far: number of NIC flows = max_pool_size_.
    nic_ = std::unique_ptr<Nic>(
        new NicDmaCCIP(base_nic_addr_, max_pool_size_, false));
#  else
#    error Nic CCI-P mode is not specified
#  endif

#else
// In the real-hardware mode, all the nics are master devices.
#  pragma message "compiling client in HW mode, running nic in master mode"

// Define nic interface with the CPU.
#  ifdef NIC_CCIP_POLLING
#    pragma message "compiling Nic to run in polling mode"
    // Simple case so far: number of NIC flows = max_pool_size_
    nic_ = std::unique_ptr<Nic>(
        new NicPollingCCIP(base_nic_addr_, max_pool_size_, true));
#  elif NIC_CCIP_MMIO
// MMIO intefrace only works either with write-combine buffering or AVX
// intrinsics
#    pragma message "compiling Nic to run in MMIO mode"
    // Simple case so far: number of NIC flows = max_pool_size_
    nic_ = std::unique_ptr<Nic>(
        new NicMmioCCIP(base_nic_addr_, max_pool_size_, true));
#  elif NIC_CCIP_DMA
#    pragma message "compiling Nic to run in DMA mode"
    // Simple case so far: number of NIC flows = max_pool_size_
    nic_ = std::unique_ptr<Nic>(
        new NicDmaCCIP(base_nic_addr_, max_pool_size_, true));
#  else
#    error Nic CCI-P mode is not specified
#  endif

#endif

    // (2) Connect to nic.
#ifdef PLATFORM_PAC_A10
    // This is multi-FPGA system, so we need to explicitely set the bus.
    int res = nic_->connect_to_nic(bus);
#elif PLATFORM_BDX
    // Single-FPGSA system.
    int res = nic_->connect_to_nic();
#else
#  error Platform is not specified
#endif
    if (res != 0) return res;
    FRPC_INFO("Connected to NIC\n");

    // (3) Configure the nic dataplane. Of course, all the clients in this pool
    // share the same configuration.
    PhyAddr cl_phy_addr = {0x1A, 0x2B, 0x3C, 0x4D, 0x5E, 0x6D};
    IPv4 cl_ipv4_addr("192.168.0.1", 0);

    res = nic_->configure_data_plane();
    if (res != 0) return res;

    // (4) Run hardware initialization.
    res = nic_->initialize_nic(cl_phy_addr, cl_ipv4_addr);
    if (res != 0) return res;

    return 0;
  }

  /// A wrapper on top of the nic's start() API.
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

  /// A wrapper on top of the nic's stop() API.
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

  /// A wrapper on top of the nic's hardware error checking API.
  int check_hw_errors() const { return nic_->check_hw_errors(); }

  /// Run the perf_thread with the corresponsing @param perf_mask as the perf
  /// event filter and the post-processing callback function @param callback.
  /// The perf_thread runs periodically, reads hardware performance counters and
  /// calls the callback function to perform all sort of processing on the
  /// performance data.
  int run_perf_thread(NicPerfMask perf_mask,
                      void (*callback)(const std::vector<uint64_t>&)) {
    return nic_->run_perf_thread(perf_mask, callback);
  }

  /// Pop the next RPC client from the pool.
  /// This method is thread-safe.
  T* pop() {
    std::unique_lock<std::mutex> lck(mtx_);

    if (rpc_client_cnt_ < max_pool_size_) {
      // Directly map rpc clients to the NIC flows for now
      rpc_client_pool.push_back(std::unique_ptr<T>(
          new T(nic_.get(), rpc_client_cnt_, rpc_client_cnt_)));
      ++rpc_client_cnt_;
      return rpc_client_pool.back().get();
    } else {
      FRPC_ERROR("Max number of rpc clients is reached: %zu\n", max_pool_size_);
      return nullptr;
    }
  }

 private:
  size_t max_pool_size_;
  uint64_t base_nic_addr_;

  /// The NIC is shared by all RpcClients in the pool
  /// and owned by the RpcClientPool class.
  std::unique_ptr<Nic> nic_;

  /// Rpc client pool.
  std::vector<std::unique_ptr<T>> rpc_client_pool;

  /// Rpc client counter.
  size_t rpc_client_cnt_;

  /// Sync.
  std::mutex mtx_;

  /// Status of the underlying hardware nic.
  bool nic_is_started_;
};

}  // namespace dagger

#endif
