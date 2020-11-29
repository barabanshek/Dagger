// Author: Cornell University
//
// Module Name :    rpc_defs
// Project :        F-NIC
// Description :    Definitions for the RPC module, includes definitions for
//                    - RPC module
//                    - Connection Manager module
//

`ifndef RPC_DEFS_VH_
`define RPC_DEFS_VH_

`include "config_defs.vh"
`include "general_defs.vh"

// Base types
//----------------------------------------------------------------------
typedef logic [LMAX_NUM_OF_FLOWS-1:0] FlowId;
typedef logic [LMAX_NUM_OF_CONNECTIONS-1] ConnectionId;

// Connection control interface to connection manager
//----------------------------------------------------------------------
typedef struct packed {
    ConnectionId conn_id;
    IPv4 dest_ip;
    Port dest_port;
    FlowId client_flow_id;
    logic open;
    logic enable;
} ConnectionControlIf;


`endif //  RPC_DEFS_VH_
