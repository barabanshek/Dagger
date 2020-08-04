#include "nic_ccip_mmio.h"

#include <assert.h>

#include <opae/fpga.h>

#include "config.h"
#include "logger.h"

namespace frpc {

NicMmioCCIP::NicMmioCCIP(uint64_t base_nic_addr, size_t num_of_flows, bool master_nic = true):
    NicCCIP(base_nic_addr, master_nic),
    dp_configured_(false),
    num_of_flows_(num_of_flows),
    buf_(nullptr),
    rx_cl_offset_(0),
    tx_cl_offset_(0) {

}

NicMmioCCIP::~NicMmioCCIP() {
    if (dp_configured_) {
        fpgaReleaseBuffer(accel_handle_, wsid_);
        FRPC_INFO("Nic buffers are released\n");
    }
}

int NicMmioCCIP::configure_data_plane() {
    assert(connected_ == true);
    assert(initialized_ == true);
    assert(dp_configured_ == false);

    // Check the nic is mmio-compatible
    uint64_t ccip_mode = 0;
    fpga_result res = fpgaReadMMIO64(accel_handle_,
                                     0,
                                     base_nic_addr_ + iRegCcipMode,
                                     &ccip_mode);
    if (res != FPGA_OK) {
        FRPC_ERROR("Nic configuration error, failed to read ccip mode register"
                    "nic returned: %d\n", res);
        return 1;
    }
    if (ccip_mode != iConstCcipMMIO) {
        FRPC_ERROR("Nic configuration error, "
                   "the harwdare is not CCI-P MMIO compatible");
        return 1;
    }

    // Allocate Rx buffer
    rx_queue_size_bytes_ = get_mtu_size_bytes() * (1 << cfg::nic::l_rx_queue_size);
    size_t buff_size_bytes = num_of_flows_ * rx_queue_size_bytes_;
    buf_ = (volatile char*)alloc_buffer(accel_handle_,
                                        buff_size_bytes,
                                        &wsid_,
                                        &buf_pa_);
    if (buf_ == nullptr) {
        FRPC_ERROR("Failed to allocate shared buffer\n");
        return 1;
    }
    FRPC_INFO("Shared nic buffer of size %uB is allocated by address 0x%x; "
              "buffer's nic-viewed physical address is 0x%x\n",
              buff_size_bytes,
              reinterpret_cast<volatile void*>(buf_),
              buf_pa_);

    // Configure Rx buffer
    rx_cl_offset_ = 0;
    res = fpgaWriteMMIO64(accel_handle_,
                          0,
                          base_nic_addr_ + iRegMemRxAddr,
                          buf_pa_ / CL(1) + rx_cl_offset_);
    if (res != FPGA_OK) {
        FRPC_ERROR("Nic configuration error, failed to configure Rx buffer,"
                    "nic returned %d\n", res);
        return 1;
    }

    // Configure rx batch size
    res = fpgaWriteMMIO64(accel_handle_,
                          0,
                          base_nic_addr_ + lRegTxBatchSize,
                          cfg::nic::l_rx_batch_size);
    if (res != FPGA_OK) {
        FRPC_ERROR("Nic configuration error, failed to configure rx batch size,"
                    "nic returned %d\n", res);
        return 1;
    }

    // Allocate Tx buffer
    // In MMIO mode, each Tx buffer has exactly one entry
    assert(cfg::nic::l_tx_queue_size == 0);
    res = fpgaMapMMIO(accel_handle_, 0, &tx_mmio_buf_);
    if (res != FPGA_OK) {
        FRPC_ERROR("Failed to allocate MMIO buffer, nic returned %d\n", res);
        return 1;
    }
    if (tx_mmio_buf_ == nullptr) {
        FRPC_ERROR("Failed to allocate MMIO buffer, NULL returned\n");
        return 1;
    }

    // Configure Tx buffer
    tx_cl_offset_ = base_nic_addr_ + iMMIOSpaceStart;
    res = fpgaWriteMMIO64(accel_handle_,
                          0,
                          base_nic_addr_ + iRegMemTxAddr,
                          tx_cl_offset_/mmio_cpu_nic_view);
    if (res != FPGA_OK) {
        FRPC_ERROR("Nic configuration error, failed to configure Tx buffer,"
                    "nic returned %d\n", res);
        return 1;
    }

    // Configure the number of flows
    res = fpgaWriteMMIO64(accel_handle_,
                          0,
                          base_nic_addr_ + iRegNumOfFlows,
                          num_of_flows_);
    if (res != FPGA_OK) {
        FRPC_ERROR("Nic configuration error, failed to configure number of flows,"
                    "nic returned %d\n", res);
        return 1;
    }

    dp_configured_ = true;
    FRPC_INFO("Nic dataplane is configured\n");
    return 0;
}

int NicMmioCCIP::start(bool perf) {
    assert(dp_configured_ == true);
    return start_nic(perf);;
}

int NicMmioCCIP::stop() {
    assert(dp_configured_ == true);
    return stop_nic();
}

}  // namespace frpc
