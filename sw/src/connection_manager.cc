#include "connection_manager.h"

#include <algorithm>
#include <cassert>
#include <iostream>

#include "logger.h"

namespace dagger {

ConnectionManager::ConnectionManager() : max_connections_(0) {}

ConnectionManager::ConnectionManager(size_t max_connections)
    : max_connections_(max_connections) {
  for (size_t i = 0; i < max_connections; ++i) {
    c_id_pool_.push_back(i);
  }
}

int ConnectionManager::open_connection(ConnectionId& c_id,
                                       const IPv4& dest_addr,
                                       ConnectionFlowId flow_id) {
  if (open_connections_.size() == max_connections_) {
    FRPC_ERROR(
        "Failed to open connection, max number of open connections is "
        "reached\n");
    return 1;
  }

  assert(c_id_pool_.size() != 0);

  c_id = c_id_pool_.front();
  c_id_pool_.pop_front();

  assert(open_connections_.find(c_id) == open_connections_.end());
  open_connections_.insert(
      std::make_pair(c_id, std::make_pair(dest_addr, flow_id)));

  return 0;
}

int ConnectionManager::add_connection(ConnectionId c_id, const IPv4& dest_addr,
                                      ConnectionFlowId flow_id) {
  if (open_connections_.size() == max_connections_) {
    FRPC_ERROR(
        "Failed to add connection, max number of open connections is "
        "reached\n");
    return 1;
  }

  assert(c_id_pool_.size() != 0);

  auto it = std::find(c_id_pool_.begin(), c_id_pool_.end(), c_id);
  if (it == c_id_pool_.end()) {
    FRPC_ERROR("Failed to add connection, such connection already exists\n");
    return 1;
  }

  c_id_pool_.erase(it);

  assert(open_connections_.find(c_id) == open_connections_.end());
  open_connections_.insert(
      std::make_pair(c_id, std::make_pair(dest_addr, flow_id)));

  return 0;
}

int ConnectionManager::close_connection(ConnectionId c_id) {
  auto it = open_connections_.find(c_id);

  if (it == open_connections_.end()) {
    FRPC_ERROR("Failed to close connection, the connection is not open\n");
    return 1;
  }

  open_connections_.erase(it);
  c_id_pool_.push_back(c_id);

  return 0;
}

void ConnectionManager::dump_open_connections() const {
  std::cout << "*** Open connections ***" << std::endl;
  std::cout << "<connection_id, dest_ip, dest_port, flow_id>" << std::endl;
  for (auto c : open_connections_) {
    std::cout << c.first << c.second.first.get_addr()
              << c.second.first.get_port() << c.second.second << std::endl;
  }
}

}  // namespace dagger
