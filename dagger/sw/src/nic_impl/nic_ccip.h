#ifndef _NIC_CCIP_H_
#define _NIC_CCIP_H_

#include <string>
#include <thread>

#include <stddef.h>
#include <stdint.h>

#include <opae/fpga.h>
#include <uuid/uuid.h>

#include "config.h"
#include "nic.h"

namespace frpc {

/// Abstract class for a CCIP-based NIC.
/// Provides implementation of the common functionality of CCI-P based NICs.
///
/// Inheritance hierarchy:
///   Nic -> NicCCIP -> NicPollingCCIP
///                  -> NicMmioCCIP
///                  -> NicDmaCCIP
///
class NicCCIP: public Nic {
public:
    // CL size and MTU
    static constexpr size_t mtu_cls = 1;
    // MMIO CPU/FPGA view: nic_addr = cpu_addr/4
    static constexpr size_t mmio_cpu_nic_view = 4;

    // Hardware register map
    static constexpr uint8_t iRegMemTxAddr   = 0;    // hw: 0, W
    static constexpr uint8_t iRegMemRxAddr   = 8;    // hw: 2, W
    static constexpr uint8_t iRegNicStart    = 16;   // hw: 4, W
    static constexpr uint8_t iRegNumOfFlows  = 24;   // hw: 6, W
    static constexpr uint8_t iRegNicInit     = 32;   // hw: 8, W
    static constexpr uint8_t iRegNicStatus   = 40;   // hw: 10, R
    static constexpr uint8_t iRegCcipRps     = 48;   // hw: 12, R
    static constexpr uint8_t iRegGetPckCnt   = 56;   // hw: 14, W
    static constexpr uint8_t iRegPckCnt      = 64;   // hw: 16, R
    static constexpr uint8_t iRegCcipMode    = 72;   // hw: 18, R
    static constexpr uint8_t iRegCcipDmaTrg  = 80;   // hw: 20, W
    static constexpr uint8_t iRegRxQueueSize = 88;   // hw: 22, W
    static constexpr uint8_t lRegTxBatchSize = 96;   // hw: 24, W
    static constexpr uint8_t lRegRxBatchSize = 104;  // hw: 26, W
    static constexpr uint8_t iRegPollingRate = 112;  // hw: 28, W
    static constexpr uint16_t iMMIOSpaceStart = 256;  // hw: 64, -

    // Hardware register map constants
    static constexpr int iConstNicStart         = 1;
    static constexpr int iConstNicStop          = 0;
    static constexpr int iConstNicInit          = 1;
    static constexpr int iConstCcipMMIO         = 0;
    static constexpr int iConstCcipPolling      = 1;
    static constexpr int iConstCcipDma          = 2;
    static constexpr int iConstCcipQueuePolling = 3;
    static constexpr uint8_t iNumOfPckCnt       = 4;

    NicCCIP(uint64_t base_rf_addr, bool master_nic);
    virtual ~NicCCIP();

    // Common functionality
    virtual int connect_to_nic();
    virtual int initialize_nic();
    virtual int check_hw_errors() const;
    virtual size_t get_mtu_size_bytes() const {
        return mtu_cls * cfg::sys::cl_size_bytes;
    }

    // CCI-P implementation dependent functionality
    virtual int configure_data_plane() = 0;
    virtual int start(bool perf=false) = 0;
    virtual int stop() = 0;
    virtual int notify_nic_of_new_dma(size_t flow, size_t bucket) const = 0;
    virtual char* get_tx_flow_buffer(size_t flow) const = 0;
    virtual volatile char* get_rx_flow_buffer(size_t flow) const = 0;  // TODO: make const char*
    virtual const char* get_tx_buff_end() const = 0;
    virtual const char* get_rx_buff_end() const = 0;

protected:
    volatile void* alloc_buffer(fpga_handle accel_handle, ssize_t size,
                                uint64_t *wsid, uint64_t *io_addr) const;

    int start_nic(bool perf=false);
    int stop_nic();

private:
    size_t round_up_to_pagesize(size_t val) const;
    fpga_handle connect_to_accel(const char *accel_uuid) const;

    // NIC status
    struct __attribute__ ((__packed__)) NicHwStatus {
        uint16_t nic_id           : 3;
        uint16_t ready            : 1;
        uint16_t running          : 1;
        uint16_t error            : 1;
        uint16_t err_rpcRxFifoOvf : 1;
        uint16_t err_rpcTxFifoOvf : 1;
        uint16_t err_ccip         : 1;
    };
    int get_nic_hw_status(NicHwStatus& status) const;
    std::string dump_nic_hw_status(const NicHwStatus& status) const;

    void get_perf() const;

protected:
    uint64_t base_nic_addr_;

    // NIC handler
    fpga_handle accel_handle_;

    // NIC status
    bool connected_;
    bool initialized_;
    bool started_;

private:
    // In case of running multiple NICs, specify the one
    // responsible for closing physical connection with FPGA
    bool master_nic_;

    // Perf thread
    volatile bool collect_perf_;
    std::thread perf_thread_;

};

}  // namespace frpc

#endif
