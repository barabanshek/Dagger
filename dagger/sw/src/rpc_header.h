// NOTE: this file must be consistent with hw/rtl/rpc_defs.vh
// NOTE: SystemVerilog structures are reversed w.r.t. C structures

#ifndef _RPC_HEADER_H_
#define _RPC_HEADER_H_

#include <type_traits>

#include <stddef.h>
#include <stdint.h>

namespace frpc {

// TODO: move it somewhere so it's always consistent with the NIC's one
#define CACHELINE_BYTES 64

// General headers
#define DirReq 0
#define DirResp 1

#define ARG_NOT_DEFINED 0

struct __attribute__ ((__packed__)) RpcHeaderCtl {
    uint8_t direction   : 1;
    uint8_t update_flag : 1;
    uint8_t valid       : 1;
};

struct __attribute__ ((__packed__)) RpcHeader {
    RpcHeaderCtl ctl;
    uint32_t rpc_id;
    uint8_t fn_id;
    uint8_t num_of_args;
};

// RPC example: uint32_t foo(uint32_t a, uint32_t b);
struct __attribute__ ((__packed__)) RpcReqPckt {
    RpcHeader hdr;
    uint32_t arg1;
    uint32_t arg2;
};

// Support CL-sized RPCs only so far
static_assert(sizeof(RpcReqPckt) <= CACHELINE_BYTES,
                            "RpcReqPckt does not fit cache line");

struct __attribute__ ((__packed__)) RpcRespPckt {
    RpcHeader hdr;
    uint32_t ret_val;
};

// Support CL-sized RPCs only so far
static_assert(sizeof(RpcRespPckt) <= CACHELINE_BYTES,
                            "RpcRespPckt does not fit cache line");

}  // namespace frpc

#endif
