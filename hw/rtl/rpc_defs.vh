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
`include "nic_defs.vh"

// Base types
//----------------------------------------------------------------------
typedef logic [LMAX_NUM_OF_CONNECTIONS-1:0] ConnectionId;

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

// RPC interface to connection manager
//----------------------------------------------------------------------
typedef struct packed {
    FlowId flow_id;
    RpcPckt rpc_data;
    logic valid;
} CManagerRpcIf;

typedef struct packed {
    NetworkAddressTuple net_addr;
    RpcPckt rpc_data;
    logic valid;
} CManagerNetRpcIf;

`endif //  RPC_DEFS_VH_
