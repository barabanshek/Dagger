#include <gtest/gtest.h>

#include <set>
#include <vector>
#include <unordered_set>

#include "rpc_client.h"
#include "rpc_client_pool.h"
#include "rpc_server_callback.h"
#include "rpc_threaded_server.h"

#include <iostream>

static constexpr size_t timeout = 5;
static constexpr uint64_t loopback1_const = 10;

static constexpr uint64_t server_nic_mmio_base = 0x20000;
static constexpr uint64_t client_nic_mmio_base = 0x00000;

class ClientServerTest: public ::testing::Test {
protected:
    ClientServerTest() = default;

    virtual void SetUp(size_t num_of_threads_) {
        num_of_threads = num_of_threads_;
        server = std::unique_ptr<frpc::RpcThreadedServer>(
                    new frpc::RpcThreadedServer(server_nic_mmio_base, num_of_threads));
        client_pool = std::unique_ptr<frpc::RpcClientPool<frpc::RpcClient>>(
                        new frpc::RpcClientPool<frpc::RpcClient>(client_nic_mmio_base, num_of_threads));

        // Setup server
        int res = server->init_nic();
        ASSERT_EQ(res, 0);

        res = server->start_nic();
        ASSERT_EQ(res, 0);

        fn_ptr.push_back(reinterpret_cast<const void*>(&ClientServerTest::loopback1));
        fn_ptr.push_back(reinterpret_cast<const void*>(&ClientServerTest::loopback2));
        fn_ptr.push_back(reinterpret_cast<const void*>(&ClientServerTest::loopback3));
        server_callback = std::unique_ptr<frpc::RpcServerCallBack>(
                                                new frpc::RpcServerCallBack(fn_ptr));

        for(int i=0; i<num_of_threads; ++i) {
            res = server->run_new_listening_thread(server_callback.get());
            ASSERT_EQ(res, 0);
        }

        // Open-up connections
        frpc::IPv4 client_addr("192.168.0.2", 3136);
        ASSERT_EQ(server->connect(client_addr, 0, 0), 0);

        // Setup clients
        res = client_pool->init_nic();
        ASSERT_EQ(res, 0);

        res = client_pool->start_nic();
        ASSERT_EQ(res, 0);
    }

    virtual void TearDown() override {
        // Shutdown server
        int res = server->stop_all_listening_threads();
        ASSERT_EQ(res, 0);

        res = server->stop_nic();
        ASSERT_EQ(res, 0);

        res = server->check_hw_errors();
        ASSERT_EQ(res, 0);

        // Shutdown clients
        res = client_pool->stop_nic();
        ASSERT_EQ(res, 0);

        res = client_pool->check_hw_errors();
        ASSERT_EQ(res, 0);
    }

    // RPC functions
    static uint64_t loopback1(uint64_t a) {
        return a + loopback1_const;
    }

    static uint64_t loopback2(uint64_t a, uint64_t b, uint64_t c, uint64_t d) {
        return a + b + c + d;
    }

    static uint64_t loopback3(uint8_t a, uint16_t b, uint32_t c, uint64_t d) {
        return a*b + c*d;
    }

    size_t num_of_threads;

    std::unique_ptr<frpc::RpcThreadedServer> server;
    std::vector<const void*> fn_ptr;
    std::unique_ptr<frpc::RpcServerCallBack> server_callback;

    std::unique_ptr<frpc::RpcClientPool<frpc::RpcClient>> client_pool;

};

TEST_F(ClientServerTest, SingleLoopback1CallTest) {
    SetUp(1);

    auto c = client_pool->pop();
    ASSERT_NE(c, nullptr);

    auto cq = c->get_completion_queue();
    ASSERT_NE(cq, nullptr);

    // Open connection
    frpc::IPv4 server_addr("192.168.0.1", 3136);
    int res = c->connect(server_addr, 0);
    ASSERT_EQ(res, 0);

    // Make a call
    c->loopback1(12);

    // Wait
    size_t t_out_cnt = 0;
    while(cq->get_number_of_completed_requests() == 0 && t_out_cnt < timeout) {
        sleep(1);
        ++t_out_cnt;
    }
    ASSERT_EQ(cq->get_number_of_completed_requests(), 1);

    // Check result
    uint64_t ret_val = *reinterpret_cast<uint64_t*>(cq->pop_response().argv);
    EXPECT_EQ(ret_val, 12 + loopback1_const);
}

TEST_F(ClientServerTest, MultipleLoopback1CallTest) {
    SetUp(1);

    constexpr size_t num_of_it = 100;
    constexpr size_t num_of_wait_us = 100;

    auto c = client_pool->pop();
    ASSERT_NE(c, nullptr);

    auto cq = c->get_completion_queue();
    ASSERT_NE(cq, nullptr);

    // Open connection
    frpc::IPv4 server_addr("192.168.0.1", 3136);
    int res = c->connect(server_addr, 0);
    ASSERT_EQ(res, 0);

    // Make calls
    std::unordered_set<int> expected;
    for(int i=0; i<num_of_it; ++i) {
        c->loopback1(i);
        expected.insert(i + loopback1_const);
        usleep(num_of_wait_us);
    }

    // Wait
    size_t t_out_cnt = 0;
    while(cq->get_number_of_completed_requests() < num_of_it &&
          t_out_cnt < timeout) {
        sleep(1);
        ++t_out_cnt;
    }
    ASSERT_EQ(cq->get_number_of_completed_requests(), num_of_it);

    // Check result
    size_t num_of_errors = 0;
    for(int i=0; i<num_of_it; ++i) {
        uint64_t ret_val = *reinterpret_cast<uint64_t*>(
                                            cq->pop_response().argv);
        auto it = expected.find(ret_val);
        if (it == expected.end()) {
            ++num_of_errors;
        } else {
            expected.erase(it);
        }
    }
    EXPECT_EQ(num_of_errors, 0);
    EXPECT_EQ(expected.size(), 0);
}

TEST_F(ClientServerTest, SingleLoopBack2CallTest) {
    SetUp(1);

    auto c = client_pool->pop();
    ASSERT_NE(c, nullptr);

    auto cq = c->get_completion_queue();
    ASSERT_NE(cq, nullptr);

    // Open connection
    frpc::IPv4 server_addr("192.168.0.1", 3136);
    int res = c->connect(server_addr, 0);
    ASSERT_EQ(res, 0);

    // Make a call
    c->loopback2(1, 2, 3, 4);

    // Wait
    size_t t_out_cnt = 0;
    while(cq->get_number_of_completed_requests() == 0 && t_out_cnt < timeout) {
        sleep(1);
        ++t_out_cnt;
    }
    ASSERT_EQ(cq->get_number_of_completed_requests(), 1);

    // Check result
    uint64_t ret_val = *reinterpret_cast<uint64_t*>(cq->pop_response().argv);
    EXPECT_EQ(ret_val, 10);
}

TEST_F(ClientServerTest, MultipleLoopback2CallTest) {
    SetUp(1);

    constexpr size_t num_of_it = 100;
    constexpr size_t num_of_wait_us = 100;

    auto c = client_pool->pop();
    ASSERT_NE(c, nullptr);

    auto cq = c->get_completion_queue();
    ASSERT_NE(cq, nullptr);

    // Open connection
    frpc::IPv4 server_addr("192.168.0.1", 3136);
    int res = c->connect(server_addr, 0);
    ASSERT_EQ(res, 0);

    // Make calls
    std::unordered_set<int> expected;
    for(int i=0; i<num_of_it; ++i) {
        c->loopback2(i, 10, i+1, i+2);
        expected.insert(i + 10 + i+1 + i+2);
        usleep(num_of_wait_us);
    }

    // Wait
    size_t t_out_cnt = 0;
    while(cq->get_number_of_completed_requests() < num_of_it &&
          t_out_cnt < timeout) {
        sleep(1);
        ++t_out_cnt;
    }
    ASSERT_EQ(cq->get_number_of_completed_requests(), num_of_it);

    // Check result
    size_t num_of_errors = 0;
    for(int i=0; i<num_of_it; ++i) {
        uint64_t ret_val = *reinterpret_cast<uint64_t*>(
                                            cq->pop_response().argv);
        auto it = expected.find(ret_val);
        if (it == expected.end()) {
            ++num_of_errors;
        } else {
            expected.erase(it);
        }
    }
    EXPECT_EQ(num_of_errors, 0);
    EXPECT_EQ(expected.size(), 0);
}

TEST_F(ClientServerTest, MixedCallTest) {
    SetUp(1);

    constexpr size_t num_of_it = 100;
    constexpr size_t num_of_wait_us = 100;

    auto c = client_pool->pop();
    ASSERT_NE(c, nullptr);

    auto cq = c->get_completion_queue();
    ASSERT_NE(cq, nullptr);

    // Open connection
    frpc::IPv4 server_addr("192.168.0.1", 3136);
    int res = c->connect(server_addr, 0);
    ASSERT_EQ(res, 0);

    // Make calls
    std::multiset<uint64_t> expected;
    for(int i=0; i<num_of_it; ++i) {
        switch (i%3) {
            case 0: {
                c->loopback1(i);
                expected.insert(i + loopback1_const);
                break;
            }
            case 1: {
                c->loopback2(i, 10, i+1, i+2);
                expected.insert(i + 10 + i+1 + i+2);
                break;
            }
            case 2: {
                c->loopback3(i+1, i+2, i+3, 2);
                expected.insert((i+1)*(i+2) + (i+3)*2);
                break;
            }
        }

        usleep(num_of_wait_us);
    }

    // Wait
    size_t t_out_cnt = 0;
    while(cq->get_number_of_completed_requests() < num_of_it &&
          t_out_cnt < timeout) {
        sleep(1);
        ++t_out_cnt;
    }
    ASSERT_EQ(cq->get_number_of_completed_requests(), num_of_it);

    // Check result
    size_t num_of_errors = 0;
    for(int i=0; i<num_of_it; ++i) {
        uint64_t ret_val = *reinterpret_cast<uint64_t*>(
                                            cq->pop_response().argv);
        auto it = expected.find(ret_val);
        if (it == expected.end()) {
            ++num_of_errors;
        } else {
            expected.erase(it);
        }
    }
    EXPECT_EQ(num_of_errors, 0);
    EXPECT_EQ(expected.size(), 0);
}
