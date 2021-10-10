// (C) 2001-2016 Altera Corporation. All rights reserved.
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


// $Id: $
// $Revision: $
// $Date: $
// $Author: $
//-----------------------------------------------------------------------------

// Copyright 2012 Altera Corporation. All rights reserved.  
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps
module crc32_rev_1 #(
    parameter TARGET_CHIP = 2,
    parameter REDUCE_LATENCY = 1'b0
)(
    input clk,
    input thru, // latency 2 - don't evo
    input [31:0] pc, // latency 2 previous CRC
    output [31:0] c // evolve backwards 1 bytes of 0
);

reg [31:0] pc_r;
reg thru_r;

generate
	if (REDUCE_LATENCY) begin
		// just wires
		always @(*) thru_r = thru;
		always @(*) pc_r = pc;
	end
	else begin
		// registers
		initial thru_r = 1'b0;
		initial pc_r = 32'h0;
		always @(posedge clk) thru_r <= thru;
		always @(posedge clk) pc_r <= pc;
	end
endgenerate

    xor_2tick_t x0 (.clk(clk), .thru(thru_r), .thru_d(pc_r[0]), .dout(c[0]),
        .din({pc[1], pc[3], pc[5], pc[7], pc[8]})); 
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
	defparam x0 .WIDTH = 5;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x1 (.clk(clk), .thru(thru_r), .thru_d(pc_r[1]), .dout(c[1]),
        .din({pc[0], pc[1], pc[2], pc[3], pc[4], 
            pc[5], pc[6], pc[7], pc[9]})); 
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .WIDTH = 9;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x2 (.clk(clk), .thru(thru_r), .thru_d(pc_r[2]), .dout(c[2]),
        .din({pc[0], pc[2], pc[4], pc[6], pc[10]})); 
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .WIDTH = 5;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x3 (.clk(clk), .thru(thru_r), .thru_d(pc_r[3]), .dout(c[3]),
        .din({pc[1], pc[3], pc[5], pc[7], pc[11]})); 
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .WIDTH = 5;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x4 (.clk(clk), .thru(thru_r), .thru_d(pc_r[4]), .dout(c[4]),
        .din({pc[1], pc[2], pc[3], pc[4], pc[5], 
            pc[6], pc[7], pc[12]})); 
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .WIDTH = 8;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x5 (.clk(clk), .thru(thru_r), .thru_d(pc_r[5]), .dout(c[5]),
        .din({pc[0], pc[1], pc[2], pc[4], pc[6], 
            pc[13]})); 
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .WIDTH = 6;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x6 (.clk(clk), .thru(thru_r), .thru_d(pc_r[6]), .dout(c[6]),
        .din({pc[1], pc[2], pc[3], pc[5], pc[7], 
            pc[14]})); 
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .WIDTH = 6;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x7 (.clk(clk), .thru(thru_r), .thru_d(pc_r[7]), .dout(c[7]),
        .din({pc[0], pc[1], pc[2], pc[4], pc[5], 
            pc[6], pc[7], pc[15]})); 
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .WIDTH = 8;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x8 (.clk(clk), .thru(thru_r), .thru_d(pc_r[8]), .dout(c[8]),
        .din({pc[2], pc[6], pc[16]})); 
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .WIDTH = 3;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x9 (.clk(clk), .thru(thru_r), .thru_d(pc_r[9]), .dout(c[9]),
        .din({pc[0], pc[3], pc[7], pc[17]})); 
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .WIDTH = 4;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x10 (.clk(clk), .thru(thru_r), .thru_d(pc_r[10]), .dout(c[10]),
        .din({pc[0], pc[3], pc[4], pc[5], pc[7], 
            pc[18]})); 
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .WIDTH = 6;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x11 (.clk(clk), .thru(thru_r), .thru_d(pc_r[11]), .dout(c[11]),
        .din({pc[3], pc[4], pc[6], pc[7], pc[19]})); 
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .WIDTH = 5;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x12 (.clk(clk), .thru(thru_r), .thru_d(pc_r[12]), .dout(c[12]),
        .din({pc[1], pc[3], pc[4], pc[20]})); 
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .WIDTH = 4;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x13 (.clk(clk), .thru(thru_r), .thru_d(pc_r[13]), .dout(c[13]),
        .din({pc[0], pc[2], pc[4], pc[5], pc[21]})); 
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .WIDTH = 5;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x14 (.clk(clk), .thru(thru_r), .thru_d(pc_r[14]), .dout(c[14]),
        .din({pc[0], pc[1], pc[3], pc[5], pc[6], 
            pc[22]})); 
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .WIDTH = 6;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x15 (.clk(clk), .thru(thru_r), .thru_d(pc_r[15]), .dout(c[15]),
        .din({pc[0], pc[1], pc[2], pc[4], pc[6], 
            pc[7], pc[23]})); 
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .WIDTH = 7;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x16 (.clk(clk), .thru(thru_r), .thru_d(pc_r[16]), .dout(c[16]),
        .din({pc[0], pc[2], pc[24]})); 
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .WIDTH = 3;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x17 (.clk(clk), .thru(thru_r), .thru_d(pc_r[17]), .dout(c[17]),
        .din({pc[0], pc[1], pc[3], pc[25]})); 
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .WIDTH = 4;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x18 (.clk(clk), .thru(thru_r), .thru_d(pc_r[18]), .dout(c[18]),
        .din({pc[1], pc[2], pc[4], pc[26]})); 
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .WIDTH = 4;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x19 (.clk(clk), .thru(thru_r), .thru_d(pc_r[19]), .dout(c[19]),
        .din({pc[2], pc[3], pc[5], pc[27]})); 
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .WIDTH = 4;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x20 (.clk(clk), .thru(thru_r), .thru_d(pc_r[20]), .dout(c[20]),
        .din({pc[0], pc[3], pc[4], pc[6], pc[28]})); 
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .WIDTH = 5;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x21 (.clk(clk), .thru(thru_r), .thru_d(pc_r[21]), .dout(c[21]),
        .din({pc[1], pc[4], pc[5], pc[7], pc[29]})); 
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .WIDTH = 5;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x22 (.clk(clk), .thru(thru_r), .thru_d(pc_r[22]), .dout(c[22]),
        .din({pc[0], pc[1], pc[2], pc[3], pc[6], 
            pc[7], pc[30]})); 
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .WIDTH = 7;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x23 (.clk(clk), .thru(thru_r), .thru_d(pc_r[23]), .dout(c[23]),
        .din({pc[0], pc[2], pc[4], pc[5], pc[31]})); 
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .WIDTH = 5;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x24 (.clk(clk), .thru(thru_r), .thru_d(pc_r[24]), .dout(c[24]),
        .din({pc[0], pc[1], pc[3], pc[5], pc[6]})); 
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .WIDTH = 5;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x25 (.clk(clk), .thru(thru_r), .thru_d(pc_r[25]), .dout(c[25]),
        .din({pc[1], pc[2], pc[4], pc[6], pc[7]})); 
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .WIDTH = 5;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x26 (.clk(clk), .thru(thru_r), .thru_d(pc_r[26]), .dout(c[26]),
        .din({pc[1], pc[2]})); 
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .WIDTH = 2;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x27 (.clk(clk), .thru(thru_r), .thru_d(pc_r[27]), .dout(c[27]),
        .din({pc[0], pc[2], pc[3]})); 
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .WIDTH = 3;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x28 (.clk(clk), .thru(thru_r), .thru_d(pc_r[28]), .dout(c[28]),
        .din({pc[1], pc[3], pc[4]})); 
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .WIDTH = 3;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x29 (.clk(clk), .thru(thru_r), .thru_d(pc_r[29]), .dout(c[29]),
        .din({pc[0], pc[2], pc[4], pc[5]})); 
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .WIDTH = 4;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x30 (.clk(clk), .thru(thru_r), .thru_d(pc_r[30]), .dout(c[30]),
        .din({pc[1], pc[3], pc[5], pc[6]})); 
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .WIDTH = 4;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_t x31 (.clk(clk), .thru(thru_r), .thru_d(pc_r[31]), .dout(c[31]),
        .din({pc[0], pc[2], pc[4], pc[6], pc[7]})); 
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .WIDTH = 5;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

endmodule


// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 118
// BENCHMARK INFO :  Total pins : 66
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 62              ;       ;
// BENCHMARK INFO :  ALMs : 49 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.314 ns, From xor_2tick_t:x27|xor_r:lp[0].xr|dout_r, To xor_2tick_t:x27|xor_r_t:xh|dout_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.352 ns, From thru_r, To xor_2tick_t:x16|xor_r_t:xh|dout_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.363 ns, From thru_r, To xor_2tick_t:x1|xor_r_t:xh|dout_r}
