/**
 * @file defs.h
 * @brief Just common definitions.
 * @author Nikita Lazarev
 */
#ifndef _DEFS_H_
#define _DEFS_H_

#include <arpa/inet.h>

namespace dagger {

//
// PHY address
//
struct PhyAddr {
  uint8_t b0;
  uint8_t b1;
  uint8_t b2;
  uint8_t b3;
  uint8_t b4;
  uint8_t b5;
};

//
// IPv4
//
class IPv4 {
 public:
  IPv4(const std::string& ip_addr, uint16_t port) : port_(port) {
    in_addr ip_addr_;
    inet_pton(AF_INET, ip_addr.c_str(), &ip_addr_);
    ipv4_ = ip_addr_.s_addr;
  }

  uint32_t get_addr() const { return ipv4_; }

  // We need this functionality because SystemVerilog structures are inverted
  // w.r.t C structures
  uint32_t get_addr_inv() const {
    return (ipv4_ >> 24) | (((ipv4_ >> 16) & 0xff) << 8) |
           (((ipv4_ >> 8) & 0xff) << 16) | ((ipv4_ & 0xff) << 24);
  }

  uint16_t get_port() const { return port_; }

 private:
  uint32_t ipv4_;
  uint16_t port_;  // TODO: why port here?
};

}  // namespace dagger

#endif
