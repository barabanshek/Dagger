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
    logic [7:0]  padding;
    logic [15:0] argl;
    logic [15:0] fn_id;
    logic [7:0]  frame_id;
    logic [7:0]  n_of_frames;
    logic [31:0] rpc_id;
    RpcHeaderCtl ctl;
} RpcHeader;    // Size is 96B

typedef struct packed {
    logic [63:0] argv;
    RpcHeader hdr;
} RpcPckt;

`endif //  RPC_DEFS_VH_
