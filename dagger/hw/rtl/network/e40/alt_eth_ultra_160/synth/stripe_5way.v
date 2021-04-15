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


// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/hsl18/stripe_5way.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
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
// baeckler - 08-18-2012

// outputs 33 times 16 bits times 5 lanes = 40 words every 40 cycles

// shift enable mask is 000000efbdf7defb

/////////////////////////////////  overall schedule
// cntr 00 phase 0 52 52 52 52 52  : load pipe 0 shl 52
// (hiccup)
// cntr 01 phase 1 118 52 52 52 52  : load pipe 1 shl 52
// cntr 02 phase 2 102 102 36 36 36  : load pipe 2 shl 36
// cntr 03 phase 3 86 86 86 20 20  : load pipe 3 shl 20
// cntr 04 phase 4 70 70 70 70 4  : load pipe 4 shl 4
// cntr 05 phase 0 54 54 54 54 54  : load pipe 0 shl 54
// cntr 06 phase 1 104 38 38 38 38  : load pipe 1 shl 38
// (hiccup)
// cntr 07 phase 2 104 104 38 38 38  : load pipe 2 shl 38
// cntr 08 phase 3 88 88 88 22 22  : load pipe 3 shl 22
// cntr 09 phase 4 72 72 72 72 6  : load pipe 4 shl 6
// cntr 0a phase 0 56 56 56 56 56  : load pipe 0 shl 56
// cntr 0b phase 1 106 40 40 40 40  : load pipe 1 shl 40
// (hiccup)
// cntr 0c phase 2 106 106 40 40 40  : load pipe 2 shl 40
// cntr 0d phase 3 90 90 90 24 24  : load pipe 3 shl 24
// cntr 0e phase 4 74 74 74 74 8  : load pipe 4 shl 8
// cntr 0f phase 0 58 58 58 58 58  : load pipe 0 shl 58
// cntr 10 phase 1 108 42 42 42 42  : load pipe 1 shl 42
// cntr 11 phase 2 92 92 26 26 26  : load pipe 2 shl 26
// (hiccup)
// cntr 12 phase 3 92 92 92 26 26  : load pipe 3 shl 26
// cntr 13 phase 4 76 76 76 76 10  : load pipe 4 shl 10
// cntr 14 phase 0 60 60 60 60 60  : load pipe 0 shl 60
// cntr 15 phase 1 110 44 44 44 44  : load pipe 1 shl 44
// cntr 16 phase 2 94 94 28 28 28  : load pipe 2 shl 28
// cntr 17 phase 3 78 78 78 12 12  : load pipe 3 shl 12
// (hiccup)
// cntr 18 phase 4 78 78 78 78 12  : load pipe 4 shl 12
// cntr 19 phase 0 62 62 62 62 62  : load pipe 0 shl 62
// cntr 1a phase 1 112 46 46 46 46  : load pipe 1 shl 46
// cntr 1b phase 2 96 96 30 30 30  : load pipe 2 shl 30
// cntr 1c phase 3 80 80 80 14 14  : load pipe 3 shl 14
// (hiccup)
// cntr 1d phase 4 80 80 80 80 14  : load pipe 4 shl 14
// cntr 1e phase 0 64 64 64 64 64  : load pipe 0 shl 64
// cntr 1f phase 1 114 48 48 48 48  : load pipe 1 shl 48
// cntr 20 phase 2 98 98 32 32 32  : load pipe 2 shl 32
// cntr 21 phase 3 82 82 82 16 16  : load pipe 3 shl 16
// cntr 22 phase 4 66 66 66 66 0  : load pipe 4 shl 0
// (hiccup)
// cntr 23 phase 0 66 66 66 66 66  : load pipe 0 shl 66
// cntr 24 phase 1 116 50 50 50 50  : load pipe 1 shl 50
// cntr 25 phase 2 100 100 34 34 34  : load pipe 2 shl 34
// cntr 26 phase 3 84 84 84 18 18  : load pipe 3 shl 18
// cntr 27 phase 4 68 68 68 68 2  : load pipe 4 shl 2

module stripe_5way #(
    parameter TARGET_CHIP = 2,
    parameter CREATE_TX_SKEW = 1'b0,
    parameter GB_NUMBER = 0
)(
    input clk,
    input shft,
    input [65:0] din, // lsbit first, words 0..4 cyclic
    input [5:0] cnt,
    output [16*5-1:0] dout // lsbit first, words 4..0 parallel
);

reg [2:0] ld_pos = 3'b0;

reg [66+6-1:0] din_shl = 0;
wire [66+14-1:0] din_sh = {din_shl,8'b0};
wire [66+14-1:0] din_ns = {8'b0,din_shl};

always @(posedge clk) begin
  case (ld_pos[1:0])
    2'b00 : din_shl <= {6'b0,din};
    2'b01 : din_shl <= {4'b0,din,2'b0};
    2'b10 : din_shl <= {2'b0,din,4'b0};
    2'b11 : din_shl <= {din,6'b0};
  endcase
end


///////////////////////////////////
// phase 0

shifter_100ge_gbx s0 (
    .clk(clk),
    .din_sh(din_sh),
    .din_ns(din_ns),
    .shft(shft),
    .ld_pos2(ld_pos[2]),
    .cnt(cnt),
    .dout(dout[1*16-1:0*16])
);
defparam s0 .TARGET_CHIP = TARGET_CHIP;
defparam s0 .MAX_SHL = 66;
defparam s0 .LD_MASK = 64'h0000000842108421;
defparam s0 .ADD_SKEW = CREATE_TX_SKEW ? GB_NUMBER*6+5 : 0;

// defparam s0 .S0_MASK = 64'h0000000401004010;
// defparam s0 .S1_MASK = 64'h0000000420004200;
// defparam s0 .S2_MASK = 64'h0000000842100000;

///////////////////////////////////
// phase 1

shifter_100ge_gbx s1 (
    .clk(clk),
    .din_sh(din_sh),
    .din_ns(din_ns),
    .shft(shft),
    .ld_pos2(ld_pos[2]),
    .cnt(cnt),
    .dout(dout[2*16-1:1*16])
);
defparam s1 .TARGET_CHIP = TARGET_CHIP;
defparam s1 .MAX_SHL = 52;
defparam s1 .LD_MASK = 64'h0000001084210842;
defparam s1 .ADD_SKEW = CREATE_TX_SKEW ? GB_NUMBER*6+2 : 0;

// defparam s1 .S0_MASK = 64'h0000000040100401;
// defparam s1 .S1_MASK = 64'h0000000800108001;
// defparam s1 .S2_MASK = 64'h0000001084000002;

///////////////////////////////////
// phase 2

shifter_100ge_gbx s2 (
    .clk(clk),
    .din_sh(din_sh),
    .din_ns(din_ns),
    .shft(shft),
    .ld_pos2(ld_pos[2]),
    .cnt(cnt),
    .dout(dout[3*16-1:2*16])
);
defparam s2 .TARGET_CHIP = TARGET_CHIP;
defparam s2 .MAX_SHL = 40;
defparam s2 .LD_MASK = 64'h0000002108421084;
defparam s2 .ADD_SKEW = CREATE_TX_SKEW ? GB_NUMBER*6+3 : 0;

// defparam s2 .S0_MASK = 64'h0000000080200802;
// defparam s2 .S1_MASK = 64'h0000000084000840;
// defparam s2 .S2_MASK = 64'h0000002000001084;

///////////////////////////////////
// phase 3

shifter_100ge_gbx s3 (
    .clk(clk),
    .din_sh(din_sh),
    .din_ns(din_ns),
    .shft(shft),
    .ld_pos2(ld_pos[2]),
    .cnt(cnt),
    .dout(dout[4*16-1:3*16])
);
defparam s3 .TARGET_CHIP = TARGET_CHIP;
defparam s3 .MAX_SHL = 26;
defparam s3 .LD_MASK = 64'h0000004210842108;
defparam s3 .ADD_SKEW = CREATE_TX_SKEW ? GB_NUMBER*6+4 : 0;

// defparam s3 .S0_MASK = 64'h0000002008020080;
// defparam s3 .S1_MASK = 64'h0000002100021000;
// defparam s3 .S2_MASK = 64'h0000000000042108;

///////////////////////////////////
// phase 4

shifter_100ge_gbx s4 (
    .clk(clk),
    .din_sh(din_sh),
    .din_ns(din_ns),
    .shft(shft),
    .ld_pos2(ld_pos[2]),
    .cnt(cnt),
    .dout(dout[5*16-1:4*16])
);
defparam s4 .TARGET_CHIP = TARGET_CHIP;
defparam s4 .MAX_SHL = 14;
defparam s4 .LD_MASK = 64'h0000008421084210;
defparam s4 .ADD_SKEW = CREATE_TX_SKEW ? GB_NUMBER*6+1 : 0;

// defparam s4 .S0_MASK = 64'h0000004010040100;
// defparam s4 .S1_MASK = 64'h0000000010800108;
// defparam s4 .S2_MASK = 64'h0000000021084000;



///////////////////////////////////
// din shifter schedule 

wire [2:0] ld_pos_w;
wys_lut w1 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(ld_pos_w[2]));
defparam w1 .MASK = 64'h00000038e71c718e;
defparam w1 .TARGET_CHIP = TARGET_CHIP;

wys_lut w2 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(ld_pos_w[1]));
defparam w2 .MASK = 64'h0000002db492db49;
defparam w2 .TARGET_CHIP = TARGET_CHIP;

wys_lut w3 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(ld_pos_w[0]));
defparam w3 .MASK = 64'h00000064d9364d93;
defparam w3 .TARGET_CHIP = TARGET_CHIP;

always @(posedge clk) ld_pos <= ld_pos_w;

endmodule


// BENCHMARK INFO :  5SGXEA7N2F45C2ES
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Combinational ALUTs : 564
// BENCHMARK INFO :  Memory ALUTs : 0
// BENCHMARK INFO :  Dedicated logic registers : 1,008
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.508 ns, From din_shl[16], To shifter_100ge_gbx:s4|ld_active[24]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.389 ns, From ld_pos[0], To din_shl[13]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.355 ns, From ld_pos[2], To shifter_100ge_gbx:s1|ld_active[10]}
