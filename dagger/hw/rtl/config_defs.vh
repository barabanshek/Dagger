// Author: Cornell University
//
// Module Name :    nic_defs
// Project :        F-NIC
// Description :    System configuration
//

`ifndef CONFIG_DEFS_H_
`define CONFIG_DEFS_H_

// =============================================================
// Base configuration
// =============================================================
// Max number of NIC flows
// - this number of flows will be synthesized
// - less or equal number of flows can be configures from SW
parameter LMAX_NUM_OF_FLOWS = 4;    // 2**4=16 flows

// Size of the on-chip connection table
// - TODO: if overflow, flush to DRAM
parameter LCONN_TBL_SIZE = 16;       // 2**16=65536 connections

// Max number of connections
parameter LMAX_NUM_OF_CONNECTIONS = 8;



`endif //  CONFIG_DEFS_H_
