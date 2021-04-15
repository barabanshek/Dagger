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

`timescale 1 ps / 1 ps
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

module crc32_d64_sig #(
	parameter TARGET_CHIP = 2
)(
    input clk,
    input [63:0] d, // used left to right, lsbit first per byte
    output [31:0] c
);

xor_2tick x0 (.clk(clk), .dout(c[0]), .din({
        d[1], d[7], d[11], d[13], d[14], 
        d[23], d[24], d[25], d[26], d[27], d[29], 
        d[30], d[31], d[34], d[37], d[39], d[40], 
        d[42], d[43], d[48], d[49], d[50], d[53], 
        d[55], d[56], d[58], d[59], d[61]})); 
defparam x0 .WIDTH = 28;
defparam x0 .TARGET_CHIP = TARGET_CHIP;

xor_2tick x1 (.clk(clk), .dout(c[1]), .din({
        d[0], d[1], d[6], d[7], d[10], 
        d[11], d[12], d[14], d[22], d[23], d[27], 
        d[28], d[31], d[33], d[34], d[36], d[37], 
        d[38], d[40], d[41], d[43], d[50], d[52], 
        d[53], d[54], d[56], d[57], d[59], d[60], 
        d[61], d[63]})); 
defparam x1 .WIDTH = 31;
defparam x1 .TARGET_CHIP = TARGET_CHIP;

xor_2tick x2 (.clk(clk), .dout(c[2]), .din({
        d[0], d[1], d[5], d[6], d[7], 
        d[9], d[10], d[14], d[15], d[21], d[22], 
        d[23], d[24], d[25], d[29], d[31], d[32], 
        d[33], d[34], d[35], d[36], d[39], d[43], 
        d[48], d[50], d[51], d[52], d[60], d[61], 
        d[62]})); 
defparam x2 .WIDTH = 30;
defparam x2 .TARGET_CHIP = TARGET_CHIP;

xor_2tick x3 (.clk(clk), .dout(c[3]), .din({
        d[0], d[4], d[5], d[6], d[8], 
        d[9], d[13], d[14], d[15], d[20], d[21], 
        d[22], d[24], d[28], d[30], d[32], d[33], 
        d[34], d[35], d[38], d[39], d[42], d[47], 
        d[49], d[50], d[51], d[59], d[60], d[61], 
        d[63]})); 
defparam x3 .WIDTH = 30;
defparam x3 .TARGET_CHIP = TARGET_CHIP;

xor_2tick x4 (.clk(clk), .dout(c[4]), .din({
        d[1], d[3], d[4], d[5], d[7], 
        d[8], d[11], d[12], d[15], d[19], d[20], 
        d[21], d[24], d[25], d[26], d[30], d[31], 
        d[32], d[33], d[38], d[40], d[41], d[42], 
        d[43], d[46], d[47], d[53], d[55], d[56], 
        d[60], d[61], d[62]})); 
defparam x4 .WIDTH = 32;
defparam x4 .TARGET_CHIP = TARGET_CHIP;

xor_2tick x5 (.clk(clk), .dout(c[5]), .din({
        d[0], d[1], d[2], d[3], d[4], 
        d[6], d[7], d[10], d[13], d[18], d[19], 
        d[20], d[26], d[27], d[31], d[32], d[34], 
        d[41], d[43], d[45], d[46], d[47], d[48], 
        d[49], d[50], d[52], d[53], d[54], d[56], 
        d[58], d[60]})); 
defparam x5 .WIDTH = 31;
defparam x5 .TARGET_CHIP = TARGET_CHIP;

xor_2tick x6 (.clk(clk), .dout(c[6]), .din({
        d[0], d[1], d[2], d[3], d[5], 
        d[6], d[9], d[12], d[15], d[17], d[18], 
        d[19], d[25], d[26], d[30], d[33], d[40], 
        d[42], d[44], d[45], d[46], d[47], d[48], 
        d[49], d[51], d[52], d[53], d[57], d[59], 
        d[63]})); 
defparam x6 .WIDTH = 30;
defparam x6 .TARGET_CHIP = TARGET_CHIP;

xor_2tick x7 (.clk(clk), .dout(c[7]), .din({
        d[0], d[2], d[4], d[5], d[7], 
        d[8], d[13], d[15], d[16], d[17], d[18], 
        d[23], d[26], d[27], d[30], d[31], d[32], 
        d[34], d[37], d[39], d[40], d[41], d[42], 
        d[44], d[45], d[46], d[49], d[51], d[52], 
        d[53], d[59], d[61], d[62], d[63]})); 
defparam x7 .WIDTH = 34;
defparam x7 .TARGET_CHIP = TARGET_CHIP;

xor_2tick x8 (.clk(clk), .dout(c[8]), .din({
        d[3], d[4], d[6], d[7], d[11], 
        d[12], d[13], d[15], d[16], d[17], d[22], 
        d[24], d[27], d[33], d[34], d[36], d[37], 
        d[38], d[39], d[41], d[42], d[44], d[45], 
        d[47], d[49], d[51], d[52], d[53], d[56], 
        d[59], d[60], d[62]})); 
defparam x8 .WIDTH = 32;
defparam x8 .TARGET_CHIP = TARGET_CHIP;

xor_2tick x9 (.clk(clk), .dout(c[9]), .din({
        d[2], d[3], d[5], d[6], d[10], 
        d[11], d[12], d[14], d[16], d[21], d[26], 
        d[31], d[32], d[33], d[35], d[36], d[37], 
        d[38], d[39], d[40], d[41], d[43], d[44], 
        d[46], d[48], d[50], d[51], d[52], d[58], 
        d[59], d[61]})); 
defparam x9 .WIDTH = 31;
defparam x9 .TARGET_CHIP = TARGET_CHIP;

xor_2tick x10 (.clk(clk), .dout(c[10]), .din({
        d[2], d[4], d[5], d[7], d[9], 
        d[10], d[14], d[20], d[23], d[24], d[26], 
        d[27], d[29], d[32], d[35], d[36], d[38], 
        d[39], d[45], d[47], d[48], d[51], d[53], 
        d[56], d[57], d[59], d[60], d[61], d[63]})); 
defparam x10 .WIDTH = 29;
defparam x10 .TARGET_CHIP = TARGET_CHIP;

xor_2tick x11 (.clk(clk), .dout(c[11]), .din({
        d[3], d[4], d[6], d[7], d[8], 
        d[9], d[11], d[14], d[19], d[22], d[23], 
        d[24], d[27], d[28], d[29], d[30], d[31], 
        d[35], d[38], d[40], d[42], d[43], d[44], 
        d[46], d[47], d[48], d[49], d[52], d[53], 
        d[55], d[60], d[61], d[62], d[63]})); 
defparam x11 .WIDTH = 34;
defparam x11 .TARGET_CHIP = TARGET_CHIP;

xor_2tick x12 (.clk(clk), .dout(c[12]), .din({
        d[1], d[2], d[3], d[5], d[6], 
        d[7], d[8], d[10], d[11], d[14], d[18], 
        d[21], d[22], d[24], d[25], d[28], d[31], 
        d[40], d[41], d[45], d[46], d[49], d[50], 
        d[51], d[52], d[53], d[54], d[56], d[58], 
        d[60], d[62], d[63]})); 
defparam x12 .WIDTH = 32;
defparam x12 .TARGET_CHIP = TARGET_CHIP;

xor_2tick x13 (.clk(clk), .dout(c[13]), .din({
        d[0], d[1], d[2], d[4], d[5], 
        d[6], d[9], d[10], d[13], d[17], d[20], 
        d[21], d[23], d[24], d[27], d[30], d[39], 
        d[40], d[44], d[45], d[48], d[49], d[50], 
        d[51], d[52], d[53], d[55], d[57], d[59], 
        d[61], d[62]})); 
defparam x13 .WIDTH = 31;
defparam x13 .TARGET_CHIP = TARGET_CHIP;

xor_2tick x14 (.clk(clk), .dout(c[14]), .din({
        d[0], d[1], d[3], d[4], d[5], 
        d[8], d[9], d[12], d[15], d[16], d[19], 
        d[20], d[22], d[26], d[29], d[38], d[39], 
        d[43], d[44], d[48], d[49], d[50], d[51], 
        d[52], d[54], d[55], d[56], d[58], d[60], 
        d[61], d[63]})); 
defparam x14 .WIDTH = 31;
defparam x14 .TARGET_CHIP = TARGET_CHIP;

xor_2tick x15 (.clk(clk), .dout(c[15]), .din({
        d[0], d[2], d[3], d[4], d[8], 
        d[11], d[14], d[15], d[18], d[19], d[21], 
        d[23], d[25], d[28], d[31], d[37], d[38], 
        d[42], d[43], d[48], d[49], d[50], d[51], 
        d[53], d[54], d[57], d[59], d[60], d[62], 
        d[63]})); 
defparam x15 .WIDTH = 30;
defparam x15 .TARGET_CHIP = TARGET_CHIP;

xor_2tick x16 (.clk(clk), .dout(c[16]), .din({
        d[2], d[3], d[7], d[10], d[11], 
        d[15], d[17], d[18], d[20], d[22], d[25], 
        d[26], d[29], d[31], d[34], d[36], d[39], 
        d[40], d[41], d[43], d[52], d[55], d[62], 
        d[63]})); 
defparam x16 .WIDTH = 24;
defparam x16 .TARGET_CHIP = TARGET_CHIP;

xor_2tick x17 (.clk(clk), .dout(c[17]), .din({
        d[1], d[2], d[6], d[9], d[10], 
        d[14], d[16], d[17], d[19], d[21], d[24], 
        d[25], d[28], d[30], d[33], d[35], d[38], 
        d[40], d[42], d[51], d[54], d[55], d[61], 
        d[62]})); 
defparam x17 .WIDTH = 24;
defparam x17 .TARGET_CHIP = TARGET_CHIP;


xor_2tick x18 (.clk(clk), .dout(c[18]), .din({
        d[0], d[1], d[5], d[8], d[9], 
        d[13], d[16], d[18], d[20], d[24], d[27], 
        d[29], d[31], d[32], d[34], d[37], d[39], 
        d[41], d[50], d[53], d[54], d[55], d[60], 
        d[61]})); 
defparam x18 .WIDTH = 24;
defparam x18 .TARGET_CHIP = TARGET_CHIP;


xor_2tick x19 (.clk(clk), .dout(c[19]), .din({
        d[0], d[4], d[8], d[12], d[15], 
        d[17], d[19], d[23], d[26], d[28], d[30], 
        d[31], d[33], d[36], d[38], d[39], d[40], 
        d[47], d[49], d[52], d[53], d[54], d[59], 
        d[60]})); 
defparam x19 .WIDTH = 24;
defparam x19 .TARGET_CHIP = TARGET_CHIP;


xor_2tick x20 (.clk(clk), .dout(c[20]), .din({
        d[3], d[11], d[14], d[15], d[16], 
        d[18], d[22], d[23], d[25], d[27], d[29], 
        d[30], d[32], d[35], d[37], d[38], d[46], 
        d[48], d[51], d[52], d[53], d[55], d[58], 
        d[59]})); 
defparam x20 .WIDTH = 24;
defparam x20 .TARGET_CHIP = TARGET_CHIP;


xor_2tick x21 (.clk(clk), .dout(c[21]), .din({
        d[2], d[10], d[13], d[14], d[17], 
        d[21], d[22], d[24], d[26], d[28], d[29], 
        d[31], d[34], d[36], d[37], d[45], d[47], 
        d[50], d[51], d[52], d[54], d[57], d[58], 
        d[63]})); 
defparam x21 .WIDTH = 24;
defparam x21 .TARGET_CHIP = TARGET_CHIP;


xor_2tick x22 (.clk(clk), .dout(c[22]), .din({
        d[7], d[9], d[11], d[12], d[14], 
        d[16], d[20], d[21], d[23], d[24], d[26], 
        d[28], d[29], d[31], d[33], d[34], d[35], 
        d[36], d[37], d[40], d[42], d[43], d[44], 
        d[46], d[48], d[51], d[55], d[57], d[58], 
        d[59], d[61], d[62]})); 
defparam x22 .WIDTH = 32;
defparam x22 .TARGET_CHIP = TARGET_CHIP;


xor_2tick x23 (.clk(clk), .dout(c[23]), .din({
        d[1], d[6], d[7], d[8], d[10], 
        d[14], d[19], d[20], d[22], d[23], d[24], 
        d[26], d[28], d[29], d[32], d[33], d[35], 
        d[36], d[37], d[40], d[41], d[45], d[48], 
        d[49], d[53], d[54], d[57], d[59], d[60], 
        d[63]})); 
defparam x23 .WIDTH = 30;
defparam x23 .TARGET_CHIP = TARGET_CHIP;


xor_2tick x24 (.clk(clk), .dout(c[24]), .din({
        d[0], d[5], d[6], d[9], d[13], 
        d[18], d[19], d[21], d[22], d[23], d[25], 
        d[27], d[28], d[32], d[34], d[35], d[36], 
        d[39], d[40], d[44], d[47], d[48], d[52], 
        d[53], d[55], d[56], d[58], d[59], d[62], 
        d[63]})); 
defparam x24 .WIDTH = 30;
defparam x24 .TARGET_CHIP = TARGET_CHIP;


xor_2tick x25 (.clk(clk), .dout(c[25]), .din({
        d[4], d[5], d[8], d[12], d[15], 
        d[17], d[18], d[20], d[21], d[22], d[24], 
        d[26], d[27], d[33], d[34], d[35], d[38], 
        d[43], d[46], d[47], d[51], d[52], d[54], 
        d[55], d[57], d[58], d[61], d[62], d[63]})); 
defparam x25 .WIDTH = 29;
defparam x25 .TARGET_CHIP = TARGET_CHIP;


xor_2tick x26 (.clk(clk), .dout(c[26]), .din({
        d[1], d[3], d[4], d[7], d[13], 
        d[16], d[17], d[19], d[20], d[21], d[24], 
        d[27], d[29], d[30], d[31], d[32], d[33], 
        d[40], d[43], d[45], d[46], d[48], d[49], 
        d[51], d[54], d[55], d[57], d[58], d[59], 
        d[60], d[62]})); 
defparam x26 .WIDTH = 31;
defparam x26 .TARGET_CHIP = TARGET_CHIP;


xor_2tick x27 (.clk(clk), .dout(c[27]), .din({
        d[0], d[2], d[3], d[6], d[12], 
        d[16], d[18], d[19], d[20], d[26], d[28], 
        d[29], d[30], d[31], d[32], d[39], d[42], 
        d[44], d[45], d[47], d[48], d[50], d[53], 
        d[54], d[55], d[56], d[57], d[58], d[59], 
        d[61], d[63]})); 
defparam x27 .WIDTH = 31;
defparam x27 .TARGET_CHIP = TARGET_CHIP;


xor_2tick x28 (.clk(clk), .dout(c[28]), .din({
        d[1], d[2], d[5], d[11], d[15], 
        d[17], d[18], d[19], d[25], d[27], d[28], 
        d[29], d[30], d[31], d[38], d[41], d[43], 
        d[44], d[46], d[47], d[49], d[52], d[53], 
        d[54], d[56], d[57], d[58], d[60], d[62], 
        d[63]})); 
defparam x28 .WIDTH = 30;
defparam x28 .TARGET_CHIP = TARGET_CHIP;


xor_2tick x29 (.clk(clk), .dout(c[29]), .din({
        d[0], d[1], d[4], d[10], d[14], 
        d[16], d[17], d[18], d[24], d[26], d[27], 
        d[28], d[29], d[30], d[37], d[40], d[42], 
        d[43], d[45], d[46], d[48], d[51], d[52], 
        d[53], d[56], d[57], d[59], d[61], d[62]})); 
defparam x29 .WIDTH = 29;
defparam x29 .TARGET_CHIP = TARGET_CHIP;


xor_2tick x30 (.clk(clk), .dout(c[30]), .din({
        d[0], d[3], d[9], d[13], d[15], 
        d[16], d[17], d[25], d[26], d[27], d[28], 
        d[29], d[31], d[36], d[39], d[41], d[42], 
        d[44], d[45], d[50], d[51], d[52], d[55], 
        d[56], d[58], d[60], d[61], d[63]})); 
defparam x30 .WIDTH = 28;
defparam x30 .TARGET_CHIP = TARGET_CHIP;


xor_2tick x31 (.clk(clk), .dout(c[31]), .din({
        d[2], d[8], d[12], d[14], d[15], 
        d[16], d[24], d[25], d[26], d[27], d[28], 
        d[30], d[31], d[35], d[38], d[40], d[41], 
        d[43], d[44], d[49], d[50], d[51], d[54], 
        d[57], d[59], d[60], d[62]})); 
defparam x31 .WIDTH = 27;
defparam x31 .TARGET_CHIP = TARGET_CHIP;


endmodule



// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 205
// BENCHMARK INFO :  Total pins : 97
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 199             ;       ;
// BENCHMARK INFO :  ALMs : 191 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.482 ns, From xor_2tick:x27|xor_r:lp[3].xr|dout_r, To xor_2tick:x27|xor_r:xh|dout_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.405 ns, From xor_2tick:x10|xor_r:lp[1].xr|dout_r, To xor_2tick:x10|xor_r:xh|dout_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.402 ns, From xor_2tick:x0|xor_r:lp[3].xr|dout_r, To xor_2tick:x0|xor_r:xh|dout_r}
