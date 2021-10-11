/**
 * @file rpc_threaded_server.h
 * @brief Implementation of the RPC server.
 * @author Nikita Lazarev
 */
#ifndef _RPC_THREADED_SERVER_H_
#define _RPC_THREADED_SERVER_H_

#include <memory>
#include <mutex>
#include <vector>

#include "nic.h"
#include "rpc_server_thread.h"

namespace dagger {

/// This class implements a wrapper on top of the RpcServerThread class
/// encapsulating server threads, and abstracts away low-level details of
/// the communication with the nic.
class RpcThreadedServer {
 public:
  RpcThreadedServer() = default;

  /// Create the RPC server object with the given number of threads and based on
  /// the nic with the hardware MMIO address @param base_nic_addr.
  RpcThreadedServer(uint64_t base_nic_addr, size_t max_num_of_threads);
  ~RpcThreadedServer();

  /// A wrapper on top of the nic's init/start/stop API.
  int init_nic(int bus);
  int start_nic();
  int stop_nic();

  /// A wrapper on top of the nic's hardware error checker API.
  int check_hw_errors() const;

  /// Run a new listening thread with the RPC handler @param rpc_callback and
  /// pin its dispatch thread to the CPU @param pim_cpu.
  int run_new_listening_thread(const RpcServerCallBack_Base* rpc_callback,
                               int pin_cpu = -1);

  /// Stop all currently running RPC threads.
  int stop_all_listening_threads();

  // Connection management API.
  int connect(const IPv4& client_addr, ConnectionId c_id,
              ConnectionFlowId c_flow_id);
  int disconnect(ConnectionId c_id);

  /// Run the perf_thread with the corresponsing @param perf_mask as the perf
  /// event filter and the post-processing callback function @param callback.
  /// The perf_thread runs periodically, reads hardware performance counters and
  /// calls the callback function to perform all sort of processing on the
  /// performance data.
  int run_perf_thread(NicPerfMask perf_mask,
                      void (*callback)(const std::vector<uint64_t>&));

  /// Set the desired load balancing scheme which will be used to distribute
  /// requests across the RpcServerThread's.
  void set_lb(int lb);

 private:
  size_t max_num_of_threads_;
  uint64_t base_nic_addr_;

  /// The NIC is shared by all threads in the pool and owned by the
  /// RpcThreadedServer class.
  std::unique_ptr<Nic> nic_;

  /// Thread pool.
  std::vector<std::unique_ptr<RpcServerThread>> threads_;
  size_t thread_cnt_;

  /// Sync.
  std::mutex mtx_;

  /// Status of the underlying hardware nic.
  bool nic_is_started_;
};

}  // namespace dagger

#endif
