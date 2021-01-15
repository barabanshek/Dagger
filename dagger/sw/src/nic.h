#ifndef _NIC_H_
#define _NIC_H_

#include <stddef.h>
#include <stdint.h>

#include <vector>

#include "connection_manager.h"

namespace frpc {

/// Abstract class for a Nic.
/// Provides the Nic interface.
///
/// Inheritance hierarchy:
///   Nic -> NicCCIP -> NicPollingCCIP
///                  -> NicMmioCCIP
///                  -> NicDmaCCIP
///
struct NicPerfMask {
    bool performance;
    bool status;
    bool packet_counters;
};

class Nic {
public:
    Nic() {}
    virtual ~Nic() {}

    // Nic implementation dependent functionality
    virtual int connect_to_nic() = 0;
    virtual int initialize_nic() = 0;
    virtual int configure_data_plane() = 0;
    virtual int start() = 0;
    virtual int stop() = 0;
    virtual int check_hw_errors() const = 0;
    virtual int open_connection(ConnectionId& c_id,
                                const IPv4& dest_addr,
                                ConnectionFlowId c_flow_id) const = 0;
    virtual int add_connection(ConnectionId c_id,
                               const IPv4& dest_addr,
                               ConnectionFlowId c_flow_id) const = 0;
    virtual int close_connection(ConnectionId c_d) const = 0;
    virtual int notify_nic_of_new_dma(size_t flow, size_t bucket) const = 0;
    virtual char* get_tx_flow_buffer(size_t flow) const = 0;
    virtual volatile char* get_rx_flow_buffer(size_t flow) const = 0;
    virtual const char* get_tx_buff_end() const = 0;
    virtual const char* get_rx_buff_end() const = 0;
    virtual size_t get_mtu_size_bytes() const = 0;
    virtual int run_perf_thread(NicPerfMask perf_mask,
                        void(*callback)(const std::vector<uint64_t>&)) = 0;

};

}  // namespace frpc

#endif
