#ifndef _NIC_CCIP_MMIO_H_
#define _NIC_CCIP_MMIO_H_

#include <stddef.h>
#include <stdint.h>

#include "nic_ccip.h"

#include "iostream"

namespace frpc {

#define CL(x) ((x) * cfg::sys::cl_size_bytes)

/// Polling-based CCIP NIC.
/// Provides software support for CCI-P polling.
///
/// Inheritance hierarchy:
///   Nic -> NicCCIP -> NicPollingCCIP
///                  -> NicMmioCCIP
///                  -> NicDmaCCIP
///
class NicMmioCCIP: public NicCCIP {
public:
    NicMmioCCIP(uint64_t base_rf_addr, size_t num_of_flows, bool master_nic);
    virtual ~NicMmioCCIP();

    virtual int start() final;
    virtual int stop() final;

    virtual int configure_data_plane() final;

    virtual int notify_nic_of_new_dma(size_t flow, size_t bucket) const {
        // No needs to explicitly notify NIC
        return 0;
    }

    virtual char* get_tx_flow_buffer(size_t flow) const final {
        return reinterpret_cast<char*>(tx_mmio_buf_) + tx_cl_offset_ + CL(flow);
    }

    virtual volatile char* get_rx_flow_buffer(size_t flow) const final {
        return buf_ + CL(rx_cl_offset_) + CL(flow);
    }

    virtual const char* get_tx_buff_end() const final {
        return reinterpret_cast<char*>(tx_mmio_buf_) + tx_cl_offset_ + CL(num_of_flows_);
    }
    virtual const char* get_rx_buff_end() const final { return nullptr; }

private:
    // Number of Nic flows;
    // one flow = one CPU-NIC communication channel
    size_t num_of_flows_;

    // Mmaped Rx buffer
    volatile char *buf_;
    // Buffer id
    uint64_t wsid_;
    // NIC-viewed physical address of the buffer
    uint64_t buf_pa_;
    // Offsets
    uint64_t rx_cl_offset_;

    // MMIO-maped Tx buffer;
    uint64_t* tx_mmio_buf_;
    // Offset
    uint64_t tx_cl_offset_;
    size_t rx_queue_size_bytes_;

};

}  // namespace frpc

#endif
