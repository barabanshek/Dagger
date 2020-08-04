#ifndef _NIC_CCIP_DMA_H_
#define _NIC_CCIP_DMA_H_

#include <stddef.h>
#include <stdint.h>

#include <mutex>

#include "nic_ccip.h"

#include <opae/fpga.h>

namespace frpc {

#define CL(x) ((x) * NicCCIP::cacheline_size_bytes)

/// DMA-based CCIP NIC.
/// Provides software support for CCI-P DMA.
///
/// Inheritance hierarchy:
///   Nic -> NicCCIP -> NicPollingCCIP
///                  -> NicMmioCCIP
///                  -> NicDmaCCIP
///
class NicDmaCCIP: public NicCCIP {
public:
    NicDmaCCIP(uint64_t base_rf_addr, size_t num_of_flows, bool master_nic);
    virtual ~NicDmaCCIP();

    virtual int start(bool perf=false);
    virtual int stop();

    virtual int configure_data_plane();

    // Make sure to sync memory before calling this function
    virtual int notify_nic_of_new_dma(size_t flow, size_t bucket) const;

    virtual char* get_tx_flow_buffer(size_t flow) const {
        return const_cast<char*>(buf_) + tx_offset_bytes_ + flow * tx_queue_size_bytes_;
    }

    virtual volatile char* get_rx_flow_buffer(size_t flow) const {
        return buf_ + rx_offset_bytes_ + flow * rx_queue_size_bytes_;
    }

    virtual const char* get_tx_buff_end() const {
        return const_cast<char*>(buf_) + tx_offset_bytes_ + tx_buff_size_bytes_;
    }
    virtual const char* get_rx_buff_end() const {
        return const_cast<char*>(buf_) + rx_offset_bytes_ + rx_buff_size_bytes_;
    }

private:
    bool dp_configured_;

    // Number of Nic flows;
    // one flow = one CPU-NIC communication channel
    size_t num_of_flows_;

    // Shared with the NIC buffer
    volatile char *buf_;

    // Buffer id
    uint64_t wsid_;

    // NIC-viewed physical address of the buffer
    uint64_t buf_pa_;

    // Tx and Rx offsets
    size_t tx_offset_bytes_;
    size_t rx_offset_bytes_;

    // Tx and Rx sizes
    size_t tx_buff_size_bytes_;
    size_t rx_buff_size_bytes_;

    // Flow size
    size_t tx_queue_size_bytes_;
    size_t rx_queue_size_bytes_;

    // NIC notification mutex
    mutable std::mutex dma_notification_lock_ ;

};

}  // namespace frpc

#endif
