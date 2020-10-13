// NOTE: this file must be consistent with hw/rtl/rpc_defs.vh
// NOTE: SystemVerilog structures are reversed w.r.t. C structures

#ifndef _RPC_HEADER_H_
#define _RPC_HEADER_H_

#include <type_traits>

#include <stddef.h>
#include <stdint.h>

#include "config.h"

namespace frpc {

enum Direction {
    rpc_request = 0,
    rpc_response = 1
};

struct __attribute__ ((__packed__)) RpcHeaderCtl {
    uint8_t req_type    : 1;
    uint8_t update_flag : 1;
    uint8_t valid       : 1;
};

static_assert(sizeof(RpcHeaderCtl) == 1,
                            "RpcHeaderCtl is too large");

struct __attribute__ ((__packed__)) RpcHeader {
    RpcHeaderCtl ctl;

    // Transport data
    uint32_t rpc_id;        // unique RPC ID
    uint8_t  n_of_frames;   // number of cl-sized frames
    uint8_t  frame_id;      // frame ID (0 for head)

    // RPC data
    uint16_t fn_id;         // remote function ID
    uint16_t argl;          // length of args

    // Padding
    uint8_t padding;
};

constexpr size_t rpc_header_size_bytes = 12;
static_assert(sizeof(RpcHeader) == rpc_header_size_bytes,
                            "RpcHeader size error");

struct __attribute__ ((__packed__)) RpcPckt {
    RpcHeader hdr;
    uint8_t argv[cfg::sys::cl_size_bytes - rpc_header_size_bytes];
};

// Support the MTU of 1 cache line so far
// Do reassembling in software for larger RPCs
static_assert(sizeof(RpcPckt) == cfg::sys::cl_size_bytes,
                            "RpcPckt does not fit cache line");

}  // namespace frpc

#endif
