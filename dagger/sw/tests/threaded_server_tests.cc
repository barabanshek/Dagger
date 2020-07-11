#include <gtest/gtest.h>

#include "rpc_threaded_server.h"

#include <vector>

namespace frpc {

static uint32_t foo(uint32_t a, uint32_t b) {
    return a + b;
}

static uint32_t boo(uint32_t a) {
    return a + 10;
}

static uint32_t moo(uint32_t a) {
    return a + 20;
}

TEST(ThreadedServerTest, ListenTest_1_Thread) {
    uint64_t base_nic_addr = 0x000000;
    uint64_t max_number_of_threads = 1;

    RpcThreadedServer rpc_server(base_nic_addr, max_number_of_threads);

    int res = rpc_server.init_nic();
    EXPECT_EQ(res, 0);

    res = rpc_server.start_nic();
    EXPECT_EQ(res, 0);

    res = rpc_server.check_hw_errors();
    EXPECT_EQ(res, 0);

    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(&foo));
    fn_ptr.push_back(reinterpret_cast<const void*>(&boo));
    res = rpc_server.run_new_listening_thread(fn_ptr);
    EXPECT_EQ(res, 0);

    sleep(1);

    res = rpc_server.stop_all_listening_threads();
    EXPECT_EQ(res, 0);

    res = rpc_server.stop_nic();
    EXPECT_EQ(res, 0);

    res = rpc_server.check_hw_errors();
    EXPECT_EQ(res, 0);
}

TEST(ThreadedServerTest, ListenTest_1_Thread_2_Requested) {
    uint64_t base_nic_addr = 0x000000;
    uint64_t max_number_of_threads = 1;

    RpcThreadedServer rpc_server(base_nic_addr, max_number_of_threads);

    int res = rpc_server.init_nic();
    EXPECT_EQ(res, 0);

    res = rpc_server.start_nic();
    EXPECT_EQ(res, 0);

    res = rpc_server.check_hw_errors();
    EXPECT_EQ(res, 0);

    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(&foo));
    fn_ptr.push_back(reinterpret_cast<const void*>(&boo));
    fn_ptr.push_back(reinterpret_cast<const void*>(&moo));
    res = rpc_server.run_new_listening_thread(fn_ptr);
    EXPECT_EQ(res, 0);

    res = rpc_server.run_new_listening_thread(fn_ptr);
    EXPECT_EQ(res, 1);

    sleep(1);

    res = rpc_server.stop_all_listening_threads();
    EXPECT_EQ(res, 0);

    res = rpc_server.stop_nic();
    EXPECT_EQ(res, 0);

    res = rpc_server.check_hw_errors();
    EXPECT_EQ(res, 0);
}

TEST(ThreadedServerTest, ListenTest_8_Threads) {
    uint64_t base_nic_addr = 0x000000;
    uint64_t max_number_of_threads = 8;

    RpcThreadedServer rpc_server(base_nic_addr, max_number_of_threads);

    int res = rpc_server.init_nic();
    EXPECT_EQ(res, 0);

    res = rpc_server.start_nic();
    EXPECT_EQ(res, 0);

    res = rpc_server.check_hw_errors();
    EXPECT_EQ(res, 0);

    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(&foo));
    fn_ptr.push_back(reinterpret_cast<const void*>(&boo));

    for (int i=0; i<8; ++i) {
        res = rpc_server.run_new_listening_thread(fn_ptr);
        EXPECT_EQ(res, 0);
    }

    sleep(1);

    res = rpc_server.stop_all_listening_threads();
    EXPECT_EQ(res, 0);

    res = rpc_server.stop_nic();
    EXPECT_EQ(res, 0);

    res = rpc_server.check_hw_errors();
    EXPECT_EQ(res, 0);
}

TEST(ThreadedServerTest, ListenTest_8_Threads_Start_Stop) {
    uint64_t base_nic_addr = 0x000000;
    uint64_t max_number_of_threads = 8;

    RpcThreadedServer rpc_server(base_nic_addr, max_number_of_threads);

    int res = rpc_server.init_nic();
    EXPECT_EQ(res, 0);

    res = rpc_server.start_nic();
    EXPECT_EQ(res, 0);

    res = rpc_server.check_hw_errors();
    EXPECT_EQ(res, 0);

    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(&foo));
    fn_ptr.push_back(reinterpret_cast<const void*>(&boo));
    fn_ptr.push_back(reinterpret_cast<const void*>(&moo));

    for (int i=0; i<8; ++i) {
        res = rpc_server.run_new_listening_thread(fn_ptr);
        EXPECT_EQ(res, 0);
    }

    res = rpc_server.run_new_listening_thread(fn_ptr);
    EXPECT_EQ(res, 1);

    sleep(1);

    res = rpc_server.stop_all_listening_threads();
    EXPECT_EQ(res, 0);

    res = rpc_server.check_hw_errors();
    EXPECT_EQ(res, 0);

    for (int i=0; i<2; ++i) {
        res = rpc_server.run_new_listening_thread(fn_ptr);
        EXPECT_EQ(res, 0);
    }

    sleep(1);

    res = rpc_server.stop_all_listening_threads();
    EXPECT_EQ(res, 0);

    res = rpc_server.stop_nic();
    EXPECT_EQ(res, 0);

    res = rpc_server.check_hw_errors();
    EXPECT_EQ(res, 0);
}

}  // namespace frpc
