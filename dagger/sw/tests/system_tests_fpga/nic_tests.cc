#include <gtest/gtest.h>

#include <memory>

#include "nic.h"
#include "nic_ccip_polling.h"

namespace frpc {

class NicTests: public ::testing::Test {
protected:
    virtual void SetUp() override {
        uint64_t base_nic_addr = 0x000000;
        uint64_t num_of_flows = 1;

        auto nic_ = std::unique_ptr<frpc::Nic>(new frpc::NicPollingCCIP
                                        (base_nic_addr, num_of_flows, true));
        nic = std::move(nic_);

        int res = nic->connect_to_nic();
        ASSERT_EQ(res, 0);

        res = nic->initialize_nic();
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
    for(int i=0; i<4; ++i) {
        int res = nic->open_connection(c_id, c_addr, c_f_id);
        EXPECT_EQ(res, 0);
        EXPECT_EQ(c_id, i);
    }

    // Close connections
    for(int i=0; i<4; ++i) {
        int res = nic->close_connection(i);
        EXPECT_EQ(res, 0);
    }
}

TEST_F(NicTests, OpenCloseMultipleConnectionsWithDifferentFlowTest) {
    ConnectionId c_id;
    ConnectionFlowId c_f_id = 2;
    frpc::IPv4 c_addr("192.168.0.1", 3136);

    // Open connections
    for(int i=0; i<4; ++i) {
        int res = nic->open_connection(c_id, c_addr, i);
        EXPECT_EQ(res, 0);
        EXPECT_EQ(c_id, i);
    }

    // Close connections
    for(int i=0; i<4; ++i) {
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
