// Author: Cornell University
//
// Module Name :    nic_defs
// Project :        F-NIC
// Description :    Definitions for the NIC module
//

`ifndef NIC_DEFS_VH_
`define NIC_DEFS_VH_

`include "config_defs.vh"
`include "general_defs.vh"
`include "cpu_if_defs.vh"

parameter LMAX_CCIP_BATCH = 2;
parameter LMAX_CCIP_DMA_BATCH = 6;

typedef logic [LMAX_NUM_OF_FLOWS-1:0] FlowId;

// RPC interface
//----------------------------------------------------------------------
typedef struct packed {
    FlowId  flow_id;
    RpcPckt rpc_data;
} RpcIf;

// RPC Network interface (to transport)
//----------------------------------------------------------------------
localparam TRANSPORT_DATA_WIDTH = 512;

typedef logic[TRANSPORT_DATA_WIDTH-1:0] NetworkPayload;

typedef struct packed {
    IPv4 source_ip;
    Port source_port;
    IPv4 dest_ip;
    Port dest_port;
} NetworkAddressTuple;

typedef struct packed {
    NetworkAddressTuple addr_tpl;
    NetworkPayload payload;
    logic valid;
} NetworkIf;

// RPC Transport network interface (to PHY/MAC)
//----------------------------------------------------------------------
//localparam MAC_PHY_DATA_WIDTH = 256;
//
//typedef struct packed {
//    logic                          tx_clk_in;
//    logic                          tx_reset_in;
//    logic                          tx_ready_in;
//    logic [MAC_PHY_DATA_WIDTH-1:0] tx_data_out;
//    logic                          tx_valid_out;
//    logic                          tx_sop_out;
//    logic                          tx_eop_out;
//    logic   [4:0]                  tx_empty_out;
//    logic                          tx_error_out;
//} AvalonNetworkIf_Tx;
//
//typedef struct packed {
//	
//} AvalonNetworkIf_Rx;

`endif //  NIC_DEFS_VH_
