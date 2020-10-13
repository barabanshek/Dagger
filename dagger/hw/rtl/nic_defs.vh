// Author: Cornell University
//
// Module Name :    nic_defs
// Project :        F-NIC
// Description :    Definitions for the NIC module

`ifndef NIC_DEFS_VH_
`define NIC_DEFS_VH_

`include "rpc_defs.vh"

parameter CL_SIZE_BYTES = 64;
parameter CL_SIZE_WORDS = 16;
parameter LMAX_CCIP_BATCH = 2;
parameter LMAX_CCIP_DMA_BATCH = 6;

// Status
// NOTE: this should be consistent with the NicHwStatus in nic.h
typedef struct packed {
    logic  err_ccip;
    logic  err_rpcTxFifoOvf;
    logic  err_rpcRxFifoOvf;
    logic  error;
    logic  running;
    logic  ready;
    logic[2:0] nic_id;
} NicStatus;

typedef enum logic[1:0] { ccipMMIO, ccipPolling, ccipDMA, ccipQueuePolling } CcipMode;

// RPC interfaces
// Abstract packet
typedef struct packed {
    logic [7:0] flow_id;    //TODO: it's a temporary solution, will have an RPC descriptor table later
    RpcPckt     rpc_data;
} RpcIf;

// Network interfaces
// TODO: define w.r.t interfaces to the transport layer
localparam TRANSPORT_DATA_WIDTH = 512;

typedef struct packed {
    logic[31:0]             payload_size;
    logic[31:0]             conn_id;
} NetworkPacketHdr;

typedef struct packed {
    NetworkPacketHdr hdr;
    logic[TRANSPORT_DATA_WIDTH-1:0] payload;
} NetworkPacketInternal;

`endif //  NIC_DEFS_VH_
