#include <gtest/gtest.h>

#include "rpc_client.h"
#include "rpc_client_pool.h"

// HW parameters
#ifdef PLATFORM_PAC_A10
    #ifdef NIC_PHY_NETWORK
        // Allocate FPGA on bus_1 for the client when running on PAC_A10 with physical networking
        static constexpr int fpga_bus = frpc::cfg::platform::pac_a10_fpga_bus_1;

        // If physical networking, running on different FPGAs, so NIC is placed by 0x20000
        // for both client and server
        static constexpr uint64_t nic_address = 0x20000;

    #else
        // Allocate FPGA on bus_1 for the client when running on PAC_A10 with loopback networking
        static constexpr int fpga_bus = frpc::cfg::platform::pac_a10_fpga_bus_1;

        // If loopback, running on the same FPGA, so NIC is placed by 0x00000 for client
        // and 0x20000 for server
        static constexpr uint64_t nic_address = 0x00000;

    #endif
#else
    // Only loopback is possible here, so -1 for bus and 0x00000 for address
    static constexpr int fpga_bus = -1;
    static constexpr uint64_t nic_address = 0x00000;

#endif

namespace frpc {

TEST(ClientPoolTest, ClientPopTest_1) {
    uint64_t base_nic_addr = 0x000000;
    uint64_t max_pool_size = 1;

    RpcClientPool<RpcClient> rpc_client_pool(nic_address, max_pool_size);

    int res = rpc_client_pool.init_nic(fpga_bus);
    ASSERT_EQ(res, 0);

    res = rpc_client_pool.start_nic();
    ASSERT_EQ(res, 0);

    auto rpc_client = rpc_client_pool.pop();
    EXPECT_TRUE(rpc_client != nullptr);

    rpc_client = rpc_client_pool.pop();
    EXPECT_TRUE(rpc_client == nullptr);

    res = rpc_client_pool.stop_nic();
    ASSERT_EQ(res, 0);
}

TEST(ClientPoolTest, ClientPopTest_2) {
    uint64_t base_nic_addr = 0x000000;
    uint64_t max_pool_size = 2;

    RpcClientPool<RpcClient> rpc_client_pool(nic_address, max_pool_size);

    int res = rpc_client_pool.init_nic(fpga_bus);
    ASSERT_EQ(res, 0);

    res = rpc_client_pool.start_nic();
    ASSERT_EQ(res, 0);

    auto rpc_client = rpc_client_pool.pop();
    EXPECT_TRUE(rpc_client != nullptr);

    rpc_client = rpc_client_pool.pop();
    EXPECT_TRUE(rpc_client != nullptr);

    rpc_client = rpc_client_pool.pop();
    EXPECT_TRUE(rpc_client == nullptr);

    res = rpc_client_pool.stop_nic();
    ASSERT_EQ(res, 0);
}


}  // namespace frpc
