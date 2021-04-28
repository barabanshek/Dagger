#include <gtest/gtest.h>

#include <vector>

#include "rpc_server_callback.h"
#include "rpc_threaded_server.h"

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

static uint64_t loopback1(uint64_t a) {
    return a;
}

TEST(ThreadedServerTest, ListenSingleThreadTest) {
    uint64_t max_number_of_threads = 1;

    RpcThreadedServer rpc_server(nic_address, max_number_of_threads);

    int res = rpc_server.init_nic(fpga_bus);
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
    uint64_t max_number_of_threads = 1;

    RpcThreadedServer rpc_server(nic_address, max_number_of_threads);

    int res = rpc_server.init_nic(fpga_bus);
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
    uint64_t max_number_of_threads = 8;

    RpcThreadedServer rpc_server(nic_address, max_number_of_threads);

    int res = rpc_server.init_nic(fpga_bus);
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
    uint64_t max_number_of_threads = 8;

    RpcThreadedServer rpc_server(nic_address, max_number_of_threads);

    int res = rpc_server.init_nic(fpga_bus);
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
