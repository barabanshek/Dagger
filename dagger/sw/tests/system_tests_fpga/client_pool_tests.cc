#include <gtest/gtest.h>

#include "rpc_client.h"
#include "rpc_client_pool.h"

namespace frpc {

TEST(ClientPoolTest, ClientPopTest_1) {
    uint64_t base_nic_addr = 0x000000;
    uint64_t max_pool_size = 1;

    RpcClientPool<RpcClient> rpc_client_pool(base_nic_addr, max_pool_size);

    int res = rpc_client_pool.init_nic();
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

    RpcClientPool<RpcClient> rpc_client_pool(base_nic_addr, max_pool_size);

    int res = rpc_client_pool.init_nic();
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
