#ifndef _NIC_H_
#define _NIC_H_

#include <stddef.h>
#include <stdint.h>

namespace frpc {

/// Abstract class for a Nic.
/// Provides the Nic interface.
///
/// Inheritance hierarchy:
///   Nic -> NicCCIP -> NicPollingCCIP
///                  -> NicMmioCCIP
///                  -> NicDmaCCIP
///
class Nic {
public:
    Nic() {}
    virtual ~Nic() {}

    // Nic implementation dependent functionality
    virtual int connect_to_nic() = 0;
    virtual int initialize_nic() = 0;
    virtual int configure_data_plane() = 0;
    virtual int start(bool perf=false) = 0;
    virtual int stop() = 0;
    virtual int check_hw_errors() const = 0;
    virtual int notify_nic_of_new_dma(size_t flow) const = 0;
    virtual char* get_tx_flow_buffer(size_t flow) const = 0;
    virtual volatile char* get_rx_flow_buffer(size_t flow) const = 0;
    virtual const char* get_tx_buff_end() const = 0;
    virtual const char* get_rx_buff_end() const = 0;
    virtual size_t get_mtu_size_bytes() const = 0;

};

}  // namespace frpc

#endif
