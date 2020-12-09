// Author: Cornell University
//
// Module Name :    nic_defs
// Project :        F-NIC
// Description :    CPU interface definitions
//                  This should be consistent with the software definitions
//

`ifndef CPU_IF_DEFS_H_
`define CPU_IF_DEFS_H_

// =============================================================
// Cache-line sizes
// This should be consistent with the targer HW platform
// =============================================================
parameter CL_SIZE_BYTES = 64;
parameter CL_SIZE_WORDS = 16;


// =============================================================
// NIC status/mode structures
// This should be consistent with the NicHwStatus in sw/nic_impl/nic_ccip.h
// =============================================================
typedef enum logic[1:0] { ccipMMIO,
                          ccipPolling,
                          ccipDMA,
                          ccipQueuePolling } CcipMode;

typedef struct packed {
    logic  err_rpc;
    logic  err_ccip;
    logic  err_rpcTxFifoOvf;
    logic  err_rpcRxFifoOvf;
    logic  error;
    logic  running;
    logic  ready;
    logic[2:0] nic_id;
} NicStatus;


// =============================================================
// RPC header (as viwed by CPU)
// This should be consistent with sw/rpc_header.h
// NOTE: SystemVerilog structures are reversed w.r.t. C structures
// =============================================================
typedef enum logic[0:0] { rpcReq, rpcResp } RpcReqType;

typedef struct packed {
    logic      [4:0] padding;
    logic      valid;
    logic      update_flag;
    RpcReqType req_type;
} RpcHeaderCtl;

typedef struct packed {
    logic [7:0]  connection_id;
    logic [15:0] argl;
    logic [15:0] fn_id;
    logic [7:0]  frame_id;
    logic [7:0]  n_of_frames;
    logic [31:0] rpc_id;
    RpcHeaderCtl ctl;
} RpcHeader;    // Size is 96b

typedef struct packed {
    logic [415:0] argv;
    RpcHeader hdr;
} RpcPckt;


// =============================================================
// RPC connection setup
// This should be consistent with sw/nic_impl/nic_ccip.h
// =============================================================
typedef enum logic[2:0] { setUpConnId,
                          setUpOpen,
                          setUpDestIPv4,
                          setUpDestPort,
                          setUpClientFlowId,
                          setUpEnable } ConnSetupCmds;

typedef struct packed {
    logic[4:0] padding;
    ConnSetupCmds cmd;
	logic[31:0] data;
} ConnSetupFrame;

typedef enum logic[1:0] { cOK,
                          cAlreadyOpen,
                          cIsClosed,
                          cIdWrong } ConnSetupStatusErrors;

typedef struct packed {
    logic[4:0] padding;
    ConnSetupStatusErrors error_status;
    logic valid;
    logic[31:0] conn_id;
} ConnSetupStatus;


`endif //  CPU_IF_DEFS_H_
