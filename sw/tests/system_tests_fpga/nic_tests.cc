#include <gtest/gtest.h>

#include <memory>

#include "nic.h"
#include "nic_ccip_polling.h"

// HW parameters
#ifdef PLATFORM_PAC_A10
#  ifdef NIC_PHY_NETWORK
// Allocate FPGA on bus_1 for the client when running on PAC_A10 with physical
// networking
static constexpr int fpga_bus = frpc::cfg::platform::pac_a10_fpga_bus_1;

// If physical networking, running on different FPGAs, so NIC is placed by
// 0x20000 for both client and server
static constexpr uint64_t nic_address = 0x20000;

#  else
// Allocate FPGA on bus_1 for the client when running on PAC_A10 with loopback
// networking
static constexpr int fpga_bus = frpc::cfg::platform::pac_a10_fpga_bus_1;

// If loopback, running on the same FPGA, so NIC is placed by 0x00000 for client
// and 0x20000 for server
static constexpr uint64_t nic_address = 0x00000;

#  endif
#else
// Only loopback is possible here, so -1 for bus and 0x00000 for address
static constexpr int fpga_bus = -1;
static constexpr uint64_t nic_address = 0x00000;

#endif

namespace frpc {

class NicTests : public ::testing::Test {
 protected:
  virtual void SetUp() override {
    uint64_t num_of_flows = 1;

    auto nic_ = std::unique_ptr<frpc::Nic>(
        new frpc::NicPollingCCIP(nic_address, num_of_flows, true));
    nic = std::move(nic_);

    int res = nic->connect_to_nic(fpga_bus);
    ASSERT_EQ(res, 0);

    PhyAddr cl_phy_addr = {0x1A, 0x2B, 0x3C, 0x4D, 0x5E, 0x6D};
    IPv4 cl_ipv4_addr("192.168.0.1", 0);
    res = nic->initialize_nic(cl_phy_addr, cl_ipv4_addr);
    ASSERT_EQ(res, 0);

    res = nic->configure_data_plane();
    ASSERT_EQ(res, 0);

    res = nic->start();
    ASSERT_EQ(res, 0);

    res = nic->check_hw_errors();
    EXPECT_EQ(res, 0);
  }

  virtual void TearDown() override {
    int res = nic->check_hw_errors();
    EXPECT_EQ(res, 0);

    res = nic->stop();
    ASSERT_EQ(res, 0);
  }

  std::unique_ptr<frpc::Nic> nic;
};

TEST_F(NicTests, OpenCloseConnectionTest) {
  ConnectionId c_id;
  ConnectionFlowId c_f_id = 2;
  frpc::IPv4 c_addr("192.168.0.1", 3136);

  // Open connection
  int res = nic->open_connection(c_id, c_addr, c_f_id);
  EXPECT_EQ(res, 0);
  EXPECT_EQ(c_id, 0);

  // Close connection
  res = nic->close_connection(c_id);
  EXPECT_EQ(res, 0);
}

TEST_F(NicTests, OpenCloseMultipleConnectionsWithSameFlowTest) {
  ConnectionId c_id;
  ConnectionFlowId c_f_id = 2;
  frpc::IPv4 c_addr("192.168.0.1", 3136);

  // Open connections
  for (int i = 0; i < 4; ++i) {
    int res = nic->open_connection(c_id, c_addr, c_f_id);
    EXPECT_EQ(res, 0);
    EXPECT_EQ(c_id, i);
  }

  // Close connections
  for (int i = 0; i < 4; ++i) {
    int res = nic->close_connection(i);
    EXPECT_EQ(res, 0);
  }
}

TEST_F(NicTests, OpenCloseMultipleConnectionsWithDifferentFlowTest) {
  ConnectionId c_id;
  ConnectionFlowId c_f_id = 2;
  frpc::IPv4 c_addr("192.168.0.1", 3136);

  // Open connections
  for (int i = 0; i < 4; ++i) {
    int res = nic->open_connection(c_id, c_addr, i);
    EXPECT_EQ(res, 0);
    EXPECT_EQ(c_id, i);
  }

  // Close connections
  for (int i = 0; i < 4; ++i) {
    int res = nic->close_connection(i);
    EXPECT_EQ(res, 0);
  }
}

TEST_F(NicTests, AddCloseConnectionTest) {
  ConnectionId c_id = 1;
  ConnectionFlowId c_f_id = 2;
  frpc::IPv4 c_addr("192.168.0.1", 3136);

  // Add connection
  int res = nic->add_connection(c_id, c_addr, c_f_id);
  EXPECT_EQ(res, 0);

  // Close connection
  res = nic->close_connection(c_id);
  EXPECT_EQ(res, 0);
}

TEST_F(NicTests, ErroneousOpenConnectionsTest) {
  ConnectionId c_id = 999999;
  ConnectionFlowId c_f_id = 2;
  frpc::IPv4 c_addr("192.168.0.1", 3136);

  // Add connection
  int res = nic->add_connection(c_id, c_addr, c_f_id);
  EXPECT_EQ(res, 1);
}

TEST_F(NicTests, ErroneousCloseConnectionsTest) {
  ConnectionId c_id;
  ConnectionFlowId c_f_id = 2;
  frpc::IPv4 c_addr("192.168.0.1", 3136);

  // Open connection
  int res = nic->open_connection(c_id, c_addr, c_f_id);
  EXPECT_EQ(res, 0);
  EXPECT_EQ(c_id, 0);

  // Close connection
  res = nic->close_connection(1);
  EXPECT_EQ(res, 1);
}

TEST_F(NicTests, ErroneousAddConnectionsTest) {
  ConnectionId c_id = 0;
  ConnectionFlowId c_f_id = 2;
  frpc::IPv4 c_addr("192.168.0.1", 3136);

  // Open connection
  int res = nic->add_connection(c_id, c_addr, c_f_id);
  EXPECT_EQ(res, 0);

  res = nic->add_connection(c_id, c_addr, c_f_id);
  EXPECT_EQ(res, 1);

  res = nic->close_connection(c_id);
  EXPECT_EQ(res, 0);

  res = nic->add_connection(c_id, c_addr, c_f_id);
  EXPECT_EQ(res, 0);
}

}  // namespace frpc
