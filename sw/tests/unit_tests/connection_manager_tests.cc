#include <gtest/gtest.h>

#include "connection_manager.h"

namespace frpc {

TEST(ConnectionManagerTest, TestOpenConnection) {
  ConnectionManager cm(2);
  IPv4 c_addr("127.0.0.1", 3600);
  ConnectionFlowId c_flow_id = 0;
  ConnectionId c_id;

  int res = cm.open_connection(c_id, c_addr, c_flow_id);
  EXPECT_EQ(res, 0);
  EXPECT_EQ(c_id, 0);

  res = cm.open_connection(c_id, c_addr, c_flow_id);
  EXPECT_EQ(res, 0);
  EXPECT_EQ(c_id, 1);

  res = cm.open_connection(c_id, c_addr, c_flow_id);
  EXPECT_EQ(res, 1);
}

TEST(ConnectionManagerTest, TestCloseConnection) {
  ConnectionManager cm(2);
  IPv4 c_addr("127.0.0.1", 3600);
  ConnectionFlowId c_flow_id = 0;
  ConnectionId c_id;

  int res = cm.open_connection(c_id, c_addr, c_flow_id);
  EXPECT_EQ(res, 0);
  EXPECT_EQ(c_id, 0);

  res = cm.open_connection(c_id, c_addr, c_flow_id);
  EXPECT_EQ(res, 0);
  EXPECT_EQ(c_id, 1);

  res = cm.close_connection(1);
  EXPECT_EQ(res, 0);

  res = cm.open_connection(c_id, c_addr, c_flow_id);
  EXPECT_EQ(res, 0);
  EXPECT_EQ(c_id, 1);

  res = cm.close_connection(1);
  EXPECT_EQ(res, 0);

  res = cm.close_connection(0);
  EXPECT_EQ(res, 0);
}

TEST(ConnectionManagerTest, TestConnectionExists) {
  ConnectionManager cm(2);
  IPv4 c_addr("127.0.0.1", 3600);
  ConnectionFlowId c_flow_id = 0;
  ConnectionId c_id;

  int res = cm.open_connection(c_id, c_addr, c_flow_id);
  EXPECT_EQ(res, 0);
  EXPECT_EQ(c_id, 0);

  res = cm.add_connection(0, c_addr, c_flow_id);
  EXPECT_EQ(res, 1);

  res = cm.close_connection(0);
  EXPECT_EQ(res, 0);

  res = cm.add_connection(0, c_addr, c_flow_id);
  EXPECT_EQ(res, 0);
}

TEST(ConnectionManagerTest, TestConnectionClosed) {
  ConnectionManager cm(2);
  IPv4 c_addr("127.0.0.1", 3600);
  ConnectionFlowId c_flow_id = 0;
  ConnectionId c_id;

  int res = cm.open_connection(c_id, c_addr, c_flow_id);
  EXPECT_EQ(res, 0);
  EXPECT_EQ(c_id, 0);

  res = cm.close_connection(0);
  EXPECT_EQ(res, 0);

  res = cm.close_connection(0);
  EXPECT_EQ(res, 1);
}

TEST(ConnectionManagerTest, TestManyConnections) {
  ConnectionManager cm(200);
  IPv4 c_addr("127.0.0.1", 3600);
  ConnectionFlowId c_flow_id = 0;
  ConnectionId c_id;

  for (int i = 0; i < 200; ++i) {
    int res = cm.open_connection(c_id, c_addr, c_flow_id);
    EXPECT_EQ(res, 0);
    EXPECT_EQ(c_id, i);
  }

  for (int i = 100; i < 200; ++i) {
    int res = cm.close_connection(i);
    EXPECT_EQ(res, 0);
  }

  for (int i = 0; i < 100; ++i) {
    int res = cm.open_connection(c_id, c_addr, c_flow_id);
    EXPECT_EQ(res, 0);
    EXPECT_EQ(c_id, i + 100);
  }
}

}  // namespace frpc
