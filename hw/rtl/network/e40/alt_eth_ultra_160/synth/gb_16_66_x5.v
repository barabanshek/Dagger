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


// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/hsl18/gb_16_66_x5.v#1 $
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
// cnt 00 : in 16 to make 16  no
// cnt 01 : in 16 to make 32  no
// cnt 02 : in 16 to make 48  no
// cnt 03 : in 16 to make 64  no
// cnt 04 : in 16 to make 80  out 66 os 3
// cnt 05 : in 16 to make 30  no
// cnt 06 : to make 30  no
// cnt 07 : in 16 to make 46  no
// cnt 08 : in 16 to make 62  no
// cnt 09 : in 16 to make 78  out 66 os 2
// cnt 0a : in 16 to make 28  no
// cnt 0b : in 16 to make 44  no
// cnt 0c : to make 44  no
// cnt 0d : in 16 to make 60  no
// cnt 0e : in 16 to make 76  out 66 os 1
// cnt 0f : in 16 to make 26  no
// cnt 10 : in 16 to make 42  no
// cnt 11 : in 16 to make 58  no
// cnt 12 : to make 58  no
// cnt 13 : in 16 to make 74  out 66 os 0
// cnt 14 : in 16 to make 24  no
// cnt 15 : in 16 to make 40  no
// cnt 16 : in 16 to make 56  no
// cnt 17 : in 16 to make 72  
// cnt 18 : bump to make 72  out 66 os 3
// cnt 19 : in 16 to make 22  no
// cnt 1a : in 16 to make 38  no
// cnt 1b : in 16 to make 54  no
// cnt 1c : in 16 to make 70  
// cnt 1d : bump to make 70  out 66 os 2
// cnt 1e : in 16 to make 20  no
// cnt 1f : in 16 to make 36  no
// cnt 20 : in 16 to make 52  no
// cnt 21 : in 16 to make 68  
// cnt 22 : bump to make 68  out 66 os 1
// cnt 23 : in 16 to make 18  no
// cnt 24 : in 16 to make 34  no
// cnt 25 : in 16 to make 50  no
// cnt 26 : in 16 to make 66  
// cnt 27 : bump to make 66  out 66 os 0


// shft mask 0000007bdefbefbf
// bump mask 0000008421000000
// out  mask 0000000842108421
// out0 mask 0000000802008020
// out1 mask 0000000042000420


module gb_16_66_x5 #(
    parameter TARGET_CHIP = 2,
    parameter PRE_TICKS = 6
)(
    input clk,
    input [5:0] cnt,
    input [16*5-1:0] din,
    output din_req,
    output pre_din_req,
    output [65:0] dout,
    output dout_zero
);

reg shft_req = 1'b0, bump = 1'b0, shft = 1'b0, out = 1'b0, pre_shft_req = 1'b0;

///////////////////////////////////
// control schedule 

wire bump_w;
wys_lut w1 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(bump_w));
defparam w1 .MASK = 64'h0000008421000000;
defparam w1 .TARGET_CHIP = TARGET_CHIP;

wire shft_w;
wys_lut w2 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(shft_w));
defparam w2 .MASK = 64'h0000007bdefbefbf;
defparam w2 .TARGET_CHIP = TARGET_CHIP;

wire shft_req_w;
wys_lut w0 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(shft_req_w));
defparam w0 .MASK = 64'h000000bdef7df7df;
defparam w0 .TARGET_CHIP = TARGET_CHIP;

wire os0_w;
wys_lut w3 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(os0_w));
defparam w3 .MASK = 64'h0000000802008020;
defparam w3 .TARGET_CHIP = TARGET_CHIP;

wire os1_w;
wys_lut w4 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(os1_w));
defparam w4 .MASK = 64'h0000000042000420;
defparam w4 .TARGET_CHIP = TARGET_CHIP;

wire out_w;
wys_lut w5 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(out_w));
defparam w5 .MASK = 64'h0000000842108421;
defparam w5 .TARGET_CHIP = TARGET_CHIP;

wire pre_shft_req_w;
localparam PRE_SHIFT_MASK = 40'hbdef7df7df;
wys_lut w6 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(pre_shft_req_w));
defparam w6 .MASK = 64'h0 | {PRE_SHIFT_MASK[PRE_TICKS-1:0],PRE_SHIFT_MASK[39:PRE_TICKS]};
defparam w6 .TARGET_CHIP = TARGET_CHIP;

always @(posedge clk) begin
    bump <= bump_w;
    shft <= shft_w;
    shft_req <= shft_req_w;
    pre_shft_req <= pre_shft_req_w;
    //os[0] <= os0_w;
    //os[1] <= os1_w;
    out <= out_w;
end


//// spreading OS for improving timing
wire    [4:0]   os0;
reg_tree os0_rt (
    .clk    (clk),
    .din    (os0_w),
    .dout   (os0)
);
defparam    os0_rt .BRANCH_FACTOR = 5;
defparam    os0_rt .NUM_OUTS = 5;

wire    [4:0]   os1;
reg_tree os1_rt (
    .clk    (clk),
    .din    (os1_w),
    .dout   (os1)
);
defparam    os1_rt .BRANCH_FACTOR = 5;
defparam    os1_rt .NUM_OUTS = 5;



assign din_req = shft_req;
assign pre_din_req = pre_shft_req;

reg [66*5-1:0] dout_i = 0;

/////////////////////////////////////////////////////

reg [79:0] storage0 = 80'h0;
always @(posedge clk) begin
    if (shft) storage0 <= {din[1*16-1:0*16],storage0[79:16]};
    else if (bump) storage0 <= {storage0[79:72],storage0[79:8]};
end

always @(posedge clk) begin
  if (out) begin
    case ({os1[0], os0[0]})
        2'd3 : dout_i[1*66-1:0*66] <= storage0[65:0];
        2'd2 : dout_i[1*66-1:0*66] <= storage0[67:2];
        2'd1 : dout_i[1*66-1:0*66] <= storage0[69:4];
        2'd0 : dout_i[1*66-1:0*66] <= storage0[71:6];
    endcase
  end
end

/////////////////////////////////////////////////////

reg [79:0] storage1 = 80'h0;
always @(posedge clk) begin
    if (shft) storage1 <= {din[2*16-1:1*16],storage1[79:16]};
    else if (bump) storage1 <= {storage1[79:72],storage1[79:8]};
end

always @(posedge clk) begin
  if (out) begin
    case ({os1[1], os0[1]})
        2'd3 : dout_i[2*66-1:1*66] <= storage1[65:0];
        2'd2 : dout_i[2*66-1:1*66] <= storage1[67:2];
        2'd1 : dout_i[2*66-1:1*66] <= storage1[69:4];
        2'd0 : dout_i[2*66-1:1*66] <= storage1[71:6];
    endcase
  end
end

/////////////////////////////////////////////////////

reg [79:0] storage2 = 80'h0;
always @(posedge clk) begin
    if (shft) storage2 <= {din[3*16-1:2*16],storage2[79:16]};
    else if (bump) storage2 <= {storage2[79:72],storage2[79:8]};
end

always @(posedge clk) begin
  if (out) begin
    case ({os1[2], os0[2]})
        2'd3 : dout_i[3*66-1:2*66] <= storage2[65:0];
        2'd2 : dout_i[3*66-1:2*66] <= storage2[67:2];
        2'd1 : dout_i[3*66-1:2*66] <= storage2[69:4];
        2'd0 : dout_i[3*66-1:2*66] <= storage2[71:6];
    endcase
  end
end

/////////////////////////////////////////////////////

reg [79:0] storage3 = 80'h0;
always @(posedge clk) begin
    if (shft) storage3 <= {din[4*16-1:3*16],storage3[79:16]};
    else if (bump) storage3 <= {storage3[79:72],storage3[79:8]};
end

always @(posedge clk) begin
  if (out) begin
    case ({os1[3], os0[3]})
        2'd3 : dout_i[4*66-1:3*66] <= storage3[65:0];
        2'd2 : dout_i[4*66-1:3*66] <= storage3[67:2];
        2'd1 : dout_i[4*66-1:3*66] <= storage3[69:4];
        2'd0 : dout_i[4*66-1:3*66] <= storage3[71:6];
    endcase
  end
end

/////////////////////////////////////////////////////

reg [79:0] storage4 = 80'h0;
always @(posedge clk) begin
    if (shft) storage4 <= {din[5*16-1:4*16],storage4[79:16]};
    else if (bump) storage4 <= {storage4[79:72],storage4[79:8]};
end

always @(posedge clk) begin
  if (out) begin
    case ({os1[4], os0[4]})
        2'd3 : dout_i[5*66-1:4*66] <= storage4[65:0];
        2'd2 : dout_i[5*66-1:4*66] <= storage4[67:2];
        2'd1 : dout_i[5*66-1:4*66] <= storage4[69:4];
        2'd0 : dout_i[5*66-1:4*66] <= storage4[71:6];
    endcase
  end
end

reg [2:0] osel = 0;
always @(posedge clk) begin
    if (out) osel <= 3'b0;
    else osel <= osel + 1'b1;
end

mx5r omx (
    .clk(clk),
    .din(dout_i),
    .sel(osel),
    .dout(dout)
);
defparam omx .WIDTH = 66;

reg dz = 1'b0;
always @(posedge clk) dz <= (osel == 3'b0);
assign dout_zero = dz;

endmodule


// BENCHMARK INFO :  5SGXEA7N2F45C2ES
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Combinational ALUTs : 417
// BENCHMARK INFO :  Memory ALUTs : 0
// BENCHMARK INFO :  Dedicated logic registers : 806
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.430 ns, From storage1[31], To dout_i[91]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.294 ns, From os[1], To dout_i[168]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.384 ns, From os[1], To dout_i[6]}
