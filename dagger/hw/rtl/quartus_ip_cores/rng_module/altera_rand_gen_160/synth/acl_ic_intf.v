// (C) 1992-2016 Altera Corporation. All rights reserved.                         
// Your use of Altera Corporation's design tools, logic functions and other       
// software and tools, and its AMPP partner logic functions, and any output       
// files any of the foregoing (including device programming or simulation         
// files), and any associated documentation or information are expressly subject  
// to the terms and conditions of the Altera Program License Subscription         
// Agreement, Altera MegaCore Function License Agreement, or other applicable     
// license agreement, including, without limitation, that your use is for the     
// sole purpose of programming logic devices manufactured by Altera and sold by   
// Altera or its authorized distributors.  Please refer to the applicable         
// agreement for further details.                                                 
    


interface acl_ic_wrp_intf #(
    parameter integer ID_W = 1  // > 0
)
();
    logic ack;
    logic [ID_W-1:0] id;
endinterface

interface acl_ic_rrp_intf #(
    parameter integer DATA_W = 32,  // > 0
    parameter integer ID_W = 1      // > 0
)
();
    logic datavalid;
    logic [ID_W-1:0] id;
    logic [DATA_W-1:0] data;
endinterface

interface acl_ic_master_intf #(
    parameter integer DATA_W = 32,              // > 0
    parameter integer BURSTCOUNT_W = 4,         // > 0
    parameter integer ADDRESS_W = 32,           // > 0
    parameter integer BYTEENA_W = DATA_W / 8,   // > 0
    parameter integer ID_W = 1                  // > 0
)
();
    // Arbitration.
    struct packed {
        struct packed {
            logic enable;
            logic request;
            logic read;
            logic write;
            logic [DATA_W-1:0] writedata;
            logic [BURSTCOUNT_W-1:0] burstcount;
            logic [ADDRESS_W-1:0] address;
            logic [BYTEENA_W-1:0] byteenable;
            logic [ID_W-1:0] id;    
        } req;

        logic stall;
    } arb;

    // Write return path.
    struct packed {
        logic ack;
    } wrp;

    // Read return path.
    struct packed {
        logic datavalid;
        logic [DATA_W-1:0] data;
    } rrp;
endinterface
