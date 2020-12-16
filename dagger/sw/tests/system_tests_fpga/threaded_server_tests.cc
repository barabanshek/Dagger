#include <gtest/gtest.h>

#include <vector>

#include "rpc_server_callback.h"
#include "rpc_threaded_server.h"

namespace frpc {

static uint64_t loopback1(uint64_t a) {
    return a;
}

TEST(ThreadedServerTest, ListenSingleThreadTest) {
    uint64_t base_nic_addr = 0x000000;
    uint64_t max_number_of_threads = 1;

    RpcThreadedServer rpc_server(base_nic_addr, max_number_of_threads);

    int res = rpc_server.init_nic();
    ASSERT_EQ(res, 0);

    res = rpc_server.start_nic();
    ASSERT_EQ(res, 0);

    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(&loopback1));
    frpc::RpcServerCallBack server_callback(fn_ptr);

    res = rpc_server.run_new_listening_thread(&server_callback);
    EXPECT_EQ(res, 0);

    // Run for a bit
    sleep(1);

    res = rpc_server.stop_all_listening_threads();
    EXPECT_EQ(res, 0);

    res = rpc_server.stop_nic();
    ASSERT_EQ(res, 0);

    res = rpc_server.check_hw_errors();
    EXPECT_EQ(res, 0);
}

TEST(ThreadedServerTest, ListenSingleThreadTwoRequestedTest) {
    uint64_t base_nic_addr = 0x000000;
    uint64_t max_number_of_threads = 1;

    RpcThreadedServer rpc_server(base_nic_addr, max_number_of_threads);

    int res = rpc_server.init_nic();
    ASSERT_EQ(res, 0);

    res = rpc_server.start_nic();
    ASSERT_EQ(res, 0);

    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(&loopback1));
    frpc::RpcServerCallBack server_callback(fn_ptr);

    res = rpc_server.run_new_listening_thread(&server_callback);
    EXPECT_EQ(res, 0);

    res = rpc_server.run_new_listening_thread(&server_callback);
    EXPECT_EQ(res, 1);

    // Run for a bit
    sleep(1);

    res = rpc_server.stop_all_listening_threads();
    EXPECT_EQ(res, 0);

    res = rpc_server.stop_nic();
    ASSERT_EQ(res, 0);

    res = rpc_server.check_hw_errors();
    EXPECT_EQ(res, 0);
}

TEST(ThreadedServerTest, ListenMultipleThreadsTest) {
    uint64_t base_nic_addr = 0x000000;
    uint64_t max_number_of_threads = 8;

    RpcThreadedServer rpc_server(base_nic_addr, max_number_of_threads);

    int res = rpc_server.init_nic();
    ASSERT_EQ(res, 0);

    res = rpc_server.start_nic();
    ASSERT_EQ(res, 0);

    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(&loopback1));
    frpc::RpcServerCallBack server_callback(fn_ptr);

    for (int i=0; i<8; ++i) {
        res = rpc_server.run_new_listening_thread(&server_callback);
        EXPECT_EQ(res, 0);
    }

    // Run for a bit
    sleep(1);

    res = rpc_server.stop_all_listening_threads();
    EXPECT_EQ(res, 0);

    res = rpc_server.stop_nic();
    ASSERT_EQ(res, 0);

    res = rpc_server.check_hw_errors();
    EXPECT_EQ(res, 0);
}

TEST(ThreadedServerTest, ListenMultipleThreadsStartStopTest) {
    uint64_t base_nic_addr = 0x000000;
    uint64_t max_number_of_threads = 8;

    RpcThreadedServer rpc_server(base_nic_addr, max_number_of_threads);

    int res = rpc_server.init_nic();
    ASSERT_EQ(res, 0);

    res = rpc_server.start_nic();
    ASSERT_EQ(res, 0);

    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(&loopback1));
    frpc::RpcServerCallBack server_callback(fn_ptr);

    for (int i=0; i<8; ++i) {
        res = rpc_server.run_new_listening_thread(&server_callback);
        EXPECT_EQ(res, 0);
    }

    res = rpc_server.run_new_listening_thread(&server_callback);
    EXPECT_EQ(res, 1);

    // Run for a bit
    sleep(1);

    res = rpc_server.stop_all_listening_threads();
    EXPECT_EQ(res, 0);

    res = rpc_server.check_hw_errors();
    EXPECT_EQ(res, 0);

    for (int i=0; i<2; ++i) {
        res = rpc_server.run_new_listening_thread(&server_callback);
        EXPECT_EQ(res, 0);
    }

    // Run for a bit
    sleep(1);

    res = rpc_server.stop_all_listening_threads();
    EXPECT_EQ(res, 0);

    res = rpc_server.stop_nic();
    ASSERT_EQ(res, 0);

    res = rpc_server.check_hw_errors();
    EXPECT_EQ(res, 0);
}

}  // namespace frpc
