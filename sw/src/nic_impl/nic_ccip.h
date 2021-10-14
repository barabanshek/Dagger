/**
 * @file nic_impl.h
 * @brief Base implementation of the CCI-P-based nics.
 * @author Nikita Lazarev
 */
#ifndef _NIC_CCIP_H_
#define _NIC_CCIP_H_

#include <opae/fpga.h>
#include <stddef.h>
#include <stdint.h>
#include <uuid/uuid.h>

#include <mutex>
#include <string>
#include <thread>

#include "config.h"
#include "connection_manager.h"
#include "fpga_hssi.h"
#include "nic.h"

namespace dagger {

/// Abstract class for all CCIP-based nics.
/// Provides implementation of the common functionality of CCI-P based nics.
///
/// Inheritance hierarchy:
///   Nic -> NicCCIP -> NicPollingCCIP
///                  -> NicMmioCCIP
///                  -> NicDmaCCIP
///
/// Extend this class for more hardware configurations and implemented nics.
class NicCCIP : public Nic {
 public:
  /// MTU.
  static constexpr size_t mtu_cls = 1;
  /// MMIO CPU/FPGA view: nic_addr = cpu_addr/4.
  static constexpr size_t mmio_cpu_nic_view = 4;

  /// Hardware register map. This should be consistent with hardware definition
  /// in the RTL.
  static constexpr uint8_t iRegMemTxAddr = 0;         // hw: 0, W
  static constexpr uint8_t iRegMemRxAddr = 8;         // hw: 2, W
  static constexpr uint8_t iRegNicStart = 16;         // hw: 4, W
  static constexpr uint8_t iRegNumOfFlows = 24;       // hw: 6, W
  static constexpr uint8_t iRegNicInit = 32;          // hw: 8, W
  static constexpr uint8_t iRegNicStatus = 40;        // hw: 10, R
  static constexpr uint8_t iRegCcipRps = 48;          // hw: 12, R
  static constexpr uint8_t iRegGetPckCnt = 56;        // hw: 14, W
  static constexpr uint8_t iRegPckCnt = 64;           // hw: 16, R
  static constexpr uint8_t iRegNicMode = 72;          // hw: 18, R
  static constexpr uint8_t iRegCcipDmaTrg = 80;       // hw: 20, W
  static constexpr uint8_t iRegRxQueueSize = 88;      // hw: 22, W
  static constexpr uint8_t lRegTxBatchSize = 96;      // hw: 24, W
  static constexpr uint8_t lRegRxBatchSize = 104;     // hw: 26, W
  static constexpr uint8_t iRegPollingRate = 112;     // hw: 28, W
  static constexpr uint8_t iRegConnSetupFrame = 120;  // hw: 30, W
  static constexpr uint8_t iRegConnStatus = 128;      // hw: 32, R
  static constexpr uint8_t iRegLb = 136;              // hw: 34, W
  static constexpr uint8_t iRegPhyNetAddr = 144;      // hw: 36, W
  static constexpr uint8_t iRegIPv4NetAddr = 152;     // hw: 38, W
  static constexpr uint8_t iRegNetDropCntRead = 160;  // hw: 40, W
  static constexpr uint8_t iRegNetDropCnt = 168;      // hw: 42, R
  static constexpr uint8_t iRegTxQueueSize = 176;     // hw: 44, W
  static constexpr uint8_t iRegDebug_0 = 184;         // hw: 46, W
  static constexpr uint16_t iMMIOSpaceStart = 256;    // hw: 64, -

  // Hardware register map constants.
  static constexpr int iConstNicStart = 1;
  static constexpr int iConstNicStop = 0;
  static constexpr int iConstNicInit = 1;
  static constexpr int iConstCcipMMIO = 0;
  static constexpr int iConstCcipPolling = 1;
  static constexpr int iConstCcipDma = 2;
  static constexpr int iConstCcipQueuePolling = 3;
  static constexpr int iPhyNetDisabled = 0;
  static constexpr int iPhyNetEnabled = 1;
  static constexpr uint8_t iNumOfPckCnt = 5;
  static constexpr uint8_t iNumOfNetworkCnt = 9;

  /// Construct the nic based on the @param base_rf_addr MMIO base address,
  /// @param num_of_flows number of active hardware flows. The @param master_nic
  /// specifies whether this instance owns the hardware.
  NicCCIP(uint64_t base_rf_addr, size_t num_of_flows, bool master_nic);
  virtual ~NicCCIP();

  // Implementation of the common for all CCI-P nics functionality. These APIs
  // terminate here.
  virtual int connect_to_nic(int bus = -1) final;
  virtual int initialize_nic(const PhyAddr& host_phy,
                             const IPv4& host_ipv4) final;
  virtual int check_hw_errors() const final;
  virtual size_t get_mtu_size_bytes() const final {
    return mtu_cls * cfg::sys::cl_size_bytes;
  }
  virtual int open_connection(ConnectionId& c_id, const IPv4& dest_addr,
                              ConnectionFlowId c_flow_id) const final;
  virtual int add_connection(ConnectionId c_id, const IPv4& dest_addr,
                             ConnectionFlowId c_flow_id) const final;
  virtual int close_connection(ConnectionId c_id) const final;
  virtual int run_perf_thread(
      NicPerfMask perf_mask,
      void (*callback)(const std::vector<uint64_t>&)) final;
  virtual void set_lb(int lb) const final;

  // CCI-P implementation dependent functionality. These APIs are implemented in
  // the inherited classes.
  virtual int configure_data_plane(size_t llc_anti_aliasing = 0) = 0;
  virtual int start() = 0;
  virtual int stop() = 0;
  virtual int notify_nic_of_new_dma(size_t flow, size_t bucket) const = 0;
  virtual volatile char* get_tx_flow_buffer(size_t flow) const = 0;
  virtual volatile char* get_rx_flow_buffer(
      size_t flow) const = 0;  // TODO: make const char*
  virtual const char* get_tx_buff_end() const = 0;
  virtual const char* get_rx_buff_end() const = 0;

 protected:
  /// Low-level API to allocate shared with the FPGA buffers.
  volatile void* alloc_buffer(fpga_handle accel_handle, ssize_t size,
                              uint64_t* wsid, uint64_t* io_addr,
                              size_t llc_anti_aliasing = 0) const;

  /// Implementation of the nic start/stop functionality.
  int start_nic();
  int stop_nic();

  // The structure to define supported nic modes.
  struct __attribute__((__packed__)) NicMode {
    uint8_t ccip_mode : 2;
    uint8_t phy_network_mode : 1;
  };

 private:
  /// Get page size from the Kernel configuration.
  size_t get_page_size() const;

  /// Round-up a value to the size of the pages.
  size_t round_up_to_pagesize(size_t val) const;

  /// Low-level API to connect to the FPGA.
  fpga_handle connect_to_accel(const char* accel_uuid, int bus) const;

  /// TODO(Nikita): why is this here?????
  static constexpr int phy_net_channel = 0;

  /// Initialize HSSI components om the FPGA to enable MAC/PHY interfaces to the
  /// physical networking.
  int initialize_phy_network(int channel);

  /// Dump networking statistics obtained through hardware HSSI counters.
  void dump_hssi_stat(int channel);

  /// Nic status.
  struct __attribute__((__packed__)) NicHwStatus {
    uint16_t nic_id : 3;
    uint16_t ready : 1;
    uint16_t running : 1;
    uint16_t error : 1;
    uint16_t err_rpcRxFifoOvf : 1;
    uint16_t err_rpcTxFifoOvf : 1;
    uint16_t err_ccip : 1;
    uint16_t err_rpc : 1;
  };

  /// The API to read status registers form the hardware.
  int get_nic_hw_status(NicHwStatus& status) const;

  /// The function to dump hardware status registers.
  std::string dump_nic_hw_status(const NicHwStatus& status) const;

  ///
  /// Nic connection manager.
  ///
  /// Connection setup commands.
  static constexpr uint8_t setUpConnId = 0;
  static constexpr uint8_t setUpOpen = 1;
  static constexpr uint8_t setUpDestIPv4 = 2;
  static constexpr uint8_t setUpDestPort = 3;
  static constexpr uint8_t setUpClientFlowId = 4;
  static constexpr uint8_t setUpEnable = 5;

  /// Connection setup frame.
  struct __attribute__((__packed__)) ConnSetupFrame {
    uint32_t data;
    uint8_t cmd : 3;
    uint8_t padding : 5;
  };
  static_assert(sizeof(ConnSetupFrame) == 5);

  /// Connection setup status.
  static constexpr uint8_t cOK = 0;
  static constexpr uint8_t cAlreadyOpen = 1;
  static constexpr uint8_t cIsClosed = 2;
  static constexpr uint8_t cIdWrong = 3;

  /// Connection setup status.
  struct __attribute__((__packed__)) ConnSetupStatus {
    uint32_t conn_id;
    uint8_t valid : 1;
    uint8_t error_status : 2;
    uint8_t padding : 5;
  };
  static_assert(sizeof(ConnSetupStatus) == 5);

  enum ConnOpenClose { cClose = 0, cOpen = 1 };

  /// Connection setup methods.
  int register_connection(ConnectionId c_id, const IPv4& dest_addr,
                          ConnectionFlowId c_flow_id) const;
  int remove_connection(ConnectionId c_id) const;

  /// Perf loop.
  void nic_perf_loop(NicPerfMask perf_mask,
                     void (*callback)(const std::vector<uint64_t>&)) const;

  /// Dump hardware performance counters.
  void get_perf() const;

  /// Dump hardware nic status register.
  void get_status() const;

  /// Packet counters.
  /// This method accepts the @param callback which can be used to run
  /// user-specific analytics over the packet counters.
  void get_packet_counters(
      void (*callback)(const std::vector<uint64_t>&)) const;

  /// Dump network counters.
  void get_network_counters() const;

  /// Dump debug ports
  void get_debug_ports() const;

 protected:
  uint64_t base_nic_addr_;

  // FPGA handler.
  fpga_handle accel_handle_;

  // HSSI networking handler.
  fpga_hssi_handle hssi_h_;

  // Nic status.
  // TODO(Nikita): define a status enum instead.
  bool connected_;
  bool initialized_;
  bool dp_configured_;
  bool started_;

 private:
  // In case of running multiple NICs, specify the one responsible for closing
  // physical connection with FPGA.
  bool master_nic_;

  // PHY network enabled/disabled.
  bool phy_network_en_;

  // Perf thread.
  volatile bool collect_perf_;
  std::thread perf_thread_;

  // Connection manager.
  // TODO(Nikita): is this the right place for connection manager?
  //       I don't like 'mutable' here, the nic has always been const!
  //       Is connection setup considered as modification of the nic?
  //       Think of a better abstraction here.
  mutable ConnectionManager conn_manager_;

  // Sync connection setup.
  mutable std::mutex conn_setup_mtx_;
  mutable std::mutex conn_setup_hw_mtx_;
};

}  // namespace dagger

#endif
