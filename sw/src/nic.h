/**
 * @file nic.h
 * @brief Abstract class for a Nic providing all the interfaces to hardware. The
 * exact implementation of these interfaces depends on the type/configuration of
 * the hardware nic on the FPGA.
 * @author Nikita Lazarev
 */
#ifndef _NIC_H_
#define _NIC_H_

#include <stddef.h>
#include <stdint.h>

#include <vector>

#include "connection_manager.h"
#include "defs.h"

namespace dagger {

/// Inheritance hierarchy:
///   Nic -> NicCCIP -> NicPollingCCIP
///                  -> NicMmioCCIP
///                  -> NicDmaCCIP
///
/// Extend this class for more hardware configurations and implemented nics.
class Nic {
 public:
  Nic() {}
  virtual ~Nic() {}

  ///
  /// Nic implementation dependent functionality.
  ///

  /// Connect to the FPGA sitting on the bus @param bus.
  virtual int connect_to_nic(int bus = -1) = 0;

  /// Run initialization process of the nic. This implementaton-dependent method
  /// initializes all hardware structures of the nic.
  virtual int initialize_nic(const PhyAddr& host_phy,
                             const IPv4& host_ipv4) = 0;

  /// Run dataplane configuration process. This implementation-dependent method
  /// configures hardware RX and TX paths of the nic.
  virtual int configure_data_plane() = 0;

  /// Comand the hardware to start and stop the nic.
  virtual int start() = 0;
  virtual int stop() = 0;

  /// Read error flags from the nic and assert their values.
  virtual int check_hw_errors() const = 0;

  /// Open connection on the nic. The nic expexts to provide the generated
  /// connection id @param c_id.
  virtual int open_connection(ConnectionId& c_id, const IPv4& dest_addr,
                              ConnectionFlowId c_flow_id) const = 0;

  /// Add connection on the nic. The API allows to specify a custom connection
  /// id as @param c_id.
  virtual int add_connection(ConnectionId c_id, const IPv4& dest_addr,
                             ConnectionFlowId c_flow_id) const = 0;

  /// Close connection identified by @param c_d on the nic.
  virtual int close_connection(ConnectionId c_d) const = 0;

  /// TODO(Nikita): hide this method
  virtual int notify_nic_of_new_dma(size_t flow, size_t bucket) const = 0;

  /// Get a pointer to the beginning of the tx buffer for the given hardware
  /// flow @param flow.
  virtual volatile char* get_tx_flow_buffer(size_t flow) const = 0;

  /// Get a pointer to the beginning of the rx buffer for the given hardware
  /// flow @param flow.
  virtual volatile char* get_rx_flow_buffer(size_t flow) const = 0;

  /// Get a pointer to the end of the tx buffer for the given hardware flow
  /// @param flow.
  virtual const char* get_tx_buff_end() const = 0;

  /// Get a pointer to the end of the rx buffer for the given hardware flow
  /// @param flow.
  virtual const char* get_rx_buff_end() const = 0;

  /// TODO(Nikita): hide this method
  virtual size_t get_mtu_size_bytes() const = 0;

  /// Run the perf_thread with the corresponsing @param perf_mask as the perf
  /// event filter and the post-processing callback function @param callback.
  /// The perf_thread runs periodically, reads hardware performance counters and
  /// calls the callback function to perform all sort of processing on the
  /// performance data.
  ///
  /// The mask to specify the filter of performance counters for the
  /// run_perf_thread() API call.
  struct NicPerfMask {
    bool performance;
    bool status;
    bool packet_counters;
    bool network_counters;
  };

  virtual int run_perf_thread(
      NicPerfMask perf_mask,
      void (*callback)(const std::vector<uint64_t>&)) = 0;

  /// Set-up the hardware load balancing scheme for the server-destinated
  /// requests.
  virtual void set_lb(int lb) const = 0;
};

}  // namespace dagger

#endif
