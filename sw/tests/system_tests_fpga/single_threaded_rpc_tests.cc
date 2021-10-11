#include <gtest/gtest.h>

#include <set>
#include <unordered_set>
#include <vector>

#include "client_server_pair.h"

class ClientServerTest : public ClientServerPair {};

TEST_F(ClientServerTest, SingleLoopback1CallTest) {
  constexpr size_t num_of_threads = 1;

  SetUp(num_of_threads);

  auto c = client_pool->pop();
  ASSERT_NE(c, nullptr);

  auto cq = c->get_completion_queue();
  ASSERT_NE(cq, nullptr);

  // Open connection
  frpc::IPv4 server_addr("192.168.0.2", 3136);
  int res = c->connect(server_addr, 0);
  ASSERT_EQ(res, 0);

  // Make a call
  c->loopback1({12});

  // Wait
  size_t t_out_cnt = 0;
  while (cq->get_number_of_completed_requests() == 0 &&
         t_out_cnt < ClientServerPair::timeout) {
    sleep(1);
    ++t_out_cnt;
  }
  ASSERT_EQ(cq->get_number_of_completed_requests(), 1);

  // Check result
  Ret1 returned = *reinterpret_cast<Ret1*>(cq->pop_response().argv);
  EXPECT_EQ(returned.f_id, 0);
  EXPECT_EQ(returned.ret_val, 12 + ClientServerPair::loopback1_const);
}

TEST_F(ClientServerTest, MultipleLoopback1CallTest) {
  constexpr size_t num_of_threads = 1;

  SetUp(num_of_threads);

  constexpr size_t num_of_it = 1000;
  constexpr size_t num_of_wait_us = 100;

  auto c = client_pool->pop();
  ASSERT_NE(c, nullptr);

  auto cq = c->get_completion_queue();
  ASSERT_NE(cq, nullptr);

  // Open connection
  frpc::IPv4 server_addr("192.168.0.2", 3136);
  int res = c->connect(server_addr, 0);
  ASSERT_EQ(res, 0);

  // Make calls
  std::unordered_set<int> expected;
  for (int i = 0; i < num_of_it; ++i) {
    c->loopback1({i});
    expected.insert(i + ClientServerPair::loopback1_const);
    usleep(num_of_wait_us);
  }

  // Wait
  size_t t_out_cnt = 0;
  while (cq->get_number_of_completed_requests() < num_of_it &&
         t_out_cnt < ClientServerPair::timeout) {
    sleep(1);
    ++t_out_cnt;
  }
  ASSERT_EQ(cq->get_number_of_completed_requests(), num_of_it);

  // Check result
  size_t num_of_errors = 0;
  for (int i = 0; i < num_of_it; ++i) {
    Ret1 returned = *reinterpret_cast<Ret1*>(cq->pop_response().argv);
    EXPECT_EQ(returned.f_id, 0);

    auto it = expected.find(returned.ret_val);
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
  constexpr size_t num_of_threads = 1;

  SetUp(num_of_threads);

  auto c = client_pool->pop();
  ASSERT_NE(c, nullptr);

  auto cq = c->get_completion_queue();
  ASSERT_NE(cq, nullptr);

  // Open connection
  frpc::IPv4 server_addr("192.168.0.2", 3136);
  int res = c->connect(server_addr, 0);
  ASSERT_EQ(res, 0);

  // Make a call
  c->loopback2({1, 2, 3, 4});
  uint64_t expected = 1 + 2 + 3 + 4;

  // Wait
  size_t t_out_cnt = 0;
  while (cq->get_number_of_completed_requests() == 0 &&
         t_out_cnt < ClientServerPair::timeout) {
    sleep(1);
    ++t_out_cnt;
  }
  ASSERT_EQ(cq->get_number_of_completed_requests(), 1);

  // Check result
  Ret1 returned = *reinterpret_cast<Ret1*>(cq->pop_response().argv);
  EXPECT_EQ(returned.f_id, 1);
  EXPECT_EQ(returned.ret_val, expected);
}

TEST_F(ClientServerTest, MultipleLoopback2CallTest) {
  constexpr size_t num_of_threads = 1;

  SetUp(num_of_threads);

  constexpr size_t num_of_it = 1000;
  constexpr size_t num_of_wait_us = 100;

  auto c = client_pool->pop();
  ASSERT_NE(c, nullptr);

  auto cq = c->get_completion_queue();
  ASSERT_NE(cq, nullptr);

  // Open connection
  frpc::IPv4 server_addr("192.168.0.2", 3136);
  int res = c->connect(server_addr, 0);
  ASSERT_EQ(res, 0);

  // Make calls
  std::unordered_set<int> expected;
  for (int i = 0; i < num_of_it; ++i) {
    c->loopback2({i, 10, i + 1, i + 2});
    expected.insert(i + 10 + i + 1 + i + 2);
    usleep(num_of_wait_us);
  }

  // Wait
  size_t t_out_cnt = 0;
  while (cq->get_number_of_completed_requests() < num_of_it &&
         t_out_cnt < ClientServerPair::timeout) {
    sleep(1);
    ++t_out_cnt;
  }
  ASSERT_EQ(cq->get_number_of_completed_requests(), num_of_it);

  // Check result
  size_t num_of_errors = 0;
  for (int i = 0; i < num_of_it; ++i) {
    Ret1 returned = *reinterpret_cast<Ret1*>(cq->pop_response().argv);
    EXPECT_EQ(returned.f_id, 1);

    auto it = expected.find(returned.ret_val);
    if (it == expected.end()) {
      ++num_of_errors;
    } else {
      expected.erase(it);
    }
  }
  EXPECT_EQ(num_of_errors, 0);
  EXPECT_EQ(expected.size(), 0);
}

TEST_F(ClientServerTest, MultipleLoopback5CallTest) {
  constexpr size_t num_of_threads = 1;

  SetUp(num_of_threads);

  constexpr size_t num_of_it = 1000;
  constexpr size_t num_of_wait_us = 100;

  auto c = client_pool->pop();
  ASSERT_NE(c, nullptr);

  auto cq = c->get_completion_queue();
  ASSERT_NE(cq, nullptr);

  // Open connection
  frpc::IPv4 server_addr("192.168.0.2", 3136);
  int res = c->connect(server_addr, 0);
  ASSERT_EQ(res, 0);

  // Make calls
  std::unordered_set<std::string> expected;
  for (int i = 0; i < num_of_it; ++i) {
    StringArg arg;
    sprintf(arg.str, "Hi there, i=%d", i);
    c->loopback5(arg);
    expected.insert(arg.str);
    usleep(num_of_wait_us);
  }

  // Wait
  size_t t_out_cnt = 0;
  while (cq->get_number_of_completed_requests() < num_of_it &&
         t_out_cnt < ClientServerPair::timeout) {
    sleep(1);
    ++t_out_cnt;
  }
  ASSERT_EQ(cq->get_number_of_completed_requests(), num_of_it);

  // Check result
  size_t num_of_errors = 0;
  for (int i = 0; i < num_of_it; ++i) {
    StringRet returned = *reinterpret_cast<StringRet*>(cq->pop_response().argv);
    EXPECT_EQ(returned.f_id, 4);

    auto it = expected.find(returned.str);
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
  constexpr size_t num_of_threads = 1;

  SetUp(num_of_threads);

  constexpr size_t num_of_it = 1000;
  constexpr size_t num_of_wait_us = 100;

  auto c = client_pool->pop();
  ASSERT_NE(c, nullptr);

  auto cq = c->get_completion_queue();
  ASSERT_NE(cq, nullptr);

  // Open connection
  frpc::IPv4 server_addr("192.168.0.2", 3136);
  int res = c->connect(server_addr, 0);
  ASSERT_EQ(res, 0);

  // Make calls
  std::unordered_set<uint64_t> expected_0;
  std::unordered_set<uint64_t> expected_1;
  std::unordered_set<uint64_t> expected_2;
  std::set<std::pair<uint64_t, uint64_t>> expected_3;

  for (int i = 0; i < num_of_it; ++i) {
    switch (i % 4) {
      case 0: {
        c->loopback1({i});
        expected_0.insert(i + ClientServerPair::loopback1_const);
        break;
      }

      case 1: {
        c->loopback2({i, 10, i + 1, i + 2});
        expected_1.insert(i + 10 + i + 1 + i + 2);
        break;
      }

      case 2: {
        c->loopback3({i + 1, i + 2, i + 3, 2});
        expected_2.insert((i + 1) * (i + 2) + (i + 3) * 2);
        break;
      }

      case 3: {
        c->loopback4({i + 1, i + 2, i + 3, 5});
        expected_3.insert(std::make_pair((i + 1) * (i + 2) + (i + 3) * 5,
                                         (i + 1) * (i + 3) + (i + 2) * 5));
        break;
      }
    }

    usleep(num_of_wait_us);
  }

  // Wait
  size_t t_out_cnt = 0;
  while (cq->get_number_of_completed_requests() < num_of_it &&
         t_out_cnt < ClientServerPair::timeout) {
    sleep(1);
    ++t_out_cnt;
  }
  ASSERT_EQ(cq->get_number_of_completed_requests(), num_of_it);

  // Check result
  size_t num_of_errors = 0;
  for (int i = 0; i < num_of_it; ++i) {
    auto ret = cq->pop_response();

    Ret1 returned = *reinterpret_cast<Ret1*>(ret.argv);
    switch (returned.f_id) {
      case 0: {
        auto it = expected_0.find(returned.ret_val);
        if (it == expected_0.end()) {
          ++num_of_errors;
        } else {
          expected_0.erase(it);
        }

        break;
      }

      case 1: {
        auto it = expected_1.find(returned.ret_val);
        if (it == expected_1.end()) {
          ++num_of_errors;
        } else {
          expected_1.erase(it);
        }

        break;
      }

      case 2: {
        auto it = expected_2.find(returned.ret_val);
        if (it == expected_2.end()) {
          ++num_of_errors;
        } else {
          expected_2.erase(it);
        }

        break;
      }

      case 3: {
        Ret2* returned_casted = reinterpret_cast<Ret2*>(ret.argv);
        auto to_find = std::make_pair(returned_casted->ret_val,
                                      returned_casted->ret_val_1);
        auto it = expected_3.find(to_find);

        if (it == expected_3.end()) {
          ++num_of_errors;
        } else {
          expected_3.erase(it);
        }

        break;
      }
    }
  }

  EXPECT_EQ(num_of_errors, 0);
  EXPECT_EQ(expected_0.size(), 0);
  EXPECT_EQ(expected_1.size(), 0);
  EXPECT_EQ(expected_2.size(), 0);
  EXPECT_EQ(expected_3.size(), 0);
}
