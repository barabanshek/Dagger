#include <gtest/gtest.h>

#include <set>
#include <thread>
#include <unordered_set>
#include <vector>

#include "client_server_pair.h"

class ClientServerTestMultithreaded : public ClientServerPair {};

TEST_F(ClientServerTestMultithreaded, SingleSameCallSingleThreadTest) {
  constexpr size_t num_of_threads = 4;
  SetUp(num_of_threads);

  // Run multiple clients
  std::vector<frpc::RpcClient*> clients;
  std::vector<frpc::CompletionQueue*> cqueues;
  for (int i = 0; i < num_of_threads; ++i) {
    auto c = client_pool->pop();
    ASSERT_NE(c, nullptr);

    auto cq = c->get_completion_queue();
    ASSERT_NE(cq, nullptr);

    clients.push_back(c);
    cqueues.push_back(cq);
  }

  // Open connections
  frpc::IPv4 server_addr("192.168.0.2", 3136);
  for (int i = 0; i < num_of_threads; ++i) {
    int res = clients[i]->connect(server_addr, i);
    ASSERT_EQ(res, 0);
  }

  // Make a single call in every client
  clients[0]->loopback1({12});
  clients[1]->loopback1({23});
  clients[2]->loopback1({34});
  clients[3]->loopback1({45});

  // Wait
  size_t t_out_cnt = 0;
  while ((cqueues[0]->get_number_of_completed_requests() == 0 |
          cqueues[1]->get_number_of_completed_requests() == 0 |
          cqueues[2]->get_number_of_completed_requests() == 0 |
          cqueues[3]->get_number_of_completed_requests() == 0) &&
         t_out_cnt < ClientServerPair::timeout) {
    sleep(1);
    ++t_out_cnt;
  }
  ASSERT_EQ(cqueues[0]->get_number_of_completed_requests(), 1);
  ASSERT_EQ(cqueues[1]->get_number_of_completed_requests(), 1);
  ASSERT_EQ(cqueues[2]->get_number_of_completed_requests(), 1);
  ASSERT_EQ(cqueues[3]->get_number_of_completed_requests(), 1);

  // Check result
  Ret1 returned = *reinterpret_cast<Ret1*>(cqueues[0]->pop_response().argv);
  EXPECT_EQ(returned.f_id, 0);
  EXPECT_EQ(returned.ret_val, 12 + ClientServerPair::loopback1_const);

  returned = *reinterpret_cast<Ret1*>(cqueues[1]->pop_response().argv);
  EXPECT_EQ(returned.f_id, 0);
  EXPECT_EQ(returned.ret_val, 23 + ClientServerPair::loopback1_const);

  returned = *reinterpret_cast<Ret1*>(cqueues[2]->pop_response().argv);
  EXPECT_EQ(returned.f_id, 0);
  EXPECT_EQ(returned.ret_val, 34 + ClientServerPair::loopback1_const);

  returned = *reinterpret_cast<Ret1*>(cqueues[3]->pop_response().argv);
  EXPECT_EQ(returned.f_id, 0);
  EXPECT_EQ(returned.ret_val, 45 + ClientServerPair::loopback1_const);
}

TEST_F(ClientServerTestMultithreaded, SingleDifferentCallsSingleThreadTest) {
  constexpr size_t num_of_threads = 6;
  SetUp(num_of_threads);

  // Run multiple clients
  std::vector<frpc::RpcClient*> clients;
  std::vector<frpc::CompletionQueue*> cqueues;
  for (int i = 0; i < num_of_threads; ++i) {
    auto c = client_pool->pop();
    ASSERT_NE(c, nullptr);

    auto cq = c->get_completion_queue();
    ASSERT_NE(cq, nullptr);

    clients.push_back(c);
    cqueues.push_back(cq);
  }

  // Open connections
  frpc::IPv4 server_addr("192.168.0.2", 3136);
  for (int i = 0; i < num_of_threads; ++i) {
    int res = clients[i]->connect(server_addr, i);
    ASSERT_EQ(res, 0);
  }

  // Make a single call in every client
  clients[0]->loopback1({12});
  clients[1]->loopback2({1, 2, 3, 4});
  clients[2]->loopback3({11, 12, 13, 14});
  clients[3]->loopback4({111, 222, 333, 444});
  clients[4]->loopback1({13});
  clients[5]->loopback2({101, 102, 201, 202});

  // Wait
  size_t t_out_cnt = 0;
  while ((cqueues[0]->get_number_of_completed_requests() == 0 |
          cqueues[1]->get_number_of_completed_requests() == 0 |
          cqueues[2]->get_number_of_completed_requests() == 0 |
          cqueues[3]->get_number_of_completed_requests() == 0 |
          cqueues[4]->get_number_of_completed_requests() == 0 |
          cqueues[5]->get_number_of_completed_requests() == 0) &&
         t_out_cnt < ClientServerPair::timeout) {
    sleep(1);
    ++t_out_cnt;
  }
  ASSERT_EQ(cqueues[0]->get_number_of_completed_requests(), 1);
  ASSERT_EQ(cqueues[1]->get_number_of_completed_requests(), 1);
  ASSERT_EQ(cqueues[2]->get_number_of_completed_requests(), 1);
  ASSERT_EQ(cqueues[3]->get_number_of_completed_requests(), 1);
  ASSERT_EQ(cqueues[4]->get_number_of_completed_requests(), 1);
  ASSERT_EQ(cqueues[5]->get_number_of_completed_requests(), 1);

  // Check result
  Ret1 returned = *reinterpret_cast<Ret1*>(cqueues[0]->pop_response().argv);
  EXPECT_EQ(returned.f_id, 0);
  EXPECT_EQ(returned.ret_val, 12 + ClientServerPair::loopback1_const);

  returned = *reinterpret_cast<Ret1*>(cqueues[1]->pop_response().argv);
  EXPECT_EQ(returned.f_id, 1);
  EXPECT_EQ(returned.ret_val, 1 + 2 + 3 + 4);

  returned = *reinterpret_cast<Ret1*>(cqueues[2]->pop_response().argv);
  EXPECT_EQ(returned.f_id, 2);
  EXPECT_EQ(returned.ret_val, 11 * 12 + 13 * 14);

  Ret2 returned_2 = *reinterpret_cast<Ret2*>(cqueues[3]->pop_response().argv);
  EXPECT_EQ(returned_2.f_id, 3);
  EXPECT_EQ(returned_2.ret_val, 111 * 222 + 333 * 444);
  EXPECT_EQ(returned_2.ret_val_1, 111 * 333 + 222 * 444);

  returned = *reinterpret_cast<Ret1*>(cqueues[4]->pop_response().argv);
  EXPECT_EQ(returned.f_id, 0);
  EXPECT_EQ(returned.ret_val, 13 + ClientServerPair::loopback1_const);

  returned = *reinterpret_cast<Ret1*>(cqueues[5]->pop_response().argv);
  EXPECT_EQ(returned.f_id, 1);
  EXPECT_EQ(returned.ret_val, 101 + 102 + 201 + 202);
}

TEST_F(ClientServerTestMultithreaded, MultipleDifferentCallsSingleThreadTest) {
  constexpr size_t num_of_threads = 4;
  SetUp(num_of_threads);

  constexpr size_t num_of_it = 1000;
  constexpr size_t num_of_wait_us = 100;

  // Run multiple clients
  std::vector<frpc::RpcClient*> clients;
  std::vector<frpc::CompletionQueue*> cqueues;
  for (int i = 0; i < num_of_threads; ++i) {
    auto c = client_pool->pop();
    ASSERT_NE(c, nullptr);

    auto cq = c->get_completion_queue();
    ASSERT_NE(cq, nullptr);

    clients.push_back(c);
    cqueues.push_back(cq);
  }

  // Open connections
  frpc::IPv4 server_addr("192.168.0.2", 3136);
  for (int i = 0; i < num_of_threads; ++i) {
    int res = clients[i]->connect(server_addr, i);
    ASSERT_EQ(res, 0);
  }

  // Make calls
  typedef std::unordered_set<uint64_t> ExpectedSet;

  std::vector<ExpectedSet> expected_loopback1;
  std::vector<ExpectedSet> expected_loopback2;
  std::vector<ExpectedSet> expected_loopback3;

  for (int i = 0; i < num_of_threads; ++i) {
    expected_loopback1.push_back(ExpectedSet());
    expected_loopback2.push_back(ExpectedSet());
    expected_loopback3.push_back(ExpectedSet());
  }

  for (int it = 0; it < num_of_it; ++it) {
    for (int client_i = 0; client_i < num_of_threads; ++client_i) {
      switch (it % 3) {
        case 0: {
          clients[client_i]->loopback1({(it + 1) * (client_i + 1)});
          expected_loopback1[client_i].insert(
              (it + 1) * (client_i + 1) + ClientServerPair::loopback1_const);
          usleep(num_of_wait_us);
          break;
        }

        case 1: {
          clients[client_i]->loopback2(
              {it + 1, client_i + 1, it * client_i + 1, it + client_i + 1});
          expected_loopback2[client_i].insert(
              it + 1 + client_i + 1 + it * client_i + 1 + it + client_i + 1);
          usleep(num_of_wait_us);
          break;
        }

        case 2: {
          clients[client_i]->loopback3(
              {it + 1, client_i + 1, it + client_i + 1, it * client_i + 1});
          expected_loopback3[client_i].insert((it + 1) * (client_i + 1) +
                                              (it + client_i + 1) *
                                                  (it * client_i + 1));
          usleep(num_of_wait_us);
        }
      }
    }
  }

  // Wait
  size_t t_out_cnt = 0;
  bool done = false;
  while (!done && t_out_cnt < ClientServerPair::timeout) {
    sleep(1);
    ++t_out_cnt;

    done = true;
    for (int i = 0; i < num_of_threads; ++i) {
      done =
          done & (cqueues[i]->get_number_of_completed_requests() == num_of_it);
    }
  }
  for (int i = 0; i < num_of_threads; ++i) {
    ASSERT_EQ(cqueues[i]->get_number_of_completed_requests(), num_of_it);
  }

  // Check result
  size_t num_of_errors = 0;
  for (int i = 0; i < num_of_threads; ++i) {
    for (int j = 0; j < num_of_it; ++j) {
      auto ret = cqueues[i]->pop_response();
      Ret1 returned = *reinterpret_cast<Ret1*>(ret.argv);

      switch (returned.f_id) {
        case 0: {
          auto it = expected_loopback1[i].find(returned.ret_val);
          if (it == expected_loopback1[i].end()) {
            ++num_of_errors;
          } else {
            expected_loopback1[i].erase(it);
          }

          break;
        }

        case 1: {
          auto it = expected_loopback2[i].find(returned.ret_val);
          if (it == expected_loopback2[i].end()) {
            ++num_of_errors;
          } else {
            expected_loopback2[i].erase(it);
          }

          break;
        }

        case 2: {
          auto it = expected_loopback3[i].find(returned.ret_val);
          if (it == expected_loopback3[i].end()) {
            ++num_of_errors;
          } else {
            expected_loopback3[i].erase(it);
          }

          break;
        }
      }
    }
  }

  EXPECT_EQ(num_of_errors, 0);
  for (int i = 0; i < num_of_threads; ++i) {
    EXPECT_EQ(expected_loopback1[i].size(), 0);
    EXPECT_EQ(expected_loopback2[i].size(), 0);
    EXPECT_EQ(expected_loopback3[i].size(), 0);
  }
}

typedef std::set<std::pair<uint64_t, uint64_t>> ExpectedSet;

static void test_thread(frpc::RpcClient* client, size_t num_of_it,
                        size_t thread_id, ExpectedSet& expected) {
  constexpr size_t num_of_wait_us = 100;

  // Make calls
  for (int i = 0; i < num_of_it; ++i) {
    client->loopback4({thread_id, i, thread_id + i, thread_id * i});
    expected.insert(
        std::make_pair((thread_id * i) + ((thread_id + i) * (thread_id * i)),
                       (thread_id * (thread_id + i)) + (i * (thread_id * i))));
    usleep(num_of_wait_us);
  }
}

TEST_F(ClientServerTestMultithreaded,
       MultipleDifferentCallsMultipleThreadTest) {
  constexpr size_t num_of_threads = 4;
  SetUp(num_of_threads);

  constexpr size_t num_of_it = 1000;

  // Run multiple clients
  std::vector<frpc::RpcClient*> clients;
  std::vector<frpc::CompletionQueue*> cqueues;
  for (int i = 0; i < num_of_threads; ++i) {
    auto c = client_pool->pop();
    ASSERT_NE(c, nullptr);

    auto cq = c->get_completion_queue();
    ASSERT_NE(cq, nullptr);

    clients.push_back(c);
    cqueues.push_back(cq);
  }

  // Open connections
  frpc::IPv4 server_addr("192.168.0.2", 3136);
  for (int i = 0; i < num_of_threads; ++i) {
    int res = clients[i]->connect(server_addr, i);
    ASSERT_EQ(res, 0);
  }

  // Run threads
  std::vector<std::thread> threads;
  std::vector<ExpectedSet> expected;
  for (int i = 0; i < num_of_threads; ++i) {
    expected.push_back(ExpectedSet());
  }

  for (int i = 0; i < num_of_threads; ++i) {
    std::thread thr = std::thread(&test_thread, clients[i], num_of_it, i + 1,
                                  std::ref(expected[i]));
    threads.push_back(std::move(thr));
  }

  for (auto& thr : threads) {
    thr.join();
  }

  // Wait
  size_t t_out_cnt = 0;
  bool done = false;
  while (!done && t_out_cnt < ClientServerPair::timeout) {
    sleep(1);
    ++t_out_cnt;

    done = true;
    for (int i = 0; i < num_of_threads; ++i) {
      done =
          done & (cqueues[i]->get_number_of_completed_requests() == num_of_it);
    }
  }
  for (int i = 0; i < num_of_threads; ++i) {
    ASSERT_EQ(cqueues[i]->get_number_of_completed_requests(), num_of_it);
  }

  // Check result
  size_t num_of_errors = 0;
  for (int i = 0; i < num_of_threads; ++i) {
    for (int j = 0; j < num_of_it; ++j) {
      auto ret = cqueues[i]->pop_response();
      Ret2* returned = reinterpret_cast<Ret2*>(ret.argv);

      auto to_find = std::make_pair(returned->ret_val, returned->ret_val_1);
      auto it = expected[i].find(to_find);

      if (it == expected[i].end()) {
        ++num_of_errors;
      } else {
        expected[i].erase(it);
      }
    }
  }

  EXPECT_EQ(num_of_errors, 0);
  for (int i = 0; i < num_of_threads; ++i) {
    EXPECT_EQ(expected[i].size(), 0);
  }
}
