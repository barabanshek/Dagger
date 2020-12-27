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
    

`include "acl_fifo.v"
`include "acl_data_fifo.v"

module acl_stream_fifo
#(
    // FIFO_DEPTH must be >=0
    parameter integer FIFO_DEPTH = 0,
    parameter integer DATA_W = 32,             // > 0
    parameter integer STALL_ON_ALMOSTFULL = 0,
    parameter integer ALMOST_FULL_VALUE=-1, // < FIFO_DEPTH, -1 defaults to FIFO_DEPTH
    parameter string IMPLEMENTATION_TYPE = "auto"
)
(
    input logic clock,
    input logic resetn,

    input logic                 stream_in_valid,
    input logic    [DATA_W-1:0] stream_in_data,
    output logic                stream_in_ready,

    input logic                 stream_out_ready,
    output logic   [DATA_W-1:0] stream_out_data,
    output logic                stream_out_valid,
    output logic                almost_full
);

    localparam ALMOST_FULL_THRESHOLD = ALMOST_FULL_VALUE == -1 ? FIFO_DEPTH : ALMOST_FULL_VALUE;
    localparam TYPE = (FIFO_DEPTH < 4) ? "ll_reg" : "ram";
    
    generate
    if (FIFO_DEPTH == 0)
    begin
        assign stream_in_ready = stream_out_ready;
        assign stream_out_data = stream_in_data;
        assign stream_out_valid = stream_in_valid;
        assign almost_full = ~stream_out_ready;
    end
    else if (IMPLEMENTATION_TYPE == "mlab")
    begin
        logic stall_out;
        acl_fifo
        #(
            .DATA_WIDTH(DATA_W),
            .DEPTH(FIFO_DEPTH),
            .ALMOST_FULL_VALUE(ALMOST_FULL_THRESHOLD),
            .LPM_HINT("RAM_BLOCK_TYPE=MLAB")
        )
        fifo
        (
            .clock     (clock),
            .resetn    (resetn), 
            .data_in   ( stream_in_data ),
            .valid_in  ( stream_in_valid ),
            .stall_out (stall_out),
            .data_out  (stream_out_data),
            .stall_in  (~stream_out_ready),
            .valid_out (stream_out_valid),
            .almost_full(almost_full)
        );
        assign stream_in_ready = STALL_ON_ALMOSTFULL ? ~almost_full : ~stall_out;
    end
    else
    begin
        logic stall_out;
        acl_data_fifo
        #(
            .DATA_WIDTH(DATA_W),
            .DEPTH(FIFO_DEPTH),
            .IMPL(TYPE),
            .ALMOST_FULL_VALUE(ALMOST_FULL_THRESHOLD),
            .ALLOW_FULL_WRITE(1)
        )
        fifo
        (
            .clock     (clock),
            .resetn    (resetn), 
            .data_in   ( stream_in_data ),
            .valid_in  ( stream_in_valid ),
            .stall_out (stall_out),
            .data_out  (stream_out_data),
            .stall_in  (~stream_out_ready),
            .valid_out (stream_out_valid),
            .almost_full(almost_full)
        );
        assign stream_in_ready = STALL_ON_ALMOSTFULL ? ~almost_full : ~stall_out;
    end
    endgenerate

endmodule
