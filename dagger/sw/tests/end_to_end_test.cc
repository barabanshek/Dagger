#include <gtest/gtest.h>

#include "rpc_client.h"
#include "rpc_client_nonblocking.h"
#include "rpc_client_pool.h"
#include "rpc_threaded_server.h"

#include <future>
#include <vector>

namespace frpc {

static uint32_t foo(uint32_t a, uint32_t b) {
    return a + b;
}

static uint32_t boo(uint32_t a) {
    return a + 20;
}

#define SERVER_NIC_ADDR 0x20000

static int run_server(std::promise<int> && p, int num_of_threads) {
    frpc::RpcThreadedServer server(SERVER_NIC_ADDR, num_of_threads);

    // Init
    int res = server.init_nic();
    if (res != 0) {
        p.set_value(res);
        return 1;
    }

    // Start server
    res = server.start_nic();
    if (res != 0) {
        p.set_value(res);
        return 1;
    }

    // Register RPC functions
    std::vector<const void*> fn_ptr;
    fn_ptr.push_back(reinterpret_cast<const void*>(&foo));
    fn_ptr.push_back(reinterpret_cast<const void*>(&boo));

    for (int i=0; i<num_of_threads; ++i) {
        res = server.run_new_listening_thread(fn_ptr);
        if (res != 0) {
            p.set_value(res);
            return 1;
        }
    }

    sleep(5); // Run server for 10 sec
    res = server.stop_all_listening_threads();
    if (res != 0) {
        p.set_value(res);
        return 1;
    }

    // Stop NIC
    res = server.stop_nic();
    if (res != 0) {
        p.set_value(res);
        return 1;
    }

    p.set_value(0);
    return 0;
}

#define CLIENT_NIC_ADDR 0x00000

static int run_client_thread(std::promise<int> && p,
                             frpc::RpcClient* rpc_client,
                             int num_of_requests,
                             int function_id,
                             int first_value) {
    // Make an RPC call
    int results[num_of_requests];
    for (int i=0; i<num_of_requests; ++i) {
        if (function_id == 0)
            results[i] = rpc_client->foo(first_value + i, first_value + i + 1);
        else
            results[i] = rpc_client->boo(first_value + i);
    }

    for (int i=0; i<num_of_requests; ++i) {
        int expected = 0;
        if (function_id == 0)
            expected = first_value + i + first_value + i + 1;
        else
            expected = first_value + i + 20;

        if (results[i] != expected) {
            std::cout << "client verification failed for element: "
                      << i << ": "
                      << results[i] << " != " << expected << std::endl;
            p.set_value(1);
            return 1;
        }
    }

    p.set_value(0);
    return 0;
}

static int run_client(std::promise<int> && p,
                      int num_of_threads,
                      int num_of_requests,
                      int function_id) {
    frpc::RpcClientPool<frpc::RpcClient> rpc_client_pool(CLIENT_NIC_ADDR, num_of_threads);

    // Init client pool
    int res = rpc_client_pool.init_nic();
    if (res != 0) {
        p.set_value(res);
        return 1;
    }

    // Start NIC
    res = rpc_client_pool.start_nic();
    if (res != 0) {
        p.set_value(res);
        return 1;
    }

    std::vector<std::promise<int>> ps;
    std::vector<std::future<int>> fs;
    std::vector<std::thread> ths;
    for (int i=0; i<num_of_threads; ++i) {
        // Get client
        frpc::RpcClient* rpc_client = rpc_client_pool.pop();
        if (rpc_client == nullptr) {
            p.set_value(1);
            return 1;
        }

        // Run thread
        std::promise<int> promise;
        auto future = promise.get_future();
        std::thread client_thread = std::thread(&run_client_thread,
                                                std::move(promise),
                                                rpc_client,
                                                num_of_requests,
                                                function_id,
                                                (i+1)*100);

        ps.push_back(std::move(promise));
        fs.push_back(std::move(future));
        ths.push_back(std::move(client_thread));
    }

    for (auto& thread: ths) {
        thread.join();
    }

    for (auto& future: fs) {
        if (future.get() != 0) {
            p.set_value(1);
            return 1;
        }
    }

    // Check for HW errors
    res = rpc_client_pool.check_hw_errors();
    if (res != 0) {
        std::cout << "HW errors found, check error log" << std::endl;
        p.set_value(res);
        return 1;
    }

    // Stop NIC
    res = rpc_client_pool.stop_nic();
    if (res != 0) {
        p.set_value(res);
        return 1;
    }

    p.set_value(0);
    return 0;
}

TEST(EndToEndTest, SingleRequest_foo) {
    constexpr int num_of_threads = 1;
    constexpr int function_id = 0; // foo()
    constexpr int num_of_requests = 1;

    std::promise<int> server_p;
    auto server_f = server_p.get_future();
    std::thread server_thread = std::thread(&run_server,
                                            std::move(server_p),
                                            num_of_threads);

    std::promise<int> client_p;
    auto client_f = client_p.get_future();
    std::thread client_thread = std::thread(&run_client,
                                            std::move(client_p),
                                            num_of_threads,
                                            num_of_requests,
                                            function_id);

    client_thread.join();
    server_thread.join();

    EXPECT_EQ(server_f.get(), 0);
    EXPECT_EQ(client_f.get(), 0);
}

TEST(EndToEndTest, SingleRequest_boo) {
    constexpr int num_of_threads = 1;
    constexpr int function_id = 1; // boo()
    constexpr int num_of_requests = 1;

    std::promise<int> server_p;
    auto server_f = server_p.get_future();
    std::thread server_thread = std::thread(&run_server,
                                            std::move(server_p),
                                            num_of_threads);

    std::promise<int> client_p;
    auto client_f = client_p.get_future();
    std::thread client_thread = std::thread(&run_client,
                                            std::move(client_p),
                                            num_of_threads,
                                            num_of_requests,
                                            function_id);

    client_thread.join();
    server_thread.join();

    EXPECT_EQ(server_f.get(), 0);
    EXPECT_EQ(client_f.get(), 0);
}

TEST(EndToEndTest, MultipleRequests_foo) {
    constexpr int num_of_threads = 1;
    constexpr int function_id = 0; // foo()
    constexpr int num_of_requests = 10;

    std::promise<int> server_p;
    auto server_f = server_p.get_future();
    std::thread server_thread = std::thread(&run_server,
                                            std::move(server_p),
                                            num_of_threads);

    std::promise<int> client_p;
    auto client_f = client_p.get_future();
    std::thread client_thread = std::thread(&run_client,
                                            std::move(client_p),
                                            num_of_threads,
                                            num_of_requests,
                                            function_id);

    client_thread.join();
    server_thread.join();

    EXPECT_EQ(server_f.get(), 0);
    EXPECT_EQ(client_f.get(), 0);
}

TEST(EndToEndTest, MultipleCuncurrentRequests_foo) {
    constexpr int num_of_threads = 4;
    constexpr int function_id = 0; // foo()
    constexpr int num_of_requests = 10;

    std::promise<int> server_p;
    auto server_f = server_p.get_future();
    std::thread server_thread = std::thread(&run_server,
                                            std::move(server_p),
                                            num_of_threads);

    std::promise<int> client_p;
    auto client_f = client_p.get_future();
    std::thread client_thread = std::thread(&run_client,
                                            std::move(client_p),
                                            num_of_threads,
                                            num_of_requests,
                                            function_id);

    client_thread.join();
    server_thread.join();

    EXPECT_EQ(server_f.get(), 0);
    EXPECT_EQ(client_f.get(), 0);
}


}  // namespace frpc
