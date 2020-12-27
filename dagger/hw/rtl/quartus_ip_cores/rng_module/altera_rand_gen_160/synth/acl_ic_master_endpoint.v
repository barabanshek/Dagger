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
    


// one-way bidirectional connection:
// altera message_off 10665

module acl_ic_master_endpoint
#(
    parameter integer DATA_W = 32,              // > 0
    parameter integer BURSTCOUNT_W = 4,         // > 0
    parameter integer ADDRESS_W = 32,           // > 0
    parameter integer BYTEENA_W = DATA_W / 8,   // > 0
    parameter integer ID_W = 1,                 // > 0

    parameter integer TOTAL_NUM_MASTERS = 1,    // > 0

    parameter integer ID = 0                    // [0..2^ID_W-1]
)
(
    input logic clock,
    input logic resetn,

    acl_ic_master_intf m_intf,

    acl_arb_intf arb_intf,
    acl_ic_wrp_intf wrp_intf,
    acl_ic_rrp_intf rrp_intf
);
    // Pass-through arbitration data.
    assign arb_intf.req = m_intf.arb.req;
    assign m_intf.arb.stall = arb_intf.stall;

    generate
    if( TOTAL_NUM_MASTERS > 1 )
    begin
        // There shouldn't be any truncation, but be explicit about the id width.
        logic [ID_W-1:0] id = ID;

        // Write return path.
        assign m_intf.wrp.ack = wrp_intf.ack & (wrp_intf.id == id);

        // Read return path.
        assign m_intf.rrp.datavalid = rrp_intf.datavalid & (rrp_intf.id == id);
        assign m_intf.rrp.data = rrp_intf.data;
    end
    else // TOTAL_NUM_MASTERS == 1
    begin
        // Only one master driving the entire interconnect, so there's no need
        // to check the id.

        // Write return path.
        assign m_intf.wrp.ack = wrp_intf.ack;

        // Read return path.
        assign m_intf.rrp.datavalid = rrp_intf.datavalid;
        assign m_intf.rrp.data = rrp_intf.data;
    end
    endgenerate

endmodule

