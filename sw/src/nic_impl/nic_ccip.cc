#include "nic_ccip.h"

#include <assert.h>
#include <sys/mman.h>
#include <unistd.h>

#include <thread>
#include <vector>

#include "logger.h"

// Hardware configuration.
// NIC's JSON file, extracted using OPAE's afu_json_mgr script.
#include "afu_json_info.h"

namespace frpc {

// Timeout values.
#define NIC_INIT_DELAY_S 1
#define NIC_INIT_TIMEOUT 15  // in # of iteration of NIC_INIT_DELAY_S
#define NIC_PERF_DELAY_S 2

NicCCIP::NicCCIP(uint64_t base_nic_addr, size_t num_of_flows,
                 bool master_nic = true)
    : base_nic_addr_(base_nic_addr),
      hssi_h_(0),
      connected_(false),
      initialized_(false),
      dp_configured_(false),
      started_(false),
      master_nic_(master_nic),
      phy_network_en_(false),
      collect_perf_(false),
      conn_manager_(num_of_flows + 100) {}

NicCCIP::~NicCCIP() {
  if (started_) {
    stop_nic();
  }

  if (hssi_h_) {
    //    dump_hssi_stat(phy_net_channel);
    // TODO: make it to be dependent on FRPC_LOG_LEVEL
    fpgaHssiClose(hssi_h_);
  }

  if (connected_ && master_nic_) {
    fpgaClose(accel_handle_);
  }

  FRPC_INFO("Nic is disconnected\n");
}

int NicCCIP::connect_to_nic(int bus) {
  assert(connected_ == false);

  // Connect to FPGA
  accel_handle_ = connect_to_accel(AFU_ACCEL_UUID, bus);
  if (accel_handle_ == 0) {
    FRPC_ERROR("Failed to connect to nic\n");
    return 1;
  }

  connected_ = true;
  return 0;
}

int NicCCIP::initialize_nic(const PhyAddr& host_phy, const IPv4& host_ipv4) {
  assert(connected_ == true);
  assert(dp_configured_ == true);

  // Assert initial hw state
  NicHwStatus status;
  int res = get_nic_hw_status(status);
  if (res != 0) return res;
  assert(status.ready == 0);
  assert(status.running == 0);
  assert(status.error == 0);

  // Check the nic networking mode
  NicMode* ccip_mode;
  uint64_t raw_mode;
  fpga_result ret =
      fpgaReadMMIO64(accel_handle_, 0, base_nic_addr_ + iRegNicMode, &raw_mode);
  if (ret != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to read ccip mode register"
        "nic returned: %d\n",
        ret);
    return 1;
  }
  ccip_mode = reinterpret_cast<NicMode*>(&raw_mode);
#ifdef NIC_PHY_NETWORK
  if (ccip_mode->phy_network_mode != iPhyNetEnabled) {
    FRPC_ERROR(
        "Nic configuration error, "
        "software is configured with physical networking support, but "
        "the hardware runs in the loopback mode\n");
    return 1;
  }

  // Init HSSI
  res = initialize_phy_network(phy_net_channel);
  if (res != 0) {
    FRPC_ERROR("Failed to initialize physical network\n");
    return 1;
  } else {
    FRPC_INFO("Physical network is initialized\n");
  }

  phy_network_en_ = true;
#else
  if (ccip_mode->phy_network_mode != iPhyNetDisabled) {
    FRPC_ERROR(
        "Nic configuration error, "
        "software is configuredin the loopback mode, but "
        "the harwdare runs physical networking\n");
    return 1;
  }

  phy_network_en_ = false;
#endif

  // Program PHY and IPv4 host addresses
  ret = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegPhyNetAddr,
                        host_phy.b5 | host_phy.b4 << 8 | host_phy.b3 << 16 |
                            host_phy.b2 << 24 | host_phy.b1 << 32 |
                            host_phy.b0 << 40);
  if (ret != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to configure iRegPhyNetAddr"
        "nic returned %d\n",
        ret);
    return 1;
  }

  ret = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegIPv4NetAddr,
                        host_ipv4.get_addr_inv());
  if (ret != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to configure iRegIPv4NetAddr"
        "nic returned %d\n",
        ret);
    return 1;
  }

  // Run initialization
  ret = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegNicInit,
                        iConstNicInit);
  if (ret != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to configure iRegNicInit"
        "nic returned %d\n",
        ret);
    return 1;
  }

  // Wait until NIC is initialized
  int wait_iteration = 0;
  do {
    int res = get_nic_hw_status(status);
    if (res != 0) return res;
    ++wait_iteration;
    sleep(NIC_INIT_DELAY_S);
  } while (status.ready == 0 && wait_iteration < NIC_INIT_TIMEOUT);

  if (status.ready == 0) {
    FRPC_ERROR(
        "Nic configuration error, failed to initialize nic: timeout reached\n");
    return 1;
  }

  assert(status.ready == 1);
  assert(status.running == 0);
  assert(status.error == 0);

  initialized_ = true;
  FRPC_INFO("Nic is initialized\n");
  return 0;
}

int NicCCIP::start_nic() {
  assert(connected_ == true);
  assert(initialized_ == true);
  assert(dp_configured_ == true);
  assert(started_ == false);

  // Assert initial hw state
  NicHwStatus status;
  int res = get_nic_hw_status(status);
  if (res != 0) return res;
  assert(status.ready == 1);
  assert(status.running == 0);
  assert(status.error == 0);

  // Run
  fpga_result ret = fpgaWriteMMIO64(
      accel_handle_, 0, base_nic_addr_ + iRegNicStart, iConstNicStart);
  if (ret != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to configure start bit,"
        "nic returned %d\n",
        ret);
    return 1;
  }

  // Wait until NIC is running
  int wait_iteration = 0;
  do {
    int res = get_nic_hw_status(status);
    if (res != 0) return res;
    ++wait_iteration;
    sleep(NIC_INIT_DELAY_S);
  } while (status.running == 0 && wait_iteration < NIC_INIT_TIMEOUT);

  if (status.running == 0) {
    FRPC_ERROR("Nic configuration error, failed to run nic: timeout reached\n");
    return 1;
  }

  assert(status.ready == 1);
  assert(status.running == 1);
  assert(status.error == 0);

  started_ = true;
  return 0;
}

int NicCCIP::run_perf_thread(NicPerfMask perf_mask,
                             void (*callback)(const std::vector<uint64_t>&)) {
  FRPC_INFO("Running perf thread on the nic\n");
  collect_perf_ = true;
  perf_thread_ =
      std::thread{&NicCCIP::nic_perf_loop, this, perf_mask, callback};
  return 0;
}

int NicCCIP::stop_nic() {
  assert(started_ == true);

  // Assert initial hw state
  NicHwStatus status;
  int res = get_nic_hw_status(status);
  if (res != 0) return res;
  assert(status.ready == 1);
  assert(status.running == 1);

  // Stop perf if running
  if (collect_perf_) {
    collect_perf_ = false;
    perf_thread_.join();
  }

  // Stop
  fpga_result ret = fpgaWriteMMIO64(
      accel_handle_, 0, base_nic_addr_ + iRegNicStart, iConstNicStop);
  if (ret != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to configure start bit,"
        "nic returned %d\n",
        ret);
    return 1;
  }

  // Wait until NIC is stopped
  int wait_iteration = 0;
  do {
    int res = get_nic_hw_status(status);
    if (res != 0) {
      return res;
    }
    ++wait_iteration;
    sleep(NIC_INIT_DELAY_S);
  } while (status.running == 1 && wait_iteration < NIC_INIT_TIMEOUT);

  if (status.running == 1) {
    FRPC_ERROR(
        "Nic configuration error, failed to stop nic: timeout reached\n");
    return 1;
  }

  assert(status.ready == 1);
  assert(status.running == 0);

  started_ = false;
  return 0;
}

int NicCCIP::check_hw_errors() const {
  NicHwStatus status;
  int res = get_nic_hw_status(status);
  if (res != 0) {
    return res;
  }

  if (status.error != 0) {
    FRPC_ERROR("Hardware errors are found in nic %d \n", status.nic_id);
    FRPC_ERROR("%s\n", dump_nic_hw_status(status).c_str());
    return 1;
  }

  return 0;
}

int NicCCIP::open_connection(ConnectionId& c_id, const IPv4& dest_addr,
                             ConnectionFlowId c_flow_id) const {
  std::unique_lock<std::mutex> lck(conn_setup_mtx_);

  if (conn_manager_.open_connection(c_id, dest_addr, c_flow_id) != 0) {
    FRPC_ERROR("Failed to open connection\n");
    return 1;
  }

  if (register_connection(c_id, dest_addr, c_flow_id) != 0) {
    FRPC_ERROR("Failed to register connection on the Nic\n");
    return 1;
  }

  return 0;
}

int NicCCIP::add_connection(ConnectionId c_id, const IPv4& dest_addr,
                            ConnectionFlowId c_flow_id) const {
  std::unique_lock<std::mutex> lck(conn_setup_mtx_);

  if (conn_manager_.add_connection(c_id, dest_addr, c_flow_id) != 0) {
    FRPC_ERROR("Failed to add connection\n");
    return 1;
  }

  if (register_connection(c_id, dest_addr, c_flow_id) != 0) {
    FRPC_ERROR("Failed to register connection on the Nic\n");
    return 1;
  }

  return 0;
}

int NicCCIP::close_connection(ConnectionId c_id) const {
  std::unique_lock<std::mutex> lck(conn_setup_mtx_);

  if (remove_connection(c_id) != 0) {
    FRPC_ERROR("Failed to remove connection on the Nic\n");
    return 1;
  }

  if (conn_manager_.close_connection(c_id) != 0) {
    FRPC_ERROR("Failed to close connection\n");
    return 1;
  }

  return 0;
}

int NicCCIP::register_connection(ConnectionId c_id, const IPv4& dest_addr,
                                 ConnectionFlowId c_flow_id) const {
  assert(connected_ == true);

  std::unique_lock<std::mutex> lck(conn_setup_hw_mtx_);

  fpga_result res;

  // setUpConnId
  // Ignore GCC warning here since designated initializers
  // will be supported in C++20
  ConnSetupFrame frame = {.data = c_id, .cmd = setUpConnId};
  res = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegConnSetupFrame,
                        *reinterpret_cast<uint64_t*>(&frame));
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to register connection, "
        "failed to write setUpConnId, nic returned: %d\n",
        res);
    return 1;
  }

  // setUpOpen
  frame = {.data = cOpen, .cmd = setUpOpen};
  res = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegConnSetupFrame,
                        *reinterpret_cast<uint64_t*>(&frame));
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to register connection, "
        "failed to write setUpOpen, nic returned: %d\n",
        res);
    return 1;
  }

  // setUpDestIPv4
  frame = {.data = dest_addr.get_addr(), .cmd = setUpDestIPv4};
  res = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegConnSetupFrame,
                        *reinterpret_cast<uint64_t*>(&frame));
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to register connection, "
        "failed to write setUpDestIPv4, nic returned: %d\n",
        res);
    return 1;
  }

  // setUpDestPort
  frame = {.data = dest_addr.get_port(), .cmd = setUpDestPort};
  res = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegConnSetupFrame,
                        *reinterpret_cast<uint64_t*>(&frame));
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to register connection, "
        "failed to write setUpDestPort, nic returned: %d\n",
        res);
    return 1;
  }

  // setUpClientFlowId
  frame = {.data = c_flow_id, .cmd = setUpClientFlowId};
  res = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegConnSetupFrame,
                        *reinterpret_cast<uint64_t*>(&frame));
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to register connection, "
        "failed to write setUpClientFlowId, nic returned: %d\n",
        res);
    return 1;
  }

  // setUpEnable
  frame = {.data = 1, .cmd = setUpEnable};
  res = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegConnSetupFrame,
                        *reinterpret_cast<uint64_t*>(&frame));
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to register connection, "
        "failed to write setUpEnable, nic returned: %d\n",
        res);
    return 1;
  }

  // Wait until connection is registered
  ConnSetupStatus* c_setup_status;
  uint64_t raw_status;
  int wait_iteration = 0;
  do {
    res = fpgaReadMMIO64(accel_handle_, 0, base_nic_addr_ + iRegConnStatus,
                         &raw_status);
    if (res != FPGA_OK) {
      FRPC_ERROR(
          "Nic configuration error, failed to register connection, "
          "failed to read status, nic returned: %d\n",
          res);
      return 1;
    }

    c_setup_status = reinterpret_cast<ConnSetupStatus*>(&raw_status);

    ++wait_iteration;
    sleep(NIC_INIT_DELAY_S);
  } while (!(c_setup_status->valid == 1 && c_setup_status->conn_id == c_id) &&
           wait_iteration < NIC_INIT_TIMEOUT);

  if (!(c_setup_status->valid == 1 && c_setup_status->conn_id == c_id)) {
    FRPC_ERROR(
        "Nic configuration error, failed to register connection: timeout "
        "reached\n");
    return 1;
  }

  if (c_setup_status->error_status == cAlreadyOpen) {
    FRPC_ERROR(
        "Nic configuration error, failed to register connection, "
        "connection is already registered on the Nic\n");
    return 1;

  } else if (c_setup_status->error_status == cOK) {
    FRPC_INFO("Connection id=%d is registered\n", c_id);
    return 0;

  } else {
    FRPC_ERROR(
        "Nic configuration error, failed to register connection, "
        "unexpected connection state on the Nic: %d\n",
        c_setup_status->error_status);
    return 1;
  }

  return 0;
}

int NicCCIP::remove_connection(ConnectionId c_id) const {
  assert(connected_ == true);

  std::unique_lock<std::mutex> lck(conn_setup_hw_mtx_);

  fpga_result res;

  // setUpConnId
  ConnSetupFrame frame = {.data = c_id, .cmd = setUpConnId};
  res = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegConnSetupFrame,
                        *reinterpret_cast<uint64_t*>(&frame));
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to remove connection,"
        "failed to write setUpConnId, nic returned: %d\n",
        res);
    return 1;
  }

  // setUpOpen
  frame = {.data = cClose, .cmd = setUpOpen};
  res = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegConnSetupFrame,
                        *reinterpret_cast<uint64_t*>(&frame));
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to remove connection,"
        "failed to write setUpOpen, nic returned: %d\n",
        res);
    return 1;
  }

  // setUpEnable
  frame = {.data = 1, .cmd = setUpEnable};
  res = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegConnSetupFrame,
                        *reinterpret_cast<uint64_t*>(&frame));
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to remove connection, "
        "failed to write setUpEnable, nic returned: %d\n",
        res);
    return 1;
  }

  // Wait until connection is closed
  ConnSetupStatus* c_setup_status;
  uint64_t raw_status;
  int wait_iteration = 0;
  do {
    res = fpgaReadMMIO64(accel_handle_, 0, base_nic_addr_ + iRegConnStatus,
                         &raw_status);
    if (res != FPGA_OK) {
      FRPC_ERROR(
          "Nic configuration error, failed to remove connection, "
          "failed to read status, nic returned: %d\n",
          res);
      return 1;
    }

    c_setup_status = reinterpret_cast<ConnSetupStatus*>(&raw_status);

    ++wait_iteration;
    sleep(NIC_INIT_DELAY_S);
  } while (!(c_setup_status->valid == 1 && c_setup_status->conn_id == c_id) &&
           wait_iteration < NIC_INIT_TIMEOUT);

  if (!(c_setup_status->valid == 1 && c_setup_status->conn_id == c_id)) {
    FRPC_ERROR(
        "Nic configuration error, failed to remove connection: timeout "
        "reached\n");
    return 1;
  }

  if (c_setup_status->error_status == cIsClosed) {
    FRPC_ERROR(
        "Nic configuration error, failed to remove connection, "
        "connection is already removed on the Nic\n");
    return 1;

  } else if (c_setup_status->error_status == cOK) {
    FRPC_INFO("Connection id=%d is removed\n", c_id);
    return 0;

  } else {
    FRPC_ERROR(
        "Nic configuration error, failed to remove connection, "
        "unexpected connection state on the Nic: %d\n",
        c_setup_status->error_status);
    return 1;
  }
}

void NicCCIP::set_lb(int lb) const {
  // setUpOpen
  int res = fpgaWriteMMIO64(accel_handle_, 0, base_nic_addr_ + iRegLb,
                            *reinterpret_cast<uint64_t*>(&lb));
  if (res != FPGA_OK) {
    FRPC_ERROR("Nic configuration error, failed to configure LB %d\n", res);
  }
}

int NicCCIP::get_nic_hw_status(NicHwStatus& status) const {
  assert(connected_ == true);

  NicHwStatus status_;
  uint64_t raw_status = 0;
  fpga_result res = fpgaReadMMIO64(accel_handle_, 0,
                                   base_nic_addr_ + iRegNicStatus, &raw_status);
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to read status register"
        "nic returned: %d\n",
        res);
    return 1;
  }

  status_ =
      *reinterpret_cast<NicHwStatus*>(reinterpret_cast<char*>(&raw_status));

  status = status_;
  return 0;
}

std::string NicCCIP::dump_nic_hw_status(const NicHwStatus& status) const {
  std::string ret;
  ret += " Nic hw status dump >> \n";
  ret += "  nic_id= " + std::to_string(status.nic_id) + "\n";
  ret += "  ready= " + std::to_string(status.ready) + "\n";
  ret += "  running= " + std::to_string(status.running) + "\n";
  ret += "  error= " + std::to_string(status.error) + "\n";
  ret +=
      "  err_rpcRxFifoOvf= " + std::to_string(status.err_rpcRxFifoOvf) + "\n";
  ret +=
      "  err_rpcTxFifoOvf= " + std::to_string(status.err_rpcTxFifoOvf) + "\n";
  ret += "  err_ccip= " + std::to_string(status.err_ccip) + "\n";
  ret += "  err_rpc= " + std::to_string(status.err_rpc) + "\n";

  return ret;
}

void NicCCIP::dump_hssi_stat(int channel) {
  // Print HSSI channel statistics
  int res;
  if (hssi_h_) {
    FRPC_INFO("********* HSSI stat *********\n");
    res = fpgaHssiPrintChannelStats(hssi_h_, PHY, channel);
    assert(res == FPGA_OK);
    res = fpgaHssiPrintChannelStats(hssi_h_, TX, channel);
    assert(res == FPGA_OK);
    res = fpgaHssiPrintChannelStats(hssi_h_, RX, channel);
    assert(res == FPGA_OK);
  }
}

void NicCCIP::get_perf() const {
  assert(connected_ == true);

  uint64_t perf_cnt = 0;
  fpga_result res =
      fpgaReadMMIO64(accel_handle_, 0, base_nic_addr_ + iRegCcipRps, &perf_cnt);
  if (res != FPGA_OK) {
    FRPC_ERROR(
        "Nic configuration error, failed to read performance counter"
        "nic returned: %d\n",
        res);
  }
  FRPC_INFO("Nic #%x returned performance counter(outgoing RPS) = %d\n",
            base_nic_addr_, perf_cnt);
}

void NicCCIP::get_status() const {
  assert(connected_ == true);

  NicHwStatus status;
  int ret = get_nic_hw_status(status);
  if (ret != 0) {
    FRPC_ERROR(
        "NIC configuration error, failed to get status, "
        "NIC returned %d\n",
        ret);
  }
  FRPC_INFO("%s\n", dump_nic_hw_status(status).c_str());
}

void NicCCIP::get_packet_counters(
    void (*callback)(const std::vector<uint64_t>&)) const {
  assert(connected_ == true);

  std::string counters_str;
  std::vector<uint64_t> counters;
  counters_str += "Nic RPC counters dump >> \n";
  for (uint8_t cnt_id = 0; cnt_id < iNumOfPckCnt; ++cnt_id) {
    fpga_result res = fpgaWriteMMIO64(accel_handle_, 0,
                                      base_nic_addr_ + iRegGetPckCnt, cnt_id);
    if (res != FPGA_OK) {
      FRPC_ERROR(
          "Nic configuration error, failed to read packet counters"
          "nic returned: %d\n",
          res);
    }

    // Wait until fpgaWrite propagates and counter is read
    usleep(1000);
    uint64_t pck_cnt = 0;
    res =
        fpgaReadMMIO64(accel_handle_, 0, base_nic_addr_ + iRegPckCnt, &pck_cnt);
    if (res != FPGA_OK) {
      FRPC_ERROR(
          "Nic configuration error, failed to read packet counters"
          "nic returned: %d\n",
          res);
    }
    counters.push_back(pck_cnt);
    counters_str += "  counter[" + std::to_string(cnt_id) +
                    "] = " + std::to_string(pck_cnt) + "\n";
  }
  FRPC_INFO("%s\n", counters_str.c_str());

  // Call the processing callback if required
  if (callback != nullptr) {
    callback(counters);
  }
}

void NicCCIP::get_network_counters() const {
  assert(connected_ == true);

  std::string counters_str;
  counters_str += "Nic network counters dump >> \n";
  if (phy_network_en_) {
    for (uint8_t cnt_id = 0; cnt_id < iNumOfNetworkCnt; ++cnt_id) {
      fpga_result res = fpgaWriteMMIO64(
          accel_handle_, 0, base_nic_addr_ + iRegNetDropCntRead, cnt_id);
      if (res != FPGA_OK) {
        FRPC_ERROR(
            "Nic configuration error, failed to read network counters"
            "nic returned: %d\n",
            res);
      }

      // Wait until fpgaWrite propagates and counter is read
      // TODO: can we do it in a smarter way?
      usleep(1000);
      uint64_t network_cnt = 0;
      res = fpgaReadMMIO64(accel_handle_, 0, base_nic_addr_ + iRegNetDropCnt,
                           &network_cnt);
      if (res != FPGA_OK) {
        FRPC_ERROR(
            "Nic configuration error, failed to read network counters"
            "nic returned: %d\n",
            res);
      }
      counters_str += "  counter[" + std::to_string(cnt_id) +
                      "] = " + std::to_string(network_cnt) + "\n";
    }
  } else {
    counters_str +=
        "  <no physical networking in this build, no network counters"
        " can be read>\n";
  }
  FRPC_INFO("%s\n", counters_str.c_str());
}

void NicCCIP::nic_perf_loop(
    NicPerfMask perf_mask,
    void (*callback)(const std::vector<uint64_t>&)) const {
  while (collect_perf_) {
    if (perf_mask.performance) {
      get_perf();
    }
    if (perf_mask.status) {
      get_status();
    }
    if (perf_mask.packet_counters) {
      get_packet_counters(callback);
    }
    if (perf_mask.network_counters) {
      get_network_counters();
    }

    sleep(NIC_PERF_DELAY_S);
  }
}

size_t NicCCIP::get_page_size() const {
  if (cfg::sys::enable_hugepages)
    return cfg::sys::hugepage_size;
  else
    return getpagesize();
}

size_t NicCCIP::round_up_to_pagesize(size_t val) const {
  size_t page_size_bytes = get_page_size();
  size_t remainder = val % page_size_bytes;
  if (remainder == 0) return val;

  size_t res = val + page_size_bytes - remainder;
  assert(res % page_size_bytes == 0);

  return res;
}

volatile void* NicCCIP::alloc_buffer(fpga_handle accel_handle, ssize_t size,
                                     uint64_t* wsid, uint64_t* io_addr) const {
  fpga_result res;
  volatile void* buf = nullptr;

  int m_flags;
  if (cfg::sys::enable_hugepages) {
    FRPC_INFO("Allocating memory with hugepages\n");
    m_flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB;
  } else {
    FRPC_INFO("Allocating memory with standard pages\n");
    m_flags = MAP_PRIVATE | MAP_ANONYMOUS;
  }

  size_t mem_size = round_up_to_pagesize(size);
  size_t page_size = get_page_size();
  size_t mem_pages = mem_size / page_size;

  if (mem_pages > 1) {
    FRPC_ERROR("Can not correctly support multu-page buffer for now\n");
    return nullptr;
  }

  buf = mmap(NULL, mem_size, PROT_READ | PROT_WRITE, m_flags, -1, 0);
  if (buf == nullptr) return nullptr;

  // fpgaPrepareBuffer only prepares the buffer for a single page per call, so
  // we need to iterate over
  for (size_t i = 0; i < mem_pages; ++i) {
    volatile void* buf_curr = reinterpret_cast<volatile void*>(
        reinterpret_cast<volatile uint8_t*>(buf) + i * page_size);
    res = fpgaPrepareBuffer(accel_handle, page_size,
                            const_cast<void**>(&buf_curr), wsid,
                            FPGA_BUF_PREALLOCATED);
    if (res != FPGA_OK) return nullptr;
  }

  // Get the physical address of the buffer in the accelerator
  // TODO: currentlty, it only works with a single page buffer
  res = fpgaGetIOAddress(accel_handle, *wsid, io_addr);
  assert(res == FPGA_OK);

  return buf;
}

// Taken from Intel Corporation, OPAE example; modified by Nikita
fpga_handle NicCCIP::connect_to_accel(const char* accel_uuid, int bus) const {
  fpga_properties filter = nullptr;
  fpga_guid guid;
  fpga_token accel_token;
  uint32_t num_matches;
  fpga_handle accel_handle;
  fpga_result res;

  // Don't print verbose messages in ASE by default
  setenv("ASE_LOG", "0", 0);

  // Set up a filter that will search for an accelerator
  res = fpgaGetProperties(NULL, &filter);
  assert(res == FPGA_OK);

  res = fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);
  assert(res == FPGA_OK);

  // Add the desired UUID to the filter
  uuid_parse(accel_uuid, guid);
  res = fpgaPropertiesSetGUID(filter, guid);
  assert(res == FPGA_OK);

  // Select bus
  if (bus != -1) {
    res = fpgaPropertiesSetBus(filter, bus);
    if (res != FPGA_OK) {
      FRPC_ERROR("Invalid bus %d\n", bus);
    }
  }

  // Do the search across the available FPGA contexts
  num_matches = 1;
  res = fpgaEnumerate(&filter, 1, &accel_token, 1, &num_matches);
  assert(res == FPGA_OK);

  // Not needed anymore
  res = fpgaDestroyProperties(&filter);
  assert(res == FPGA_OK);

  if (num_matches < 1) {
    FRPC_ERROR("Accelerator %s not found!\n", accel_uuid);
    return 0;
  }

  // Open accelerator
  res = fpgaOpen(accel_token, &accel_handle, FPGA_OPEN_SHARED);
  assert(res == FPGA_OK);

  // Done with token
  res = fpgaDestroyToken(&accel_token);
  assert(res == FPGA_OK);

  // Reset FPGA
  // Do NOT reset when running more than one Nic on the same FPGA or reset
  // in the master Nic
  // TODO: implement reseting by Master Nic
  //    res = fpgaReset(accel_handle);
  //    if (res != FPGA_OK) {
  //        FRPC_ERROR("Failed to reset FPGA\n");
  //        return 0;
  //    }

  return accel_handle;
}

int NicCCIP::initialize_phy_network(int channel) {
  // Open HSSI
  int res = fpgaHssiOpen(accel_handle_, &hssi_h_);
  assert(res == FPGA_OK);
  if (!hssi_h_) {
    FRPC_ERROR("Failed to open HSSI\n");
    return 1;
  }

  // Reset HSSI
  res = fpgaHssiReset(hssi_h_);
  if (res != FPGA_OK) {
    FRPC_ERROR("Failed to reset HSSI\n");
    return 1;
  } else {
    FRPC_INFO("HSSI is reset\n");
  }

  // Disable HSSI loopback
  res = fpgaHssiCtrlLoopback(hssi_h_, channel, false);
  if (res != FPGA_OK) {
    FRPC_ERROR("Failed to disable HSSI loopback\n");
    return 1;
  } else {
    FRPC_INFO("HSSI loopback is disabled\n");
  }

  // Clear HSSI stat
  res = fpgaHssiClearChannelStats(hssi_h_, TX, channel);
  assert(res == FPGA_OK);
  res = fpgaHssiClearChannelStats(hssi_h_, RX, channel);
  assert(res == FPGA_OK);

  return 0;
}

}  // namespace frpc
