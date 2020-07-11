#include <gtest/gtest.h>

#include <memory>

#include "nic.h"
#include "nic_ccip_polling.h"

namespace frpc {

TEST(NicTest, StartStopTest_1_Flow) {
    uint64_t base_nic_addr = 0x000000;
    uint64_t num_of_flows = 1;

    std::unique_ptr<Nic> nic(new NicPollingCCIP(base_nic_addr, num_of_flows, true));

    int res = nic->connect_to_nic();
    EXPECT_EQ(res, 0);

    res = nic->check_hw_errors();
    EXPECT_EQ(res, 0);

    res = nic->initialize_nic();
    EXPECT_EQ(res, 0);

    res = nic->check_hw_errors();
    EXPECT_EQ(res, 0);

    res = nic->configure_data_plane();
    EXPECT_EQ(res, 0);

    res = nic->check_hw_errors();
    EXPECT_EQ(res, 0);

    res = nic->start();
    EXPECT_EQ(res, 0);

    res = nic->check_hw_errors();
    EXPECT_EQ(res, 0);

    sleep(1);

    res = nic->check_hw_errors();
    EXPECT_EQ(res, 0);

    res = nic->stop();
    EXPECT_EQ(res, 0);

    res = nic->check_hw_errors();
    EXPECT_EQ(res, 0);
}

TEST(NicTest, StartStopTest_8_Flows) {
    uint64_t base_nic_addr = 0x000000;
    uint64_t num_of_flows = 8;

    std::unique_ptr<Nic> nic(new NicPollingCCIP(base_nic_addr, num_of_flows, true));

    int res = nic->connect_to_nic();
    EXPECT_EQ(res, 0);

    res = nic->check_hw_errors();
    EXPECT_EQ(res, 0);

    res = nic->initialize_nic();
    EXPECT_EQ(res, 0);

    res = nic->check_hw_errors();
    EXPECT_EQ(res, 0);

    res = nic->configure_data_plane();
    EXPECT_EQ(res, 0);

    res = nic->check_hw_errors();
    EXPECT_EQ(res, 0);

    res = nic->start();
    EXPECT_EQ(res, 0);

    res = nic->check_hw_errors();
    EXPECT_EQ(res, 0);

    sleep(1);

    res = nic->check_hw_errors();
    EXPECT_EQ(res, 0);

    res = nic->stop();
    EXPECT_EQ(res, 0);

    res = nic->check_hw_errors();
    EXPECT_EQ(res, 0);
}

}  // namespace frpc
