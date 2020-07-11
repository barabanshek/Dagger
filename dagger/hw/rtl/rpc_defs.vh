// Author: Cornell University
//
// Module Name :    rpc_defs
// Project :        F-NIC
// Description :    RPC definitions
//
// NOTE: this file must be consistent with sw/rpc_header.h
// NOTE: SystemVerilog structures are reversed w.r.t. C structures

`ifndef RPC_DEFS_VH_
`define RPC_DEFS_VH_

typedef enum logic[0:0] { rpcReq, rpcResp } RpcReqType;

typedef struct packed {
    logic      [4:0] padding;
    logic      valid;
    logic      update_flag;
    RpcReqType req_type;
} RpcHeaderCtl;

typedef struct packed {
    logic [7:0]  num_of_args;
    logic [7:0]  fn_id;
    logic [31:0] rpc_id;
    RpcHeaderCtl ctl;
} RpcHeader;

typedef struct packed {
    logic [31:0] arg2;
    logic [31:0] arg1;
    RpcHeader hdr;
} RpcReqPckt;

typedef struct packed {
    logic [31:0] ret_val;
    RpcHeader hdr;
} RpcRespPckt;

// Abstract RPC packet
typedef struct packed {
    logic [31:0] padding_1;
    logic [31:0] padding_0;
    RpcHeader hdr;
} RpcPckt;

`endif //  RPC_DEFS_VH_
