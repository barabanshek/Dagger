#include "nic_ccip_polling.h"

#include <assert.h>
#include <opae/fpga.h>

#include "config.h"
#include "logger.h"

namespace dagger {

NicPollingCCIP::NicPollingCCIP(uint64_t base_nic_addr, size_t num_of_flows,
                               bool master_nic = true)
    : NicCCIP(base_nic_addr, num_of_flows, master_nic),
      num_of_flows_(num_of_flows),
      buf_(nullptr),
      tx_offset_bytes_(0),
      rx_offset_bytes_(0),
      tx_buff_size_bytes_(0),
      rx_buff_size_bytes_(0),
      tx_queue_size_bytes_(0),
      rx_queue_size_bytes_(0) {}

NicPollingCCIP::~NicPollingCCIP() {
  if (dp_configured_) {
    fpgaReleaseBuffer(accel_handle_, wsid_);
    FRPC_INFO("Nic buffers are released\n");
  }
}

int NicPollingCCIP::configure_data_plane() {
  assert(connected_ == true);
  assert(dp_configured_ == false);

  // Check the nic is polling-compatible.
  NicMode *ccip_mode;
  uint64_t raw_mode;
  fpga_result res =
      fpgaReadMMIO64(accel_handle_, 0, base_nic_addr_ + iRegNicMode, &raw_mode);
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to read ccip mode register"
        "nic returned: %d\n",
        res);
    return 1;
  }
  ccip_mode = reinterpret_cast<NicMode *>(&raw_mode);
  if (ccip_mode->ccip_mode != iConstCcipQueuePolling) {
    FRPC_ERROR(
        "Nic configuration error, "
        "the harwdare is not CCI-P queue polling compatible\n");
    // It always fails when cross-clock shim is used in HW
    // TODO: fix the issue
    // return 1;
  }

  // Allocate Rx and Tx buffers.
  tx_queue_size_bytes_ =
      get_mtu_size_bytes() * (1 << cfg::nic::l_tx_queue_size);
  tx_buff_size_bytes_ = num_of_flows_ * tx_queue_size_bytes_;
  rx_queue_size_bytes_ =
      get_mtu_size_bytes() * (1 << cfg::nic::l_rx_queue_size);
  rx_buff_size_bytes_ = num_of_flows_ * rx_queue_size_bytes_;

  size_t buff_size_bytes = tx_buff_size_bytes_ + rx_buff_size_bytes_;
  buf_ = (volatile char *)alloc_buffer(accel_handle_, buff_size_bytes, &wsid_,
                                       &buf_pa_);
  if (buf_ == nullptr) {
    FRPC_ERROR("Failed to allocate shared buffer\n");
    return 1;
  }
  FRPC_INFO(
      "Shared nic buffer of size %uB is allocated by address 0x%x; "
      "buffer's nic-viewed physical address is 0x%x\n",
      buff_size_bytes, reinterpret_cast<volatile void *>(buf_), buf_pa_);

  // Configure Rx and Tx buffers.
  // NIC's side data are cache line aligned.
  tx_offset_bytes_ = 0;
  rx_offset_bytes_ = tx_offset_bytes_ + tx_buff_size_bytes_;

  res = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegMemTxAddr,
                        buf_pa_ / CL(1) + tx_offset_bytes_ / CL(1));
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to configure Tx buffer,"
        "nic returned %d\n",
        res);
    return 1;
  }

  res = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegMemRxAddr,
                        buf_pa_ / CL(1) + rx_offset_bytes_ / CL(1));
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to configure Rx buffer,"
        "nic returned %d\n",
        res);
    return 1;
  }

  // Configure number of flows.
  res = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegNumOfFlows,
                        num_of_flows_);
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to configure number of flows,"
        "nic returned %d\n",
        res);
    return 1;
  }

  // Configure tx-queue depth.
  // tx-queue from CPU size is rx-queue from Nic side
  //   - tx-queue is configured by iRegRxQueueSize.
  res = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegRxQueueSize,
                        tx_queue_size_bytes_ / CL(1));
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to configure tx queue depth,"
        "nic returned %d\n",
        res);
    return 1;
  }

  // Configure rx queue depth.
  // rx-queue from CPU size is tx-queue from Nic side
  //   - rx-queue is configured by iRegTxQueueSize.
  res = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegTxQueueSize,
                        rx_queue_size_bytes_ / CL(1));
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to configure tx queue depth,"
        "nic returned %d\n",
        res);
    return 1;
  }

  // Configure polling rate.
  res = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegPollingRate,
                        cfg::nic::polling_rate);
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to configure polling rate,"
        "nic returned %d\n",
        res);
    return 1;
  }

  // Configure rx batch size.
  res = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + lRegTxBatchSize,
                        cfg::nic::l_rx_batch_size);
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to configure rx batch size,"
        "nic returned %d\n",
        res);
    return 1;
  }

  dp_configured_ = true;
  FRPC_INFO("Nic dataplane is configured\n");
  return 0;
}

int NicPollingCCIP::start() {
  assert(dp_configured_ == true);
  assert(initialized_ == true);
  return start_nic();
}

int NicPollingCCIP::stop() {
  assert(dp_configured_ == true);
  assert(initialized_ == true);
  return stop_nic();
}

}  // namespace dagger
