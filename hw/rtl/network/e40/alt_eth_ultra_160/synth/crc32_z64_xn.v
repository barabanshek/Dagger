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

module crc32_z64_xn #(
    parameter TARGET_CHIP = 2,
    parameter REDUCE_LATENCY = 1'b0,
    parameter NUM_EVOS = 1
)(
    input clk,
    input blank,     // zero out, latency 1
    input [31:0] d, // previous CRC, latency 2
    output [31:0] c  // evolved through 64 bits of zero data x 0 rounds
);
generate

/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 1) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[0], d[2], d[5], d[12], d[13], 
            d[15], d[16], d[18], d[21], d[22], d[23], 
            d[26], d[28], d[29], d[31]})); 
    defparam x0 .WIDTH = 15;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[1], d[2], d[3], d[5], d[6], 
            d[12], d[14], d[15], d[17], d[18], d[19], 
            d[21], d[24], d[26], d[27], d[28], d[30], 
            d[31]})); 
    defparam x1 .WIDTH = 18;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[0], d[3], d[4], d[5], d[6], 
            d[7], d[12], d[19], d[20], d[21], d[23], 
            d[25], d[26], d[27]})); 
    defparam x2 .WIDTH = 14;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[0], d[1], d[4], d[5], d[6], 
            d[7], d[8], d[13], d[20], d[21], d[22], 
            d[24], d[26], d[27], d[28]})); 
    defparam x3 .WIDTH = 15;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[1], d[6], d[7], d[8], d[9], 
            d[12], d[13], d[14], d[15], d[16], d[18], 
            d[25], d[26], d[27], d[31]})); 
    defparam x4 .WIDTH = 15;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[5], d[7], d[8], d[9], d[10], 
            d[12], d[14], d[17], d[18], d[19], d[21], 
            d[22], d[23], d[27], d[29], d[31]})); 
    defparam x5 .WIDTH = 16;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[6], d[8], d[9], d[10], d[11], 
            d[13], d[15], d[18], d[19], d[20], d[22], 
            d[23], d[24], d[28], d[30]})); 
    defparam x6 .WIDTH = 15;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[2], d[5], d[7], d[9], 
            d[10], d[11], d[13], d[14], d[15], d[18], 
            d[19], d[20], d[22], d[24], d[25], d[26], 
            d[28]})); 
    defparam x7 .WIDTH = 18;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[0], d[1], d[2], d[3], d[5], 
            d[6], d[8], d[10], d[11], d[13], d[14], 
            d[18], d[19], d[20], d[22], d[25], d[27], 
            d[28], d[31]})); 
    defparam x8 .WIDTH = 19;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[6], d[7], d[9], d[11], d[12], d[14], 
            d[15], d[19], d[20], d[21], d[23], d[26], 
            d[28], d[29]})); 
    defparam x9 .WIDTH = 19;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[1], d[3], d[4], d[7], 
            d[8], d[10], d[18], d[20], d[23], d[24], 
            d[26], d[27], d[28], d[30], d[31]})); 
    defparam x10 .WIDTH = 16;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[1], d[4], d[8], d[9], d[11], 
            d[12], d[13], d[15], d[16], d[18], d[19], 
            d[22], d[23], d[24], d[25], d[26], d[27]})); 
    defparam x11 .WIDTH = 17;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[9], d[10], d[14], d[15], d[17], 
            d[18], d[19], d[20], d[21], d[22], d[24], 
            d[25], d[27], d[29], d[31]})); 
    defparam x12 .WIDTH = 15;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[0], d[10], d[11], d[15], d[16], 
            d[18], d[19], d[20], d[21], d[22], d[23], 
            d[25], d[26], d[28], d[30]})); 
    defparam x13 .WIDTH = 15;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[0], d[1], d[11], d[12], d[16], 
            d[17], d[19], d[20], d[21], d[22], d[23], 
            d[24], d[26], d[27], d[29], d[31]})); 
    defparam x14 .WIDTH = 16;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[1], d[2], d[12], d[13], d[17], 
            d[18], d[20], d[21], d[22], d[23], d[24], 
            d[25], d[27], d[28], d[30]})); 
    defparam x15 .WIDTH = 15;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[0], d[3], d[5], d[12], d[14], 
            d[15], d[16], d[19], d[24], d[25]})); 
    defparam x16 .WIDTH = 10;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[1], d[4], d[6], d[13], d[15], 
            d[16], d[17], d[20], d[25], d[26]})); 
    defparam x17 .WIDTH = 10;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[2], d[5], d[7], d[14], 
            d[16], d[17], d[18], d[21], d[26], d[27]})); 
    defparam x18 .WIDTH = 11;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[0], d[1], d[3], d[6], d[8], 
            d[15], d[17], d[18], d[19], d[22], d[27], 
            d[28]})); 
    defparam x19 .WIDTH = 12;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[1], d[2], d[4], d[7], d[9], 
            d[16], d[18], d[19], d[20], d[23], d[28], 
            d[29]})); 
    defparam x20 .WIDTH = 12;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[2], d[3], d[5], d[8], d[10], 
            d[17], d[19], d[20], d[21], d[24], d[29], 
            d[30]})); 
    defparam x21 .WIDTH = 12;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[2], d[3], d[4], d[5], d[6], 
            d[9], d[11], d[12], d[13], d[15], d[16], 
            d[20], d[23], d[25], d[26], d[28], d[29], 
            d[30]})); 
    defparam x22 .WIDTH = 18;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[2], d[3], d[4], d[6], d[7], 
            d[10], d[14], d[15], d[17], d[18], d[22], 
            d[23], d[24], d[27], d[28], d[30]})); 
    defparam x23 .WIDTH = 16;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[0], d[3], d[4], d[5], d[7], 
            d[8], d[11], d[15], d[16], d[18], d[19], 
            d[23], d[24], d[25], d[28], d[29], d[31]})); 
    defparam x24 .WIDTH = 17;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[1], d[4], d[5], d[6], d[8], 
            d[9], d[12], d[16], d[17], d[19], d[20], 
            d[24], d[25], d[26], d[29], d[30]})); 
    defparam x25 .WIDTH = 16;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[6], d[7], d[9], d[10], d[12], 
            d[15], d[16], d[17], d[20], d[22], d[23], 
            d[25], d[27], d[28], d[29], d[30]})); 
    defparam x26 .WIDTH = 16;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[0], d[7], d[8], d[10], d[11], 
            d[13], d[16], d[17], d[18], d[21], d[23], 
            d[24], d[26], d[28], d[29], d[30], d[31]})); 
    defparam x27 .WIDTH = 17;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[1], d[8], d[9], d[11], d[12], 
            d[14], d[17], d[18], d[19], d[22], d[24], 
            d[25], d[27], d[29], d[30], d[31]})); 
    defparam x28 .WIDTH = 16;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[2], d[9], d[10], d[12], d[13], 
            d[15], d[18], d[19], d[20], d[23], d[25], 
            d[26], d[28], d[30], d[31]})); 
    defparam x29 .WIDTH = 15;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[3], d[10], d[11], d[13], 
            d[14], d[16], d[19], d[20], d[21], d[24], 
            d[26], d[27], d[29], d[31]})); 
    defparam x30 .WIDTH = 15;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[1], d[4], d[11], d[12], d[14], 
            d[15], d[17], d[20], d[21], d[22], d[25], 
            d[27], d[28], d[30]})); 
    defparam x31 .WIDTH = 14;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 2) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[0], d[1], d[2], d[3], d[5], 
            d[7], d[8], d[10], d[14], d[15], d[17], 
            d[18], d[20], d[21], d[22], d[23], d[27], 
            d[29], d[30], d[31]})); 
    defparam x0 .WIDTH = 20;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[4], d[5], d[6], d[7], d[9], 
            d[10], d[11], d[14], d[16], d[17], d[19], 
            d[20], d[24], d[27], d[28], d[29]})); 
    defparam x1 .WIDTH = 16;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[0], d[1], d[2], d[3], d[6], 
            d[11], d[12], d[14], d[22], d[23], d[25], 
            d[27], d[28], d[31]})); 
    defparam x2 .WIDTH = 14;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[1], d[2], d[3], d[4], d[7], 
            d[12], d[13], d[15], d[23], d[24], d[26], 
            d[28], d[29]})); 
    defparam x3 .WIDTH = 13;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[1], d[4], d[7], d[10], d[13], 
            d[15], d[16], d[17], d[18], d[20], d[21], 
            d[22], d[23], d[24], d[25], d[31]})); 
    defparam x4 .WIDTH = 16;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[1], d[3], d[7], d[10], d[11], 
            d[15], d[16], d[19], d[20], d[24], d[25], 
            d[26], d[27], d[29], d[30], d[31]})); 
    defparam x5 .WIDTH = 16;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[2], d[4], d[8], d[11], d[12], 
            d[16], d[17], d[20], d[21], d[25], d[26], 
            d[27], d[28], d[30], d[31]})); 
    defparam x6 .WIDTH = 15;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[1], d[2], d[7], d[8], d[9], 
            d[10], d[12], d[13], d[14], d[15], d[20], 
            d[23], d[26], d[28], d[30]})); 
    defparam x7 .WIDTH = 15;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[1], d[5], d[7], d[9], d[11], 
            d[13], d[16], d[17], d[18], d[20], d[22], 
            d[23], d[24], d[30]})); 
    defparam x8 .WIDTH = 14;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[0], d[2], d[6], d[8], d[10], 
            d[12], d[14], d[17], d[18], d[19], d[21], 
            d[23], d[24], d[25], d[31]})); 
    defparam x9 .WIDTH = 15;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[2], d[5], d[8], d[9], 
            d[10], d[11], d[13], d[14], d[17], d[19], 
            d[21], d[23], d[24], d[25], d[26], d[27], 
            d[29], d[30], d[31]})); 
    defparam x10 .WIDTH = 20;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[2], d[5], d[6], d[7], d[8], 
            d[9], d[11], d[12], d[17], d[21], d[23], 
            d[24], d[25], d[26], d[28], d[29]})); 
    defparam x11 .WIDTH = 16;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[0], d[1], d[2], d[5], d[6], 
            d[9], d[12], d[13], d[14], d[15], d[17], 
            d[20], d[21], d[23], d[24], d[25], d[26], 
            d[31]})); 
    defparam x12 .WIDTH = 18;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[1], d[2], d[3], d[6], d[7], 
            d[10], d[13], d[14], d[15], d[16], d[18], 
            d[21], d[22], d[24], d[25], d[26], d[27]})); 
    defparam x13 .WIDTH = 17;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[0], d[2], d[3], d[4], d[7], 
            d[8], d[11], d[14], d[15], d[16], d[17], 
            d[19], d[22], d[23], d[25], d[26], d[27], 
            d[28]})); 
    defparam x14 .WIDTH = 18;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[1], d[3], d[4], d[5], d[8], 
            d[9], d[12], d[15], d[16], d[17], d[18], 
            d[20], d[23], d[24], d[26], d[27], d[28], 
            d[29]})); 
    defparam x15 .WIDTH = 18;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[1], d[3], d[4], d[6], d[7], 
            d[8], d[9], d[13], d[14], d[15], d[16], 
            d[19], d[20], d[22], d[23], d[24], d[25], 
            d[28], d[31]})); 
    defparam x16 .WIDTH = 19;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[2], d[4], d[5], d[7], d[8], 
            d[9], d[10], d[14], d[15], d[16], d[17], 
            d[20], d[21], d[23], d[24], d[25], d[26], 
            d[29]})); 
    defparam x17 .WIDTH = 18;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[3], d[5], d[6], d[8], 
            d[9], d[10], d[11], d[15], d[16], d[17], 
            d[18], d[21], d[22], d[24], d[25], d[26], 
            d[27], d[30]})); 
    defparam x18 .WIDTH = 19;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[1], d[4], d[6], d[7], d[9], 
            d[10], d[11], d[12], d[16], d[17], d[18], 
            d[19], d[22], d[23], d[25], d[26], d[27], 
            d[28], d[31]})); 
    defparam x19 .WIDTH = 19;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[2], d[5], d[7], d[8], d[10], 
            d[11], d[12], d[13], d[17], d[18], d[19], 
            d[20], d[23], d[24], d[26], d[27], d[28], 
            d[29]})); 
    defparam x20 .WIDTH = 18;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[0], d[3], d[6], d[8], d[9], 
            d[11], d[12], d[13], d[14], d[18], d[19], 
            d[20], d[21], d[24], d[25], d[27], d[28], 
            d[29], d[30]})); 
    defparam x21 .WIDTH = 19;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[2], d[3], d[4], d[5], d[8], 
            d[9], d[12], d[13], d[17], d[18], d[19], 
            d[23], d[25], d[26], d[27], d[28]})); 
    defparam x22 .WIDTH = 16;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[0], d[1], d[2], d[4], d[6], 
            d[7], d[8], d[9], d[13], d[15], d[17], 
            d[19], d[21], d[22], d[23], d[24], d[26], 
            d[28], d[30], d[31]})); 
    defparam x23 .WIDTH = 20;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[1], d[2], d[3], d[5], d[7], 
            d[8], d[9], d[10], d[14], d[16], d[18], 
            d[20], d[22], d[23], d[24], d[25], d[27], 
            d[29], d[31]})); 
    defparam x24 .WIDTH = 19;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[2], d[3], d[4], d[6], d[8], 
            d[9], d[10], d[11], d[15], d[17], d[19], 
            d[21], d[23], d[24], d[25], d[26], d[28], 
            d[30]})); 
    defparam x25 .WIDTH = 18;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[1], d[2], d[4], d[8], d[9], 
            d[11], d[12], d[14], d[15], d[16], d[17], 
            d[21], d[23], d[24], d[25], d[26], d[30]})); 
    defparam x26 .WIDTH = 17;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[0], d[2], d[3], d[5], d[9], 
            d[10], d[12], d[13], d[15], d[16], d[17], 
            d[18], d[22], d[24], d[25], d[26], d[27], 
            d[31]})); 
    defparam x27 .WIDTH = 18;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[1], d[3], d[4], d[6], d[10], 
            d[11], d[13], d[14], d[16], d[17], d[18], 
            d[19], d[23], d[25], d[26], d[27], d[28]})); 
    defparam x28 .WIDTH = 17;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[0], d[2], d[4], d[5], d[7], 
            d[11], d[12], d[14], d[15], d[17], d[18], 
            d[19], d[20], d[24], d[26], d[27], d[28], 
            d[29]})); 
    defparam x29 .WIDTH = 18;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[1], d[3], d[5], d[6], 
            d[8], d[12], d[13], d[15], d[16], d[18], 
            d[19], d[20], d[21], d[25], d[27], d[28], 
            d[29], d[30]})); 
    defparam x30 .WIDTH = 19;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[0], d[1], d[2], d[4], d[6], 
            d[7], d[9], d[13], d[14], d[16], d[17], 
            d[19], d[20], d[21], d[22], d[26], d[28], 
            d[29], d[30], d[31]})); 
    defparam x31 .WIDTH = 20;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 3) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[1], d[2], d[6], d[7], d[9], 
            d[10], d[11], d[12], d[22], d[23], d[26], 
            d[28], d[30], d[31]})); 
    defparam x0 .WIDTH = 14;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[1], d[3], d[6], d[8], d[9], 
            d[13], d[22], d[24], d[26], d[27], d[28], 
            d[29], d[30]})); 
    defparam x1 .WIDTH = 13;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[0], d[1], d[4], d[6], d[11], 
            d[12], d[14], d[22], d[25], d[26], d[27], 
            d[29]})); 
    defparam x2 .WIDTH = 12;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[0], d[1], d[2], d[5], d[7], 
            d[12], d[13], d[15], d[23], d[26], d[27], 
            d[28], d[30]})); 
    defparam x3 .WIDTH = 13;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[3], d[7], d[8], d[9], d[10], 
            d[11], d[12], d[13], d[14], d[16], d[22], 
            d[23], d[24], d[26], d[27], d[29], d[30]})); 
    defparam x4 .WIDTH = 17;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[1], d[2], d[4], d[6], d[7], 
            d[8], d[13], d[14], d[15], d[17], d[22], 
            d[24], d[25], d[26], d[27]})); 
    defparam x5 .WIDTH = 15;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[0], d[2], d[3], d[5], d[7], 
            d[8], d[9], d[14], d[15], d[16], d[18], 
            d[23], d[25], d[26], d[27], d[28]})); 
    defparam x6 .WIDTH = 16;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[2], d[3], d[4], d[7], d[8], 
            d[11], d[12], d[15], d[16], d[17], d[19], 
            d[22], d[23], d[24], d[27], d[29], d[30], 
            d[31]})); 
    defparam x7 .WIDTH = 18;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[6], d[7], d[8], d[10], d[11], 
            d[13], d[16], d[17], d[18], d[20], d[22], 
            d[24], d[25], d[26]})); 
    defparam x8 .WIDTH = 20;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[1], d[2], d[3], d[4], d[5], 
            d[6], d[7], d[8], d[9], d[11], d[12], 
            d[14], d[17], d[18], d[19], d[21], d[23], 
            d[25], d[26], d[27]})); 
    defparam x9 .WIDTH = 20;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[1], d[3], d[4], d[5], 
            d[8], d[11], d[13], d[15], d[18], d[19], 
            d[20], d[23], d[24], d[27], d[30], d[31]})); 
    defparam x10 .WIDTH = 17;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[4], d[5], d[7], d[10], 
            d[11], d[14], d[16], d[19], d[20], d[21], 
            d[22], d[23], d[24], d[25], d[26], d[30]})); 
    defparam x11 .WIDTH = 17;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[2], d[5], d[7], d[8], d[9], 
            d[10], d[15], d[17], d[20], d[21], d[24], 
            d[25], d[27], d[28], d[30]})); 
    defparam x12 .WIDTH = 15;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[3], d[6], d[8], d[9], d[10], 
            d[11], d[16], d[18], d[21], d[22], d[25], 
            d[26], d[28], d[29], d[31]})); 
    defparam x13 .WIDTH = 15;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[0], d[4], d[7], d[9], d[10], 
            d[11], d[12], d[17], d[19], d[22], d[23], 
            d[26], d[27], d[29], d[30]})); 
    defparam x14 .WIDTH = 15;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[0], d[1], d[5], d[8], d[10], 
            d[11], d[12], d[13], d[18], d[20], d[23], 
            d[24], d[27], d[28], d[30], d[31]})); 
    defparam x15 .WIDTH = 16;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[0], d[7], d[10], d[13], d[14], 
            d[19], d[21], d[22], d[23], d[24], d[25], 
            d[26], d[29], d[30]})); 
    defparam x16 .WIDTH = 14;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[1], d[8], d[11], d[14], d[15], 
            d[20], d[22], d[23], d[24], d[25], d[26], 
            d[27], d[30], d[31]})); 
    defparam x17 .WIDTH = 14;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[2], d[9], d[12], d[15], d[16], 
            d[21], d[23], d[24], d[25], d[26], d[27], 
            d[28], d[31]})); 
    defparam x18 .WIDTH = 13;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[0], d[3], d[10], d[13], d[16], 
            d[17], d[22], d[24], d[25], d[26], d[27], 
            d[28], d[29]})); 
    defparam x19 .WIDTH = 13;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[1], d[4], d[11], d[14], 
            d[17], d[18], d[23], d[25], d[26], d[27], 
            d[28], d[29], d[30]})); 
    defparam x20 .WIDTH = 14;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[0], d[1], d[2], d[5], d[12], 
            d[15], d[18], d[19], d[24], d[26], d[27], 
            d[28], d[29], d[30], d[31]})); 
    defparam x21 .WIDTH = 15;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[3], d[7], d[9], d[10], d[11], 
            d[12], d[13], d[16], d[19], d[20], d[22], 
            d[23], d[25], d[26], d[27], d[29]})); 
    defparam x22 .WIDTH = 16;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[0], d[1], d[2], d[4], d[6], 
            d[7], d[8], d[9], d[13], d[14], d[17], 
            d[20], d[21], d[22], d[24], d[27], d[31]})); 
    defparam x23 .WIDTH = 17;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[0], d[1], d[2], d[3], d[5], 
            d[7], d[8], d[9], d[10], d[14], d[15], 
            d[18], d[21], d[22], d[23], d[25], d[28]})); 
    defparam x24 .WIDTH = 17;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[1], d[2], d[3], d[4], d[6], 
            d[8], d[9], d[10], d[11], d[15], d[16], 
            d[19], d[22], d[23], d[24], d[26], d[29]})); 
    defparam x25 .WIDTH = 17;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[0], d[1], d[3], d[4], d[5], 
            d[6], d[16], d[17], d[20], d[22], d[24], 
            d[25], d[26], d[27], d[28], d[31]})); 
    defparam x26 .WIDTH = 16;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[1], d[2], d[4], d[5], d[6], 
            d[7], d[17], d[18], d[21], d[23], d[25], 
            d[26], d[27], d[28], d[29]})); 
    defparam x27 .WIDTH = 15;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[2], d[3], d[5], d[6], d[7], 
            d[8], d[18], d[19], d[22], d[24], d[26], 
            d[27], d[28], d[29], d[30]})); 
    defparam x28 .WIDTH = 15;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[3], d[4], d[6], d[7], d[8], 
            d[9], d[19], d[20], d[23], d[25], d[27], 
            d[28], d[29], d[30], d[31]})); 
    defparam x29 .WIDTH = 15;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[4], d[5], d[7], d[8], 
            d[9], d[10], d[20], d[21], d[24], d[26], 
            d[28], d[29], d[30], d[31]})); 
    defparam x30 .WIDTH = 15;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[0], d[1], d[5], d[6], d[8], 
            d[9], d[10], d[11], d[21], d[22], d[25], 
            d[27], d[29], d[30], d[31]})); 
    defparam x31 .WIDTH = 15;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 4) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[0], d[2], d[3], d[4], d[6], 
            d[10], d[13], d[19], d[24], d[28], d[31]})); 
    defparam x0 .WIDTH = 11;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[0], d[1], d[2], d[5], d[6], 
            d[7], d[10], d[11], d[13], d[14], d[19], 
            d[20], d[24], d[25], d[28], d[29], d[31]})); 
    defparam x1 .WIDTH = 17;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[0], d[1], d[4], d[7], d[8], 
            d[10], d[11], d[12], d[13], d[14], d[15], 
            d[19], d[20], d[21], d[24], d[25], d[26], 
            d[28], d[29], d[30], d[31]})); 
    defparam x2 .WIDTH = 21;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[1], d[2], d[5], d[8], d[9], 
            d[11], d[12], d[13], d[14], d[15], d[16], 
            d[20], d[21], d[22], d[25], d[26], d[27], 
            d[29], d[30], d[31]})); 
    defparam x3 .WIDTH = 20;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[0], d[4], d[9], d[12], d[14], 
            d[15], d[16], d[17], d[19], d[21], d[22], 
            d[23], d[24], d[26], d[27], d[30]})); 
    defparam x4 .WIDTH = 16;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[6], d[15], d[16], d[17], d[18], 
            d[19], d[20], d[22], d[23], d[25], d[27]})); 
    defparam x5 .WIDTH = 17;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[1], d[2], d[3], d[4], d[5], 
            d[6], d[7], d[16], d[17], d[18], d[19], 
            d[20], d[21], d[23], d[24], d[26], d[28]})); 
    defparam x6 .WIDTH = 17;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[5], d[7], d[8], d[10], 
            d[13], d[17], d[18], d[20], d[21], d[22], 
            d[25], d[27], d[28], d[29], d[31]})); 
    defparam x7 .WIDTH = 16;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[1], d[2], d[3], d[4], d[8], 
            d[9], d[10], d[11], d[13], d[14], d[18], 
            d[21], d[22], d[23], d[24], d[26], d[29], 
            d[30], d[31]})); 
    defparam x8 .WIDTH = 19;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[0], d[2], d[3], d[4], d[5], 
            d[9], d[10], d[11], d[12], d[14], d[15], 
            d[19], d[22], d[23], d[24], d[25], d[27], 
            d[30], d[31]})); 
    defparam x9 .WIDTH = 19;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[1], d[2], d[5], d[11], 
            d[12], d[15], d[16], d[19], d[20], d[23], 
            d[25], d[26]})); 
    defparam x10 .WIDTH = 13;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[1], d[4], d[10], d[12], d[16], 
            d[17], d[19], d[20], d[21], d[26], d[27], 
            d[28], d[31]})); 
    defparam x11 .WIDTH = 13;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[3], d[4], d[5], d[6], d[10], 
            d[11], d[17], d[18], d[19], d[20], d[21], 
            d[22], d[24], d[27], d[29], d[31]})); 
    defparam x12 .WIDTH = 16;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[4], d[5], d[6], d[7], d[11], 
            d[12], d[18], d[19], d[20], d[21], d[22], 
            d[23], d[25], d[28], d[30]})); 
    defparam x13 .WIDTH = 15;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[0], d[5], d[6], d[7], d[8], 
            d[12], d[13], d[19], d[20], d[21], d[22], 
            d[23], d[24], d[26], d[29], d[31]})); 
    defparam x14 .WIDTH = 16;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[1], d[6], d[7], d[8], d[9], 
            d[13], d[14], d[20], d[21], d[22], d[23], 
            d[24], d[25], d[27], d[30]})); 
    defparam x15 .WIDTH = 15;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[3], d[4], d[6], d[7], d[8], 
            d[9], d[13], d[14], d[15], d[19], d[21], 
            d[22], d[23], d[25], d[26]})); 
    defparam x16 .WIDTH = 15;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[0], d[4], d[5], d[7], d[8], 
            d[9], d[10], d[14], d[15], d[16], d[20], 
            d[22], d[23], d[24], d[26], d[27]})); 
    defparam x17 .WIDTH = 16;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[1], d[5], d[6], d[8], 
            d[9], d[10], d[11], d[15], d[16], d[17], 
            d[21], d[23], d[24], d[25], d[27], d[28]})); 
    defparam x18 .WIDTH = 17;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[0], d[1], d[2], d[6], d[7], 
            d[9], d[10], d[11], d[12], d[16], d[17], 
            d[18], d[22], d[24], d[25], d[26], d[28], 
            d[29]})); 
    defparam x19 .WIDTH = 18;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[1], d[2], d[3], d[7], 
            d[8], d[10], d[11], d[12], d[13], d[17], 
            d[18], d[19], d[23], d[25], d[26], d[27], 
            d[29], d[30]})); 
    defparam x20 .WIDTH = 19;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[8], d[9], d[11], d[12], d[13], d[14], 
            d[18], d[19], d[20], d[24], d[26], d[27], 
            d[28], d[30], d[31]})); 
    defparam x21 .WIDTH = 20;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[1], d[5], d[6], d[9], d[12], 
            d[14], d[15], d[20], d[21], d[24], d[25], 
            d[27], d[29]})); 
    defparam x22 .WIDTH = 13;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[0], d[3], d[4], d[7], d[15], 
            d[16], d[19], d[21], d[22], d[24], d[25], 
            d[26], d[30], d[31]})); 
    defparam x23 .WIDTH = 14;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[0], d[1], d[4], d[5], d[8], 
            d[16], d[17], d[20], d[22], d[23], d[25], 
            d[26], d[27], d[31]})); 
    defparam x24 .WIDTH = 14;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[1], d[2], d[5], d[6], d[9], 
            d[17], d[18], d[21], d[23], d[24], d[26], 
            d[27], d[28]})); 
    defparam x25 .WIDTH = 13;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[0], d[4], d[7], d[13], d[18], 
            d[22], d[25], d[27], d[29], d[31]})); 
    defparam x26 .WIDTH = 10;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[1], d[5], d[8], d[14], d[19], 
            d[23], d[26], d[28], d[30]})); 
    defparam x27 .WIDTH = 9;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[0], d[2], d[6], d[9], d[15], 
            d[20], d[24], d[27], d[29], d[31]})); 
    defparam x28 .WIDTH = 10;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[0], d[1], d[3], d[7], d[10], 
            d[16], d[21], d[25], d[28], d[30]})); 
    defparam x29 .WIDTH = 10;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[1], d[2], d[4], d[8], 
            d[11], d[17], d[22], d[26], d[29], d[31]})); 
    defparam x30 .WIDTH = 11;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[1], d[2], d[3], d[5], d[9], 
            d[12], d[18], d[23], d[27], d[30]})); 
    defparam x31 .WIDTH = 10;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 5) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[0], d[2], d[4], d[6], d[7], 
            d[8], d[9], d[10], d[11], d[12], d[14], 
            d[15], d[17], d[21], d[22], d[24], d[27], 
            d[29], d[30], d[31]})); 
    defparam x0 .WIDTH = 20;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[1], d[2], d[3], d[4], d[5], 
            d[6], d[13], d[14], d[16], d[17], d[18], 
            d[21], d[23], d[24], d[25], d[27], d[28], 
            d[29]})); 
    defparam x1 .WIDTH = 18;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[0], d[3], d[5], d[8], d[9], 
            d[10], d[11], d[12], d[18], d[19], d[21], 
            d[25], d[26], d[27], d[28], d[31]})); 
    defparam x2 .WIDTH = 16;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[1], d[4], d[6], d[9], d[10], 
            d[11], d[12], d[13], d[19], d[20], d[22], 
            d[26], d[27], d[28], d[29]})); 
    defparam x3 .WIDTH = 15;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[4], d[5], d[6], d[8], d[9], 
            d[13], d[15], d[17], d[20], d[22], d[23], 
            d[24], d[28], d[31]})); 
    defparam x4 .WIDTH = 14;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[0], d[2], d[4], d[5], d[8], 
            d[11], d[12], d[15], d[16], d[17], d[18], 
            d[22], d[23], d[25], d[27], d[30], d[31]})); 
    defparam x5 .WIDTH = 17;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[0], d[1], d[3], d[5], d[6], 
            d[9], d[12], d[13], d[16], d[17], d[18], 
            d[19], d[23], d[24], d[26], d[28], d[31]})); 
    defparam x6 .WIDTH = 17;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[1], d[8], d[9], d[11], 
            d[12], d[13], d[15], d[18], d[19], d[20], 
            d[21], d[22], d[25], d[30], d[31]})); 
    defparam x7 .WIDTH = 16;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[1], d[4], d[6], d[7], d[8], 
            d[11], d[13], d[15], d[16], d[17], d[19], 
            d[20], d[23], d[24], d[26], d[27], d[29], 
            d[30]})); 
    defparam x8 .WIDTH = 18;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[2], d[5], d[7], d[8], d[9], 
            d[12], d[14], d[16], d[17], d[18], d[20], 
            d[21], d[24], d[25], d[27], d[28], d[30], 
            d[31]})); 
    defparam x9 .WIDTH = 18;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[2], d[3], d[4], d[7], d[11], 
            d[12], d[13], d[14], d[18], d[19], d[24], 
            d[25], d[26], d[27], d[28], d[30]})); 
    defparam x10 .WIDTH = 16;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[2], d[3], d[5], d[6], d[7], 
            d[9], d[10], d[11], d[13], d[17], d[19], 
            d[20], d[21], d[22], d[24], d[25], d[26], 
            d[28], d[30]})); 
    defparam x11 .WIDTH = 19;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[2], d[3], d[9], d[15], d[17], 
            d[18], d[20], d[23], d[24], d[25], d[26], 
            d[30]})); 
    defparam x12 .WIDTH = 12;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[3], d[4], d[10], d[16], d[18], 
            d[19], d[21], d[24], d[25], d[26], d[27], 
            d[31]})); 
    defparam x13 .WIDTH = 12;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[4], d[5], d[11], d[17], d[19], 
            d[20], d[22], d[25], d[26], d[27], d[28]})); 
    defparam x14 .WIDTH = 11;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[5], d[6], d[12], d[18], d[20], 
            d[21], d[23], d[26], d[27], d[28], d[29]})); 
    defparam x15 .WIDTH = 11;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[0], d[2], d[4], d[8], d[9], 
            d[10], d[11], d[12], d[13], d[14], d[15], 
            d[17], d[19], d[28], d[31]})); 
    defparam x16 .WIDTH = 15;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[0], d[1], d[3], d[5], d[9], 
            d[10], d[11], d[12], d[13], d[14], d[15], 
            d[16], d[18], d[20], d[29]})); 
    defparam x17 .WIDTH = 15;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[1], d[2], d[4], d[6], 
            d[10], d[11], d[12], d[13], d[14], d[15], 
            d[16], d[17], d[19], d[21], d[30]})); 
    defparam x18 .WIDTH = 16;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[1], d[2], d[3], d[5], d[7], 
            d[11], d[12], d[13], d[14], d[15], d[16], 
            d[17], d[18], d[20], d[22], d[31]})); 
    defparam x19 .WIDTH = 16;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[2], d[3], d[4], d[6], 
            d[8], d[12], d[13], d[14], d[15], d[16], 
            d[17], d[18], d[19], d[21], d[23]})); 
    defparam x20 .WIDTH = 16;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[1], d[3], d[4], d[5], d[7], 
            d[9], d[13], d[14], d[15], d[16], d[17], 
            d[18], d[19], d[20], d[22], d[24]})); 
    defparam x21 .WIDTH = 16;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[5], d[7], d[9], d[11], d[12], 
            d[16], d[18], d[19], d[20], d[22], d[23], 
            d[24], d[25], d[27], d[29], d[30], d[31]})); 
    defparam x22 .WIDTH = 17;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[0], d[2], d[4], d[7], d[9], 
            d[11], d[13], d[14], d[15], d[19], d[20], 
            d[22], d[23], d[25], d[26], d[27], d[28], 
            d[29]})); 
    defparam x23 .WIDTH = 18;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[1], d[3], d[5], d[8], d[10], 
            d[12], d[14], d[15], d[16], d[20], d[21], 
            d[23], d[24], d[26], d[27], d[28], d[29], 
            d[30]})); 
    defparam x24 .WIDTH = 18;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[0], d[2], d[4], d[6], d[9], 
            d[11], d[13], d[15], d[16], d[17], d[21], 
            d[22], d[24], d[25], d[27], d[28], d[29], 
            d[30], d[31]})); 
    defparam x25 .WIDTH = 19;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[6], d[8], d[9], d[11], d[15], 
            d[16], d[18], d[21], d[23], d[24], d[25], 
            d[26], d[27], d[28]})); 
    defparam x26 .WIDTH = 20;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[1], d[2], d[3], d[4], d[5], 
            d[6], d[7], d[9], d[10], d[12], d[16], 
            d[17], d[19], d[22], d[24], d[25], d[26], 
            d[27], d[28], d[29]})); 
    defparam x27 .WIDTH = 20;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[0], d[2], d[3], d[4], d[5], 
            d[6], d[7], d[8], d[10], d[11], d[13], 
            d[17], d[18], d[20], d[23], d[25], d[26], 
            d[27], d[28], d[29], d[30]})); 
    defparam x28 .WIDTH = 21;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[1], d[3], d[4], d[5], d[6], 
            d[7], d[8], d[9], d[11], d[12], d[14], 
            d[18], d[19], d[21], d[24], d[26], d[27], 
            d[28], d[29], d[30], d[31]})); 
    defparam x29 .WIDTH = 21;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[2], d[4], d[5], d[6], 
            d[7], d[8], d[9], d[10], d[12], d[13], 
            d[15], d[19], d[20], d[22], d[25], d[27], 
            d[28], d[29], d[30], d[31]})); 
    defparam x30 .WIDTH = 21;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[1], d[3], d[5], d[6], d[7], 
            d[8], d[9], d[10], d[11], d[13], d[14], 
            d[16], d[20], d[21], d[23], d[26], d[28], 
            d[29], d[30], d[31]})); 
    defparam x31 .WIDTH = 20;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 6) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[1], d[5], d[6], d[7], d[10], 
            d[11], d[14], d[16], d[17], d[20], d[22], 
            d[24], d[26], d[29]})); 
    defparam x0 .WIDTH = 14;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[1], d[2], d[5], d[8], d[10], 
            d[12], d[14], d[15], d[16], d[18], d[20], 
            d[21], d[22], d[23], d[24], d[25], d[26], 
            d[27], d[29], d[30]})); 
    defparam x1 .WIDTH = 20;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[1], d[2], d[3], d[5], d[7], 
            d[9], d[10], d[13], d[14], d[15], d[19], 
            d[20], d[21], d[23], d[25], d[27], d[28], 
            d[29], d[30], d[31]})); 
    defparam x2 .WIDTH = 20;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[0], d[2], d[3], d[4], d[6], 
            d[8], d[10], d[11], d[14], d[15], d[16], 
            d[20], d[21], d[22], d[24], d[26], d[28], 
            d[29], d[30], d[31]})); 
    defparam x3 .WIDTH = 20;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[3], d[4], d[6], d[9], d[10], 
            d[12], d[14], d[15], d[20], d[21], d[23], 
            d[24], d[25], d[26], d[27], d[30], d[31]})); 
    defparam x4 .WIDTH = 17;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[0], d[1], d[4], d[6], d[13], 
            d[14], d[15], d[17], d[20], d[21], d[25], 
            d[27], d[28], d[29], d[31]})); 
    defparam x5 .WIDTH = 15;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[1], d[2], d[5], d[7], d[14], 
            d[15], d[16], d[18], d[21], d[22], d[26], 
            d[28], d[29], d[30]})); 
    defparam x6 .WIDTH = 14;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[1], d[2], d[3], d[5], 
            d[7], d[8], d[10], d[11], d[14], d[15], 
            d[19], d[20], d[23], d[24], d[26], d[27], 
            d[30], d[31]})); 
    defparam x7 .WIDTH = 19;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[2], d[3], d[4], d[5], d[7], 
            d[8], d[9], d[10], d[12], d[14], d[15], 
            d[17], d[21], d[22], d[25], d[26], d[27], 
            d[28], d[29], d[31]})); 
    defparam x8 .WIDTH = 20;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[3], d[4], d[5], d[6], d[8], 
            d[9], d[10], d[11], d[13], d[15], d[16], 
            d[18], d[22], d[23], d[26], d[27], d[28], 
            d[29], d[30]})); 
    defparam x9 .WIDTH = 19;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[1], d[4], d[9], d[12], d[19], 
            d[20], d[22], d[23], d[26], d[27], d[28], 
            d[30], d[31]})); 
    defparam x10 .WIDTH = 13;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[1], d[2], d[6], d[7], 
            d[11], d[13], d[14], d[16], d[17], d[21], 
            d[22], d[23], d[26], d[27], d[28], d[31]})); 
    defparam x11 .WIDTH = 17;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[2], d[3], d[5], d[6], d[8], 
            d[10], d[11], d[12], d[15], d[16], d[18], 
            d[20], d[23], d[26], d[27], d[28]})); 
    defparam x12 .WIDTH = 16;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[0], d[3], d[4], d[6], d[7], 
            d[9], d[11], d[12], d[13], d[16], d[17], 
            d[19], d[21], d[24], d[27], d[28], d[29]})); 
    defparam x13 .WIDTH = 17;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[1], d[4], d[5], d[7], d[8], 
            d[10], d[12], d[13], d[14], d[17], d[18], 
            d[20], d[22], d[25], d[28], d[29], d[30]})); 
    defparam x14 .WIDTH = 17;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[2], d[5], d[6], d[8], d[9], 
            d[11], d[13], d[14], d[15], d[18], d[19], 
            d[21], d[23], d[26], d[29], d[30], d[31]})); 
    defparam x15 .WIDTH = 17;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[1], d[3], d[5], d[9], d[11], 
            d[12], d[15], d[17], d[19], d[26], d[27], 
            d[29], d[30], d[31]})); 
    defparam x16 .WIDTH = 14;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[2], d[4], d[6], d[10], d[12], 
            d[13], d[16], d[18], d[20], d[27], d[28], 
            d[30], d[31]})); 
    defparam x17 .WIDTH = 13;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[3], d[5], d[7], d[11], d[13], 
            d[14], d[17], d[19], d[21], d[28], d[29], 
            d[31]})); 
    defparam x18 .WIDTH = 12;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[0], d[4], d[6], d[8], d[12], 
            d[14], d[15], d[18], d[20], d[22], d[29], 
            d[30]})); 
    defparam x19 .WIDTH = 12;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[1], d[5], d[7], d[9], 
            d[13], d[15], d[16], d[19], d[21], d[23], 
            d[30], d[31]})); 
    defparam x20 .WIDTH = 13;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[0], d[1], d[2], d[6], d[8], 
            d[10], d[14], d[16], d[17], d[20], d[22], 
            d[24], d[31]})); 
    defparam x21 .WIDTH = 13;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[2], d[3], d[5], d[6], d[9], 
            d[10], d[14], d[15], d[16], d[18], d[20], 
            d[21], d[22], d[23], d[24], d[25], d[26], 
            d[29]})); 
    defparam x22 .WIDTH = 18;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[1], d[3], d[4], d[5], d[14], 
            d[15], d[19], d[20], d[21], d[23], d[25], 
            d[27], d[29], d[30]})); 
    defparam x23 .WIDTH = 14;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[2], d[4], d[5], d[6], d[15], 
            d[16], d[20], d[21], d[22], d[24], d[26], 
            d[28], d[30], d[31]})); 
    defparam x24 .WIDTH = 14;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[3], d[5], d[6], d[7], d[16], 
            d[17], d[21], d[22], d[23], d[25], d[27], 
            d[29], d[31]})); 
    defparam x25 .WIDTH = 13;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[0], d[1], d[4], d[5], d[8], 
            d[10], d[11], d[14], d[16], d[18], d[20], 
            d[23], d[28], d[29], d[30]})); 
    defparam x26 .WIDTH = 15;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[0], d[1], d[2], d[5], d[6], 
            d[9], d[11], d[12], d[15], d[17], d[19], 
            d[21], d[24], d[29], d[30], d[31]})); 
    defparam x27 .WIDTH = 16;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[1], d[2], d[3], d[6], d[7], 
            d[10], d[12], d[13], d[16], d[18], d[20], 
            d[22], d[25], d[30], d[31]})); 
    defparam x28 .WIDTH = 15;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[2], d[3], d[4], d[7], d[8], 
            d[11], d[13], d[14], d[17], d[19], d[21], 
            d[23], d[26], d[31]})); 
    defparam x29 .WIDTH = 14;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[3], d[4], d[5], d[8], d[9], 
            d[12], d[14], d[15], d[18], d[20], d[22], 
            d[24], d[27]})); 
    defparam x30 .WIDTH = 13;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[0], d[4], d[5], d[6], d[9], 
            d[10], d[13], d[15], d[16], d[19], d[21], 
            d[23], d[25], d[28]})); 
    defparam x31 .WIDTH = 14;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 7) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[0], d[2], d[3], d[6], d[8], 
            d[17], d[18], d[20], d[21], d[28]})); 
    defparam x0 .WIDTH = 10;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[0], d[1], d[2], d[4], d[6], 
            d[7], d[8], d[9], d[17], d[19], d[20], 
            d[22], d[28], d[29]})); 
    defparam x1 .WIDTH = 14;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[1], d[5], d[6], d[7], d[9], 
            d[10], d[17], d[23], d[28], d[29], d[30]})); 
    defparam x2 .WIDTH = 11;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[0], d[2], d[6], d[7], d[8], 
            d[10], d[11], d[18], d[24], d[29], d[30], 
            d[31]})); 
    defparam x3 .WIDTH = 12;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[0], d[1], d[2], d[6], d[7], 
            d[9], d[11], d[12], d[17], d[18], d[19], 
            d[20], d[21], d[25], d[28], d[30], d[31]})); 
    defparam x4 .WIDTH = 17;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[1], d[6], d[7], d[10], d[12], 
            d[13], d[17], d[19], d[22], d[26], d[28], 
            d[29], d[31]})); 
    defparam x5 .WIDTH = 13;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[2], d[7], d[8], d[11], d[13], 
            d[14], d[18], d[20], d[23], d[27], d[29], 
            d[30]})); 
    defparam x6 .WIDTH = 12;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[2], d[6], d[9], d[12], 
            d[14], d[15], d[17], d[18], d[19], d[20], 
            d[24], d[30], d[31]})); 
    defparam x7 .WIDTH = 14;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[1], d[2], d[6], d[7], d[8], 
            d[10], d[13], d[15], d[16], d[17], d[19], 
            d[25], d[28], d[31]})); 
    defparam x8 .WIDTH = 14;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[0], d[2], d[3], d[7], d[8], 
            d[9], d[11], d[14], d[16], d[17], d[18], 
            d[20], d[26], d[29]})); 
    defparam x9 .WIDTH = 14;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[1], d[2], d[4], d[6], d[9], 
            d[10], d[12], d[15], d[19], d[20], d[27], 
            d[28], d[30]})); 
    defparam x10 .WIDTH = 13;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[5], d[6], d[7], d[8], 
            d[10], d[11], d[13], d[16], d[17], d[18], 
            d[29], d[31]})); 
    defparam x11 .WIDTH = 13;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[0], d[1], d[2], d[3], d[7], 
            d[9], d[11], d[12], d[14], d[19], d[20], 
            d[21], d[28], d[30]})); 
    defparam x12 .WIDTH = 14;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[8], d[10], d[12], d[13], d[15], d[20], 
            d[21], d[22], d[29], d[31]})); 
    defparam x13 .WIDTH = 15;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[9], d[11], d[13], d[14], d[16], 
            d[21], d[22], d[23], d[30]})); 
    defparam x14 .WIDTH = 15;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[1], d[2], d[3], d[4], d[5], 
            d[6], d[10], d[12], d[14], d[15], d[17], 
            d[22], d[23], d[24], d[31]})); 
    defparam x15 .WIDTH = 15;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[0], d[4], d[5], d[7], d[8], 
            d[11], d[13], d[15], d[16], d[17], d[20], 
            d[21], d[23], d[24], d[25], d[28]})); 
    defparam x16 .WIDTH = 16;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[0], d[1], d[5], d[6], d[8], 
            d[9], d[12], d[14], d[16], d[17], d[18], 
            d[21], d[22], d[24], d[25], d[26], d[29]})); 
    defparam x17 .WIDTH = 17;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[1], d[2], d[6], d[7], 
            d[9], d[10], d[13], d[15], d[17], d[18], 
            d[19], d[22], d[23], d[25], d[26], d[27], 
            d[30]})); 
    defparam x18 .WIDTH = 18;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[0], d[1], d[2], d[3], d[7], 
            d[8], d[10], d[11], d[14], d[16], d[18], 
            d[19], d[20], d[23], d[24], d[26], d[27], 
            d[28], d[31]})); 
    defparam x19 .WIDTH = 19;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[8], d[9], d[11], d[12], d[15], d[17], 
            d[19], d[20], d[21], d[24], d[25], d[27], 
            d[28], d[29]})); 
    defparam x20 .WIDTH = 19;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[9], d[10], d[12], d[13], d[16], 
            d[18], d[20], d[21], d[22], d[25], d[26], 
            d[28], d[29], d[30]})); 
    defparam x21 .WIDTH = 20;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[1], d[4], d[5], d[8], d[10], 
            d[11], d[13], d[14], d[18], d[19], d[20], 
            d[22], d[23], d[26], d[27], d[28], d[29], 
            d[30], d[31]})); 
    defparam x22 .WIDTH = 19;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[0], d[3], d[5], d[8], d[9], 
            d[11], d[12], d[14], d[15], d[17], d[18], 
            d[19], d[23], d[24], d[27], d[29], d[30], 
            d[31]})); 
    defparam x23 .WIDTH = 18;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[1], d[4], d[6], d[9], d[10], 
            d[12], d[13], d[15], d[16], d[18], d[19], 
            d[20], d[24], d[25], d[28], d[30], d[31]})); 
    defparam x24 .WIDTH = 17;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[2], d[5], d[7], d[10], d[11], 
            d[13], d[14], d[16], d[17], d[19], d[20], 
            d[21], d[25], d[26], d[29], d[31]})); 
    defparam x25 .WIDTH = 16;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[0], d[2], d[11], d[12], d[14], 
            d[15], d[22], d[26], d[27], d[28], d[30]})); 
    defparam x26 .WIDTH = 11;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[1], d[3], d[12], d[13], d[15], 
            d[16], d[23], d[27], d[28], d[29], d[31]})); 
    defparam x27 .WIDTH = 11;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[2], d[4], d[13], d[14], d[16], 
            d[17], d[24], d[28], d[29], d[30]})); 
    defparam x28 .WIDTH = 10;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[0], d[3], d[5], d[14], d[15], 
            d[17], d[18], d[25], d[29], d[30], d[31]})); 
    defparam x29 .WIDTH = 11;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[1], d[4], d[6], d[15], 
            d[16], d[18], d[19], d[26], d[30], d[31]})); 
    defparam x30 .WIDTH = 11;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[1], d[2], d[5], d[7], d[16], 
            d[17], d[19], d[20], d[27], d[31]})); 
    defparam x31 .WIDTH = 10;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 8) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[0], d[1], d[2], d[3], d[6], 
            d[8], d[9], d[10], d[11], d[12], d[13], 
            d[14], d[15], d[20], d[21], d[22], d[26], 
            d[27], d[28], d[30], d[31]})); 
    defparam x0 .WIDTH = 21;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[4], d[6], d[7], d[8], d[16], 
            d[20], d[23], d[26], d[29], d[30]})); 
    defparam x1 .WIDTH = 10;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[1], d[2], d[3], d[5], d[6], 
            d[7], d[10], d[11], d[12], d[13], d[14], 
            d[15], d[17], d[20], d[22], d[24], d[26], 
            d[28]})); 
    defparam x2 .WIDTH = 18;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[2], d[3], d[4], d[6], d[7], 
            d[8], d[11], d[12], d[13], d[14], d[15], 
            d[16], d[18], d[21], d[23], d[25], d[27], 
            d[29]})); 
    defparam x3 .WIDTH = 18;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[0], d[1], d[2], d[4], d[5], 
            d[6], d[7], d[10], d[11], d[16], d[17], 
            d[19], d[20], d[21], d[24], d[27], d[31]})); 
    defparam x4 .WIDTH = 17;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[5], d[7], d[9], d[10], d[13], 
            d[14], d[15], d[17], d[18], d[25], d[26], 
            d[27], d[30], d[31]})); 
    defparam x5 .WIDTH = 14;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[6], d[8], d[10], d[11], d[14], 
            d[15], d[16], d[18], d[19], d[26], d[27], 
            d[28], d[31]})); 
    defparam x6 .WIDTH = 13;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[1], d[2], d[3], d[6], d[7], 
            d[8], d[10], d[13], d[14], d[16], d[17], 
            d[19], d[21], d[22], d[26], d[29], d[30], 
            d[31]})); 
    defparam x7 .WIDTH = 18;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[0], d[1], d[4], d[6], d[7], 
            d[10], d[12], d[13], d[17], d[18], d[21], 
            d[23], d[26], d[28]})); 
    defparam x8 .WIDTH = 14;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[0], d[1], d[2], d[5], d[7], 
            d[8], d[11], d[13], d[14], d[18], d[19], 
            d[22], d[24], d[27], d[29]})); 
    defparam x9 .WIDTH = 15;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[10], d[11], d[13], d[19], d[21], 
            d[22], d[23], d[25], d[26], d[27], d[31]})); 
    defparam x10 .WIDTH = 11;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[1], d[2], d[3], d[6], 
            d[8], d[9], d[10], d[13], d[15], d[21], 
            d[23], d[24], d[30], d[31]})); 
    defparam x11 .WIDTH = 15;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[4], d[6], d[7], d[8], d[12], 
            d[13], d[15], d[16], d[20], d[21], d[24], 
            d[25], d[26], d[27], d[28], d[30]})); 
    defparam x12 .WIDTH = 16;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[5], d[7], d[8], d[9], d[13], 
            d[14], d[16], d[17], d[21], d[22], d[25], 
            d[26], d[27], d[28], d[29], d[31]})); 
    defparam x13 .WIDTH = 16;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[6], d[8], d[9], d[10], d[14], 
            d[15], d[17], d[18], d[22], d[23], d[26], 
            d[27], d[28], d[29], d[30]})); 
    defparam x14 .WIDTH = 15;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[0], d[7], d[9], d[10], d[11], 
            d[15], d[16], d[18], d[19], d[23], d[24], 
            d[27], d[28], d[29], d[30], d[31]})); 
    defparam x15 .WIDTH = 16;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[2], d[3], d[6], d[9], d[13], 
            d[14], d[15], d[16], d[17], d[19], d[21], 
            d[22], d[24], d[25], d[26], d[27], d[29]})); 
    defparam x16 .WIDTH = 17;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[0], d[3], d[4], d[7], d[10], 
            d[14], d[15], d[16], d[17], d[18], d[20], 
            d[22], d[23], d[25], d[26], d[27], d[28], 
            d[30]})); 
    defparam x17 .WIDTH = 18;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[1], d[4], d[5], d[8], d[11], 
            d[15], d[16], d[17], d[18], d[19], d[21], 
            d[23], d[24], d[26], d[27], d[28], d[29], 
            d[31]})); 
    defparam x18 .WIDTH = 18;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[2], d[5], d[6], d[9], d[12], 
            d[16], d[17], d[18], d[19], d[20], d[22], 
            d[24], d[25], d[27], d[28], d[29], d[30]})); 
    defparam x19 .WIDTH = 17;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[3], d[6], d[7], d[10], d[13], 
            d[17], d[18], d[19], d[20], d[21], d[23], 
            d[25], d[26], d[28], d[29], d[30], d[31]})); 
    defparam x20 .WIDTH = 17;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[0], d[4], d[7], d[8], d[11], 
            d[14], d[18], d[19], d[20], d[21], d[22], 
            d[24], d[26], d[27], d[29], d[30], d[31]})); 
    defparam x21 .WIDTH = 17;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[2], d[3], d[5], d[6], d[10], 
            d[11], d[13], d[14], d[19], d[23], d[25], 
            d[26]})); 
    defparam x22 .WIDTH = 12;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[1], d[2], d[4], d[7], d[8], 
            d[9], d[10], d[13], d[21], d[22], d[24], 
            d[28], d[30], d[31]})); 
    defparam x23 .WIDTH = 14;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[2], d[3], d[5], d[8], d[9], 
            d[10], d[11], d[14], d[22], d[23], d[25], 
            d[29], d[31]})); 
    defparam x24 .WIDTH = 13;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[0], d[3], d[4], d[6], d[9], 
            d[10], d[11], d[12], d[15], d[23], d[24], 
            d[26], d[30]})); 
    defparam x25 .WIDTH = 13;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[0], d[2], d[3], d[4], d[5], 
            d[6], d[7], d[8], d[9], d[14], d[15], 
            d[16], d[20], d[21], d[22], d[24], d[25], 
            d[26], d[28], d[30]})); 
    defparam x26 .WIDTH = 20;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[1], d[3], d[4], d[5], d[6], 
            d[7], d[8], d[9], d[10], d[15], d[16], 
            d[17], d[21], d[22], d[23], d[25], d[26], 
            d[27], d[29], d[31]})); 
    defparam x27 .WIDTH = 20;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[2], d[4], d[5], d[6], d[7], 
            d[8], d[9], d[10], d[11], d[16], d[17], 
            d[18], d[22], d[23], d[24], d[26], d[27], 
            d[28], d[30]})); 
    defparam x28 .WIDTH = 19;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[0], d[3], d[5], d[6], d[7], 
            d[8], d[9], d[10], d[11], d[12], d[17], 
            d[18], d[19], d[23], d[24], d[25], d[27], 
            d[28], d[29], d[31]})); 
    defparam x29 .WIDTH = 20;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[1], d[4], d[6], d[7], 
            d[8], d[9], d[10], d[11], d[12], d[13], 
            d[18], d[19], d[20], d[24], d[25], d[26], 
            d[28], d[29], d[30]})); 
    defparam x30 .WIDTH = 20;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[0], d[1], d[2], d[5], d[7], 
            d[8], d[9], d[10], d[11], d[12], d[13], 
            d[14], d[19], d[20], d[21], d[25], d[26], 
            d[27], d[29], d[30], d[31]})); 
    defparam x31 .WIDTH = 21;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 9) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[1], d[5], d[7], d[10], d[11], 
            d[12], d[13], d[14], d[16], d[17], d[19], 
            d[21], d[23], d[27], d[29], d[30], d[31]})); 
    defparam x0 .WIDTH = 17;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[1], d[2], d[5], d[6], d[7], 
            d[8], d[10], d[15], d[16], d[18], d[19], 
            d[20], d[21], d[22], d[23], d[24], d[27], 
            d[28], d[29]})); 
    defparam x1 .WIDTH = 19;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[0], d[1], d[2], d[3], d[5], 
            d[6], d[8], d[9], d[10], d[12], d[13], 
            d[14], d[20], d[22], d[24], d[25], d[27], 
            d[28], d[31]})); 
    defparam x2 .WIDTH = 19;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[6], d[7], d[9], d[10], d[11], d[13], 
            d[14], d[15], d[21], d[23], d[25], d[26], 
            d[28], d[29]})); 
    defparam x3 .WIDTH = 19;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[2], d[3], d[4], d[8], d[13], 
            d[15], d[17], d[19], d[21], d[22], d[23], 
            d[24], d[26], d[31]})); 
    defparam x4 .WIDTH = 14;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[1], d[3], d[4], d[7], d[9], 
            d[10], d[11], d[12], d[13], d[17], d[18], 
            d[19], d[20], d[21], d[22], d[24], d[25], 
            d[29], d[30], d[31]})); 
    defparam x5 .WIDTH = 20;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[0], d[2], d[4], d[5], d[8], 
            d[10], d[11], d[12], d[13], d[14], d[18], 
            d[19], d[20], d[21], d[22], d[23], d[25], 
            d[26], d[30], d[31]})); 
    defparam x6 .WIDTH = 20;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[3], d[6], d[7], d[9], d[10], 
            d[15], d[16], d[17], d[20], d[22], d[24], 
            d[26], d[29], d[30]})); 
    defparam x7 .WIDTH = 14;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[0], d[1], d[4], d[5], d[8], 
            d[12], d[13], d[14], d[18], d[19], d[25], 
            d[29]})); 
    defparam x8 .WIDTH = 12;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[1], d[2], d[5], d[6], d[9], 
            d[13], d[14], d[15], d[19], d[20], d[26], 
            d[30]})); 
    defparam x9 .WIDTH = 12;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[1], d[2], d[3], d[5], d[6], 
            d[11], d[12], d[13], d[15], d[17], d[19], 
            d[20], d[23], d[29], d[30]})); 
    defparam x10 .WIDTH = 15;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[6], d[10], d[11], d[17], d[18], 
            d[19], d[20], d[23], d[24], d[27], d[29]})); 
    defparam x11 .WIDTH = 17;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[0], d[2], d[3], d[4], d[6], 
            d[10], d[13], d[14], d[16], d[17], d[18], 
            d[20], d[23], d[24], d[25], d[27], d[28], 
            d[29], d[31]})); 
    defparam x12 .WIDTH = 19;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[0], d[1], d[3], d[4], d[5], 
            d[7], d[11], d[14], d[15], d[17], d[18], 
            d[19], d[21], d[24], d[25], d[26], d[28], 
            d[29], d[30]})); 
    defparam x13 .WIDTH = 19;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[0], d[1], d[2], d[4], d[5], 
            d[6], d[8], d[12], d[15], d[16], d[18], 
            d[19], d[20], d[22], d[25], d[26], d[27], 
            d[29], d[30], d[31]})); 
    defparam x14 .WIDTH = 20;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[1], d[2], d[3], d[5], d[6], 
            d[7], d[9], d[13], d[16], d[17], d[19], 
            d[20], d[21], d[23], d[26], d[27], d[28], 
            d[30], d[31]})); 
    defparam x15 .WIDTH = 19;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[6], d[8], d[11], d[12], d[13], 
            d[16], d[18], d[19], d[20], d[22], d[23], 
            d[24], d[28], d[30]})); 
    defparam x16 .WIDTH = 20;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[6], d[7], d[9], d[12], d[13], 
            d[14], d[17], d[19], d[20], d[21], d[23], 
            d[24], d[25], d[29], d[31]})); 
    defparam x17 .WIDTH = 21;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[1], d[2], d[3], d[4], d[5], 
            d[6], d[7], d[8], d[10], d[13], d[14], 
            d[15], d[18], d[20], d[21], d[22], d[24], 
            d[25], d[26], d[30]})); 
    defparam x18 .WIDTH = 20;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[2], d[3], d[4], d[5], d[6], 
            d[7], d[8], d[9], d[11], d[14], d[15], 
            d[16], d[19], d[21], d[22], d[23], d[25], 
            d[26], d[27], d[31]})); 
    defparam x19 .WIDTH = 20;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[3], d[4], d[5], d[6], 
            d[7], d[8], d[9], d[10], d[12], d[15], 
            d[16], d[17], d[20], d[22], d[23], d[24], 
            d[26], d[27], d[28]})); 
    defparam x20 .WIDTH = 20;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[0], d[1], d[4], d[5], d[6], 
            d[7], d[8], d[9], d[10], d[11], d[13], 
            d[16], d[17], d[18], d[21], d[23], d[24], 
            d[25], d[27], d[28], d[29]})); 
    defparam x21 .WIDTH = 21;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[2], d[6], d[8], d[9], d[13], 
            d[16], d[18], d[21], d[22], d[23], d[24], 
            d[25], d[26], d[27], d[28], d[31]})); 
    defparam x22 .WIDTH = 16;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[1], d[3], d[5], d[9], d[11], 
            d[12], d[13], d[16], d[21], d[22], d[24], 
            d[25], d[26], d[28], d[30], d[31]})); 
    defparam x23 .WIDTH = 16;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[2], d[4], d[6], d[10], d[12], 
            d[13], d[14], d[17], d[22], d[23], d[25], 
            d[26], d[27], d[29], d[31]})); 
    defparam x24 .WIDTH = 15;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[3], d[5], d[7], d[11], d[13], 
            d[14], d[15], d[18], d[23], d[24], d[26], 
            d[27], d[28], d[30]})); 
    defparam x25 .WIDTH = 14;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[1], d[4], d[5], d[6], d[7], 
            d[8], d[10], d[11], d[13], d[15], d[17], 
            d[21], d[23], d[24], d[25], d[28], d[30]})); 
    defparam x26 .WIDTH = 17;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[0], d[2], d[5], d[6], d[7], 
            d[8], d[9], d[11], d[12], d[14], d[16], 
            d[18], d[22], d[24], d[25], d[26], d[29], 
            d[31]})); 
    defparam x27 .WIDTH = 18;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[1], d[3], d[6], d[7], d[8], 
            d[9], d[10], d[12], d[13], d[15], d[17], 
            d[19], d[23], d[25], d[26], d[27], d[30]})); 
    defparam x28 .WIDTH = 17;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[2], d[4], d[7], d[8], d[9], 
            d[10], d[11], d[13], d[14], d[16], d[18], 
            d[20], d[24], d[26], d[27], d[28], d[31]})); 
    defparam x29 .WIDTH = 17;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[3], d[5], d[8], d[9], d[10], 
            d[11], d[12], d[14], d[15], d[17], d[19], 
            d[21], d[25], d[27], d[28], d[29]})); 
    defparam x30 .WIDTH = 16;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[0], d[4], d[6], d[9], d[10], 
            d[11], d[12], d[13], d[15], d[16], d[18], 
            d[20], d[22], d[26], d[28], d[29], d[30]})); 
    defparam x31 .WIDTH = 17;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 10) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[1], d[2], d[3], d[4], d[5], 
            d[7], d[9], d[11], d[12], d[15], d[16], 
            d[18], d[21], d[22], d[24], d[28]})); 
    defparam x0 .WIDTH = 16;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[0], d[1], d[6], d[7], d[8], 
            d[9], d[10], d[11], d[13], d[15], d[17], 
            d[18], d[19], d[21], d[23], d[24], d[25], 
            d[28], d[29]})); 
    defparam x1 .WIDTH = 19;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[3], d[4], d[5], d[8], d[10], 
            d[14], d[15], d[19], d[20], d[21], d[25], 
            d[26], d[28], d[29], d[30]})); 
    defparam x2 .WIDTH = 15;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[4], d[5], d[6], d[9], d[11], 
            d[15], d[16], d[20], d[21], d[22], d[26], 
            d[27], d[29], d[30], d[31]})); 
    defparam x3 .WIDTH = 15;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[1], d[2], d[3], d[4], d[6], 
            d[9], d[10], d[11], d[15], d[17], d[18], 
            d[23], d[24], d[27], d[30], d[31]})); 
    defparam x4 .WIDTH = 16;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[0], d[1], d[9], d[10], d[15], 
            d[19], d[21], d[22], d[25], d[31]})); 
    defparam x5 .WIDTH = 10;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[0], d[1], d[2], d[10], d[11], 
            d[16], d[20], d[22], d[23], d[26]})); 
    defparam x6 .WIDTH = 10;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[4], d[5], d[7], d[9], 
            d[15], d[16], d[17], d[18], d[22], d[23], 
            d[27], d[28]})); 
    defparam x7 .WIDTH = 13;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[2], d[3], d[4], d[6], d[7], 
            d[8], d[9], d[10], d[11], d[12], d[15], 
            d[17], d[19], d[21], d[22], d[23], d[29]})); 
    defparam x8 .WIDTH = 17;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[3], d[4], d[5], d[7], d[8], 
            d[9], d[10], d[11], d[12], d[13], d[16], 
            d[18], d[20], d[22], d[23], d[24], d[30]})); 
    defparam x9 .WIDTH = 17;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[1], d[2], d[3], d[6], 
            d[7], d[8], d[10], d[13], d[14], d[15], 
            d[16], d[17], d[18], d[19], d[22], d[23], 
            d[25], d[28], d[31]})); 
    defparam x10 .WIDTH = 20;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[5], d[8], d[12], d[14], d[17], 
            d[19], d[20], d[21], d[22], d[23], d[26], 
            d[28], d[29]})); 
    defparam x11 .WIDTH = 13;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[1], d[2], d[3], d[4], d[5], 
            d[6], d[7], d[11], d[12], d[13], d[16], 
            d[20], d[23], d[27], d[28], d[29], d[30]})); 
    defparam x12 .WIDTH = 17;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[2], d[3], d[4], d[5], d[6], 
            d[7], d[8], d[12], d[13], d[14], d[17], 
            d[21], d[24], d[28], d[29], d[30], d[31]})); 
    defparam x13 .WIDTH = 17;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[3], d[4], d[5], d[6], d[7], 
            d[8], d[9], d[13], d[14], d[15], d[18], 
            d[22], d[25], d[29], d[30], d[31]})); 
    defparam x14 .WIDTH = 16;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[0], d[4], d[5], d[6], d[7], 
            d[8], d[9], d[10], d[14], d[15], d[16], 
            d[19], d[23], d[26], d[30], d[31]})); 
    defparam x15 .WIDTH = 16;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[2], d[3], d[4], d[6], d[8], 
            d[10], d[12], d[17], d[18], d[20], d[21], 
            d[22], d[27], d[28], d[31]})); 
    defparam x16 .WIDTH = 15;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[0], d[3], d[4], d[5], d[7], 
            d[9], d[11], d[13], d[18], d[19], d[21], 
            d[22], d[23], d[28], d[29]})); 
    defparam x17 .WIDTH = 15;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[1], d[4], d[5], d[6], d[8], 
            d[10], d[12], d[14], d[19], d[20], d[22], 
            d[23], d[24], d[29], d[30]})); 
    defparam x18 .WIDTH = 15;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[0], d[2], d[5], d[6], d[7], 
            d[9], d[11], d[13], d[15], d[20], d[21], 
            d[23], d[24], d[25], d[30], d[31]})); 
    defparam x19 .WIDTH = 16;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[1], d[3], d[6], d[7], 
            d[8], d[10], d[12], d[14], d[16], d[21], 
            d[22], d[24], d[25], d[26], d[31]})); 
    defparam x20 .WIDTH = 16;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[1], d[2], d[4], d[7], d[8], 
            d[9], d[11], d[13], d[15], d[17], d[22], 
            d[23], d[25], d[26], d[27]})); 
    defparam x21 .WIDTH = 15;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[1], d[4], d[7], d[8], d[10], 
            d[11], d[14], d[15], d[21], d[22], d[23], 
            d[26], d[27]})); 
    defparam x22 .WIDTH = 13;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[1], d[3], d[4], d[7], d[8], 
            d[18], d[21], d[23], d[27]})); 
    defparam x23 .WIDTH = 9;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[0], d[2], d[4], d[5], d[8], 
            d[9], d[19], d[22], d[24], d[28]})); 
    defparam x24 .WIDTH = 10;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[1], d[3], d[5], d[6], d[9], 
            d[10], d[20], d[23], d[25], d[29]})); 
    defparam x25 .WIDTH = 10;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[1], d[3], d[5], d[6], d[9], 
            d[10], d[12], d[15], d[16], d[18], d[22], 
            d[26], d[28], d[30]})); 
    defparam x26 .WIDTH = 14;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[0], d[2], d[4], d[6], d[7], 
            d[10], d[11], d[13], d[16], d[17], d[19], 
            d[23], d[27], d[29], d[31]})); 
    defparam x27 .WIDTH = 15;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[0], d[1], d[3], d[5], d[7], 
            d[8], d[11], d[12], d[14], d[17], d[18], 
            d[20], d[24], d[28], d[30]})); 
    defparam x28 .WIDTH = 15;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[0], d[1], d[2], d[4], d[6], 
            d[8], d[9], d[12], d[13], d[15], d[18], 
            d[19], d[21], d[25], d[29], d[31]})); 
    defparam x29 .WIDTH = 16;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[1], d[2], d[3], d[5], 
            d[7], d[9], d[10], d[13], d[14], d[16], 
            d[19], d[20], d[22], d[26], d[30]})); 
    defparam x30 .WIDTH = 16;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[6], d[8], d[10], d[11], d[14], d[15], 
            d[17], d[20], d[21], d[23], d[27], d[31]})); 
    defparam x31 .WIDTH = 17;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 11) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[0], d[1], d[2], d[3], d[8], 
            d[14], d[15], d[17], d[19], d[21], d[22], 
            d[23], d[26], d[28], d[29], d[30]})); 
    defparam x0 .WIDTH = 16;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[0], d[4], d[8], d[9], d[14], 
            d[16], d[17], d[18], d[19], d[20], d[21], 
            d[24], d[26], d[27], d[28], d[31]})); 
    defparam x1 .WIDTH = 16;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[2], d[3], d[5], d[8], d[9], 
            d[10], d[14], d[18], d[20], d[23], d[25], 
            d[26], d[27], d[30]})); 
    defparam x2 .WIDTH = 14;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[3], d[4], d[6], d[9], d[10], 
            d[11], d[15], d[19], d[21], d[24], d[26], 
            d[27], d[28], d[31]})); 
    defparam x3 .WIDTH = 14;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[1], d[2], d[3], d[4], d[5], 
            d[7], d[8], d[10], d[11], d[12], d[14], 
            d[15], d[16], d[17], d[19], d[20], d[21], 
            d[23], d[25], d[26], d[27], d[30]})); 
    defparam x4 .WIDTH = 22;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[1], d[4], d[5], d[6], d[9], 
            d[11], d[12], d[13], d[14], d[16], d[18], 
            d[19], d[20], d[23], d[24], d[27], d[29], 
            d[30], d[31]})); 
    defparam x5 .WIDTH = 19;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[2], d[5], d[6], d[7], d[10], 
            d[12], d[13], d[14], d[15], d[17], d[19], 
            d[20], d[21], d[24], d[25], d[28], d[30], 
            d[31]})); 
    defparam x6 .WIDTH = 18;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[1], d[2], d[6], d[7], d[11], 
            d[13], d[16], d[17], d[18], d[19], d[20], 
            d[23], d[25], d[28], d[30], d[31]})); 
    defparam x7 .WIDTH = 16;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[0], d[1], d[7], d[12], d[15], 
            d[18], d[20], d[22], d[23], d[24], d[28], 
            d[30], d[31]})); 
    defparam x8 .WIDTH = 13;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[1], d[2], d[8], d[13], d[16], 
            d[19], d[21], d[23], d[24], d[25], d[29], 
            d[31]})); 
    defparam x9 .WIDTH = 12;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[1], d[8], d[9], d[15], 
            d[19], d[20], d[21], d[23], d[24], d[25], 
            d[28], d[29]})); 
    defparam x10 .WIDTH = 13;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[3], d[8], d[9], d[10], 
            d[14], d[15], d[16], d[17], d[19], d[20], 
            d[23], d[24], d[25], d[28]})); 
    defparam x11 .WIDTH = 15;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[0], d[2], d[3], d[4], d[8], 
            d[9], d[10], d[11], d[14], d[16], d[18], 
            d[19], d[20], d[22], d[23], d[24], d[25], 
            d[28], d[30]})); 
    defparam x12 .WIDTH = 19;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[1], d[3], d[4], d[5], d[9], 
            d[10], d[11], d[12], d[15], d[17], d[19], 
            d[20], d[21], d[23], d[24], d[25], d[26], 
            d[29], d[31]})); 
    defparam x13 .WIDTH = 19;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[2], d[4], d[5], d[6], d[10], 
            d[11], d[12], d[13], d[16], d[18], d[20], 
            d[21], d[22], d[24], d[25], d[26], d[27], 
            d[30]})); 
    defparam x14 .WIDTH = 18;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[0], d[3], d[5], d[6], d[7], 
            d[11], d[12], d[13], d[14], d[17], d[19], 
            d[21], d[22], d[23], d[25], d[26], d[27], 
            d[28], d[31]})); 
    defparam x15 .WIDTH = 19;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[2], d[3], d[4], d[6], d[7], 
            d[12], d[13], d[17], d[18], d[19], d[20], 
            d[21], d[24], d[27], d[30]})); 
    defparam x16 .WIDTH = 15;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[0], d[3], d[4], d[5], d[7], 
            d[8], d[13], d[14], d[18], d[19], d[20], 
            d[21], d[22], d[25], d[28], d[31]})); 
    defparam x17 .WIDTH = 16;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[1], d[4], d[5], d[6], d[8], 
            d[9], d[14], d[15], d[19], d[20], d[21], 
            d[22], d[23], d[26], d[29]})); 
    defparam x18 .WIDTH = 15;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[0], d[2], d[5], d[6], d[7], 
            d[9], d[10], d[15], d[16], d[20], d[21], 
            d[22], d[23], d[24], d[27], d[30]})); 
    defparam x19 .WIDTH = 16;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[1], d[3], d[6], d[7], d[8], 
            d[10], d[11], d[16], d[17], d[21], d[22], 
            d[23], d[24], d[25], d[28], d[31]})); 
    defparam x20 .WIDTH = 16;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[2], d[4], d[7], d[8], d[9], 
            d[11], d[12], d[17], d[18], d[22], d[23], 
            d[24], d[25], d[26], d[29]})); 
    defparam x21 .WIDTH = 15;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[0], d[1], d[2], d[5], d[9], 
            d[10], d[12], d[13], d[14], d[15], d[17], 
            d[18], d[21], d[22], d[24], d[25], d[27], 
            d[28], d[29]})); 
    defparam x22 .WIDTH = 19;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[0], d[6], d[8], d[10], d[11], 
            d[13], d[16], d[17], d[18], d[21], d[25]})); 
    defparam x23 .WIDTH = 11;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[1], d[7], d[9], d[11], d[12], 
            d[14], d[17], d[18], d[19], d[22], d[26]})); 
    defparam x24 .WIDTH = 11;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[0], d[2], d[8], d[10], d[12], 
            d[13], d[15], d[18], d[19], d[20], d[23], 
            d[27]})); 
    defparam x25 .WIDTH = 12;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[2], d[8], d[9], d[11], d[13], 
            d[15], d[16], d[17], d[20], d[22], d[23], 
            d[24], d[26], d[29], d[30]})); 
    defparam x26 .WIDTH = 15;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[3], d[9], d[10], d[12], d[14], 
            d[16], d[17], d[18], d[21], d[23], d[24], 
            d[25], d[27], d[30], d[31]})); 
    defparam x27 .WIDTH = 15;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[4], d[10], d[11], d[13], d[15], 
            d[17], d[18], d[19], d[22], d[24], d[25], 
            d[26], d[28], d[31]})); 
    defparam x28 .WIDTH = 14;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[0], d[5], d[11], d[12], d[14], 
            d[16], d[18], d[19], d[20], d[23], d[25], 
            d[26], d[27], d[29]})); 
    defparam x29 .WIDTH = 14;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[1], d[6], d[12], d[13], 
            d[15], d[17], d[19], d[20], d[21], d[24], 
            d[26], d[27], d[28], d[30]})); 
    defparam x30 .WIDTH = 15;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[0], d[1], d[2], d[7], d[13], 
            d[14], d[16], d[18], d[20], d[21], d[22], 
            d[25], d[27], d[28], d[29], d[31]})); 
    defparam x31 .WIDTH = 16;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 12) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[0], d[4], d[5], d[6], d[8], 
            d[11], d[12], d[14], d[17], d[19], d[20], 
            d[22], d[26], d[27], d[29], d[31]})); 
    defparam x0 .WIDTH = 16;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[0], d[1], d[4], d[7], d[8], 
            d[9], d[11], d[13], d[14], d[15], d[17], 
            d[18], d[19], d[21], d[22], d[23], d[26], 
            d[28], d[29], d[30], d[31]})); 
    defparam x1 .WIDTH = 21;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[0], d[1], d[2], d[4], d[6], 
            d[9], d[10], d[11], d[15], d[16], d[17], 
            d[18], d[23], d[24], d[26], d[30]})); 
    defparam x2 .WIDTH = 16;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[1], d[2], d[3], d[5], d[7], 
            d[10], d[11], d[12], d[16], d[17], d[18], 
            d[19], d[24], d[25], d[27], d[31]})); 
    defparam x3 .WIDTH = 16;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[2], d[3], d[5], d[13], d[14], 
            d[18], d[22], d[25], d[27], d[28], d[29], 
            d[31]})); 
    defparam x4 .WIDTH = 12;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[0], d[3], d[5], d[8], d[11], 
            d[12], d[15], d[17], d[20], d[22], d[23], 
            d[27], d[28], d[30], d[31]})); 
    defparam x5 .WIDTH = 15;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[1], d[4], d[6], d[9], d[12], 
            d[13], d[16], d[18], d[21], d[23], d[24], 
            d[28], d[29], d[31]})); 
    defparam x6 .WIDTH = 14;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[2], d[4], d[6], d[7], 
            d[8], d[10], d[11], d[12], d[13], d[20], 
            d[24], d[25], d[26], d[27], d[30], d[31]})); 
    defparam x7 .WIDTH = 17;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[0], d[1], d[3], d[4], d[6], 
            d[7], d[9], d[13], d[17], d[19], d[20], 
            d[21], d[22], d[25], d[28], d[29]})); 
    defparam x8 .WIDTH = 16;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[1], d[2], d[4], d[5], d[7], 
            d[8], d[10], d[14], d[18], d[20], d[21], 
            d[22], d[23], d[26], d[29], d[30]})); 
    defparam x9 .WIDTH = 16;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[2], d[3], d[4], d[9], 
            d[12], d[14], d[15], d[17], d[20], d[21], 
            d[23], d[24], d[26], d[29], d[30]})); 
    defparam x10 .WIDTH = 16;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[1], d[3], d[6], d[8], 
            d[10], d[11], d[12], d[13], d[14], d[15], 
            d[16], d[17], d[18], d[19], d[20], d[21], 
            d[24], d[25], d[26], d[29], d[30]})); 
    defparam x11 .WIDTH = 22;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[1], d[2], d[5], d[6], d[7], 
            d[8], d[9], d[13], d[15], d[16], d[18], 
            d[21], d[25], d[29], d[30]})); 
    defparam x12 .WIDTH = 15;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[0], d[2], d[3], d[6], d[7], 
            d[8], d[9], d[10], d[14], d[16], d[17], 
            d[19], d[22], d[26], d[30], d[31]})); 
    defparam x13 .WIDTH = 16;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[1], d[3], d[4], d[7], d[8], 
            d[9], d[10], d[11], d[15], d[17], d[18], 
            d[20], d[23], d[27], d[31]})); 
    defparam x14 .WIDTH = 15;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[0], d[2], d[4], d[5], d[8], 
            d[9], d[10], d[11], d[12], d[16], d[18], 
            d[19], d[21], d[24], d[28]})); 
    defparam x15 .WIDTH = 15;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[0], d[1], d[3], d[4], d[8], 
            d[9], d[10], d[13], d[14], d[25], d[26], 
            d[27], d[31]})); 
    defparam x16 .WIDTH = 13;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[1], d[2], d[4], d[5], d[9], 
            d[10], d[11], d[14], d[15], d[26], d[27], 
            d[28]})); 
    defparam x17 .WIDTH = 12;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[2], d[3], d[5], d[6], d[10], 
            d[11], d[12], d[15], d[16], d[27], d[28], 
            d[29]})); 
    defparam x18 .WIDTH = 12;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[0], d[3], d[4], d[6], d[7], 
            d[11], d[12], d[13], d[16], d[17], d[28], 
            d[29], d[30]})); 
    defparam x19 .WIDTH = 13;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[1], d[4], d[5], d[7], d[8], 
            d[12], d[13], d[14], d[17], d[18], d[29], 
            d[30], d[31]})); 
    defparam x20 .WIDTH = 13;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[2], d[5], d[6], d[8], d[9], 
            d[13], d[14], d[15], d[18], d[19], d[30], 
            d[31]})); 
    defparam x21 .WIDTH = 12;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[0], d[3], d[4], d[5], d[7], 
            d[8], d[9], d[10], d[11], d[12], d[15], 
            d[16], d[17], d[22], d[26], d[27], d[29]})); 
    defparam x22 .WIDTH = 17;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[1], d[9], d[10], d[13], d[14], 
            d[16], d[18], d[19], d[20], d[22], d[23], 
            d[26], d[28], d[29], d[30], d[31]})); 
    defparam x23 .WIDTH = 16;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[0], d[2], d[10], d[11], d[14], 
            d[15], d[17], d[19], d[20], d[21], d[23], 
            d[24], d[27], d[29], d[30], d[31]})); 
    defparam x24 .WIDTH = 16;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[1], d[3], d[11], d[12], d[15], 
            d[16], d[18], d[20], d[21], d[22], d[24], 
            d[25], d[28], d[30], d[31]})); 
    defparam x25 .WIDTH = 15;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[0], d[2], d[5], d[6], d[8], 
            d[11], d[13], d[14], d[16], d[20], d[21], 
            d[23], d[25], d[27]})); 
    defparam x26 .WIDTH = 14;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[0], d[1], d[3], d[6], d[7], 
            d[9], d[12], d[14], d[15], d[17], d[21], 
            d[22], d[24], d[26], d[28]})); 
    defparam x27 .WIDTH = 15;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[0], d[1], d[2], d[4], d[7], 
            d[8], d[10], d[13], d[15], d[16], d[18], 
            d[22], d[23], d[25], d[27], d[29]})); 
    defparam x28 .WIDTH = 16;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[1], d[2], d[3], d[5], d[8], 
            d[9], d[11], d[14], d[16], d[17], d[19], 
            d[23], d[24], d[26], d[28], d[30]})); 
    defparam x29 .WIDTH = 16;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[2], d[3], d[4], d[6], d[9], 
            d[10], d[12], d[15], d[17], d[18], d[20], 
            d[24], d[25], d[27], d[29], d[31]})); 
    defparam x30 .WIDTH = 16;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[3], d[4], d[5], d[7], d[10], 
            d[11], d[13], d[16], d[18], d[19], d[21], 
            d[25], d[26], d[28], d[30]})); 
    defparam x31 .WIDTH = 15;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 13) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[0], d[2], d[3], d[4], d[6], 
            d[7], d[8], d[9], d[10], d[11], d[12], 
            d[13], d[14], d[15], d[16], d[18], d[19], 
            d[24], d[25], d[27]})); 
    defparam x0 .WIDTH = 20;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[0], d[1], d[2], d[5], d[6], 
            d[17], d[18], d[20], d[24], d[26], d[27], 
            d[28]})); 
    defparam x1 .WIDTH = 12;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[1], d[4], d[8], d[9], d[10], 
            d[11], d[12], d[13], d[14], d[15], d[16], 
            d[21], d[24], d[28], d[29]})); 
    defparam x2 .WIDTH = 15;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[0], d[2], d[5], d[9], d[10], 
            d[11], d[12], d[13], d[14], d[15], d[16], 
            d[17], d[22], d[25], d[29], d[30]})); 
    defparam x3 .WIDTH = 16;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[1], d[2], d[4], d[7], d[8], 
            d[9], d[17], d[19], d[23], d[24], d[25], 
            d[26], d[27], d[30], d[31]})); 
    defparam x4 .WIDTH = 15;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[0], d[4], d[5], d[6], d[7], 
            d[11], d[12], d[13], d[14], d[15], d[16], 
            d[19], d[20], d[26], d[28], d[31]})); 
    defparam x5 .WIDTH = 16;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[0], d[1], d[5], d[6], d[7], 
            d[8], d[12], d[13], d[14], d[15], d[16], 
            d[17], d[20], d[21], d[27], d[29]})); 
    defparam x6 .WIDTH = 16;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[1], d[3], d[4], d[10], 
            d[11], d[12], d[17], d[19], d[21], d[22], 
            d[24], d[25], d[27], d[28], d[30]})); 
    defparam x7 .WIDTH = 16;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[1], d[3], d[5], d[6], d[7], 
            d[8], d[9], d[10], d[14], d[15], d[16], 
            d[19], d[20], d[22], d[23], d[24], d[26], 
            d[27], d[28], d[29], d[31]})); 
    defparam x8 .WIDTH = 21;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[0], d[2], d[4], d[6], d[7], 
            d[8], d[9], d[10], d[11], d[15], d[16], 
            d[17], d[20], d[21], d[23], d[24], d[25], 
            d[27], d[28], d[29], d[30]})); 
    defparam x9 .WIDTH = 21;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[1], d[2], d[4], d[5], 
            d[6], d[13], d[14], d[15], d[17], d[19], 
            d[21], d[22], d[26], d[27], d[28], d[29], 
            d[30], d[31]})); 
    defparam x10 .WIDTH = 19;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[1], d[4], d[5], d[8], 
            d[9], d[10], d[11], d[12], d[13], d[19], 
            d[20], d[22], d[23], d[24], d[25], d[28], 
            d[29], d[30], d[31]})); 
    defparam x11 .WIDTH = 20;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[1], d[3], d[4], d[5], d[7], 
            d[8], d[15], d[16], d[18], d[19], d[20], 
            d[21], d[23], d[26], d[27], d[29], d[30], 
            d[31]})); 
    defparam x12 .WIDTH = 18;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[0], d[2], d[4], d[5], d[6], 
            d[8], d[9], d[16], d[17], d[19], d[20], 
            d[21], d[22], d[24], d[27], d[28], d[30], 
            d[31]})); 
    defparam x13 .WIDTH = 18;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[0], d[1], d[3], d[5], d[6], 
            d[7], d[9], d[10], d[17], d[18], d[20], 
            d[21], d[22], d[23], d[25], d[28], d[29], 
            d[31]})); 
    defparam x14 .WIDTH = 18;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[0], d[1], d[2], d[4], d[6], 
            d[7], d[8], d[10], d[11], d[18], d[19], 
            d[21], d[22], d[23], d[24], d[26], d[29], 
            d[30]})); 
    defparam x15 .WIDTH = 18;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[1], d[4], d[5], d[6], d[10], 
            d[13], d[14], d[15], d[16], d[18], d[20], 
            d[22], d[23], d[30], d[31]})); 
    defparam x16 .WIDTH = 15;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[0], d[2], d[5], d[6], d[7], 
            d[11], d[14], d[15], d[16], d[17], d[19], 
            d[21], d[23], d[24], d[31]})); 
    defparam x17 .WIDTH = 15;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[1], d[3], d[6], d[7], 
            d[8], d[12], d[15], d[16], d[17], d[18], 
            d[20], d[22], d[24], d[25]})); 
    defparam x18 .WIDTH = 15;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[1], d[2], d[4], d[7], d[8], 
            d[9], d[13], d[16], d[17], d[18], d[19], 
            d[21], d[23], d[25], d[26]})); 
    defparam x19 .WIDTH = 15;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[2], d[3], d[5], d[8], d[9], 
            d[10], d[14], d[17], d[18], d[19], d[20], 
            d[22], d[24], d[26], d[27]})); 
    defparam x20 .WIDTH = 15;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[3], d[4], d[6], d[9], d[10], 
            d[11], d[15], d[18], d[19], d[20], d[21], 
            d[23], d[25], d[27], d[28]})); 
    defparam x21 .WIDTH = 15;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[2], d[3], d[5], d[6], d[8], 
            d[9], d[13], d[14], d[15], d[18], d[20], 
            d[21], d[22], d[25], d[26], d[27], d[28], 
            d[29]})); 
    defparam x22 .WIDTH = 18;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[2], d[8], d[11], d[12], d[13], 
            d[18], d[21], d[22], d[23], d[24], d[25], 
            d[26], d[28], d[29], d[30]})); 
    defparam x23 .WIDTH = 15;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[3], d[9], d[12], d[13], d[14], 
            d[19], d[22], d[23], d[24], d[25], d[26], 
            d[27], d[29], d[30], d[31]})); 
    defparam x24 .WIDTH = 15;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[0], d[4], d[10], d[13], d[14], 
            d[15], d[20], d[23], d[24], d[25], d[26], 
            d[27], d[28], d[30], d[31]})); 
    defparam x25 .WIDTH = 15;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[6], d[7], d[8], d[9], d[10], 
            d[12], d[13], d[18], d[19], d[21], d[26], 
            d[28], d[29], d[31]})); 
    defparam x26 .WIDTH = 20;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[1], d[2], d[3], d[4], d[5], 
            d[6], d[7], d[8], d[9], d[10], d[11], 
            d[13], d[14], d[19], d[20], d[22], d[27], 
            d[29], d[30]})); 
    defparam x27 .WIDTH = 19;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[0], d[2], d[3], d[4], d[5], 
            d[6], d[7], d[8], d[9], d[10], d[11], 
            d[12], d[14], d[15], d[20], d[21], d[23], 
            d[28], d[30], d[31]})); 
    defparam x28 .WIDTH = 20;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[0], d[1], d[3], d[4], d[5], 
            d[6], d[7], d[8], d[9], d[10], d[11], 
            d[12], d[13], d[15], d[16], d[21], d[22], 
            d[24], d[29], d[31]})); 
    defparam x29 .WIDTH = 20;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[1], d[2], d[4], d[5], 
            d[6], d[7], d[8], d[9], d[10], d[11], 
            d[12], d[13], d[14], d[16], d[17], d[22], 
            d[23], d[25], d[30]})); 
    defparam x30 .WIDTH = 20;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[1], d[2], d[3], d[5], d[6], 
            d[7], d[8], d[9], d[10], d[11], d[12], 
            d[13], d[14], d[15], d[17], d[18], d[23], 
            d[24], d[26], d[31]})); 
    defparam x31 .WIDTH = 20;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 14) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[3], d[4], d[5], d[7], d[9], 
            d[10], d[11], d[12], d[13], d[14], d[15], 
            d[17], d[19], d[22], d[23], d[25], d[26], 
            d[27], d[29]})); 
    defparam x0 .WIDTH = 19;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[0], d[3], d[6], d[7], d[8], 
            d[9], d[16], d[17], d[18], d[19], d[20], 
            d[22], d[24], d[25], d[28], d[29], d[30]})); 
    defparam x1 .WIDTH = 17;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[0], d[1], d[3], d[5], d[8], 
            d[11], d[12], d[13], d[14], d[15], d[18], 
            d[20], d[21], d[22], d[27], d[30], d[31]})); 
    defparam x2 .WIDTH = 17;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[1], d[2], d[4], d[6], d[9], 
            d[12], d[13], d[14], d[15], d[16], d[19], 
            d[21], d[22], d[23], d[28], d[31]})); 
    defparam x3 .WIDTH = 16;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[2], d[4], d[9], d[11], d[12], 
            d[16], d[19], d[20], d[24], d[25], d[26], 
            d[27]})); 
    defparam x4 .WIDTH = 12;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[4], d[7], d[9], d[11], d[14], 
            d[15], d[19], d[20], d[21], d[22], d[23], 
            d[28], d[29]})); 
    defparam x5 .WIDTH = 13;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[0], d[5], d[8], d[10], d[12], 
            d[15], d[16], d[20], d[21], d[22], d[23], 
            d[24], d[29], d[30]})); 
    defparam x6 .WIDTH = 14;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[1], d[3], d[4], d[5], 
            d[6], d[7], d[10], d[12], d[14], d[15], 
            d[16], d[19], d[21], d[24], d[26], d[27], 
            d[29], d[30], d[31]})); 
    defparam x7 .WIDTH = 20;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[1], d[2], d[3], d[6], d[8], 
            d[9], d[10], d[12], d[14], d[16], d[19], 
            d[20], d[23], d[26], d[28], d[29], d[30], 
            d[31]})); 
    defparam x8 .WIDTH = 18;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[2], d[3], d[4], d[7], d[9], 
            d[10], d[11], d[13], d[15], d[17], d[20], 
            d[21], d[24], d[27], d[29], d[30], d[31]})); 
    defparam x9 .WIDTH = 17;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[7], d[8], d[9], d[13], 
            d[15], d[16], d[17], d[18], d[19], d[21], 
            d[23], d[26], d[27], d[28], d[29], d[30], 
            d[31]})); 
    defparam x10 .WIDTH = 18;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[1], d[3], d[4], d[5], d[7], 
            d[8], d[11], d[12], d[13], d[15], d[16], 
            d[18], d[20], d[23], d[24], d[25], d[26], 
            d[28], d[30], d[31]})); 
    defparam x11 .WIDTH = 20;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[2], d[3], d[6], d[7], d[8], 
            d[10], d[11], d[15], d[16], d[21], d[22], 
            d[23], d[24], d[31]})); 
    defparam x12 .WIDTH = 14;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[0], d[3], d[4], d[7], d[8], 
            d[9], d[11], d[12], d[16], d[17], d[22], 
            d[23], d[24], d[25]})); 
    defparam x13 .WIDTH = 14;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[1], d[4], d[5], d[8], d[9], 
            d[10], d[12], d[13], d[17], d[18], d[23], 
            d[24], d[25], d[26]})); 
    defparam x14 .WIDTH = 14;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[0], d[2], d[5], d[6], d[9], 
            d[10], d[11], d[13], d[14], d[18], d[19], 
            d[24], d[25], d[26], d[27]})); 
    defparam x15 .WIDTH = 15;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[1], d[4], d[5], d[6], d[9], 
            d[13], d[17], d[20], d[22], d[23], d[28], 
            d[29]})); 
    defparam x16 .WIDTH = 12;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[0], d[2], d[5], d[6], d[7], 
            d[10], d[14], d[18], d[21], d[23], d[24], 
            d[29], d[30]})); 
    defparam x17 .WIDTH = 13;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[1], d[3], d[6], d[7], 
            d[8], d[11], d[15], d[19], d[22], d[24], 
            d[25], d[30], d[31]})); 
    defparam x18 .WIDTH = 14;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[1], d[2], d[4], d[7], d[8], 
            d[9], d[12], d[16], d[20], d[23], d[25], 
            d[26], d[31]})); 
    defparam x19 .WIDTH = 13;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[2], d[3], d[5], d[8], d[9], 
            d[10], d[13], d[17], d[21], d[24], d[26], 
            d[27]})); 
    defparam x20 .WIDTH = 12;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[3], d[4], d[6], d[9], d[10], 
            d[11], d[14], d[18], d[22], d[25], d[27], 
            d[28]})); 
    defparam x21 .WIDTH = 12;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[3], d[9], d[13], d[14], d[17], 
            d[22], d[25], d[27], d[28]})); 
    defparam x22 .WIDTH = 9;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[3], d[5], d[7], d[9], d[11], 
            d[12], d[13], d[17], d[18], d[19], d[22], 
            d[25], d[27], d[28]})); 
    defparam x23 .WIDTH = 14;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[4], d[6], d[8], d[10], d[12], 
            d[13], d[14], d[18], d[19], d[20], d[23], 
            d[26], d[28], d[29]})); 
    defparam x24 .WIDTH = 14;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[0], d[5], d[7], d[9], d[11], 
            d[13], d[14], d[15], d[19], d[20], d[21], 
            d[24], d[27], d[29], d[30]})); 
    defparam x25 .WIDTH = 15;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[1], d[3], d[4], d[5], d[6], 
            d[7], d[8], d[9], d[11], d[13], d[16], 
            d[17], d[19], d[20], d[21], d[23], d[26], 
            d[27], d[28], d[29], d[30], d[31]})); 
    defparam x26 .WIDTH = 22;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[0], d[2], d[4], d[5], d[6], 
            d[7], d[8], d[9], d[10], d[12], d[14], 
            d[17], d[18], d[20], d[21], d[22], d[24], 
            d[27], d[28], d[29], d[30], d[31]})); 
    defparam x27 .WIDTH = 22;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[0], d[1], d[3], d[5], d[6], 
            d[7], d[8], d[9], d[10], d[11], d[13], 
            d[15], d[18], d[19], d[21], d[22], d[23], 
            d[25], d[28], d[29], d[30], d[31]})); 
    defparam x28 .WIDTH = 22;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[0], d[1], d[2], d[4], d[6], 
            d[7], d[8], d[9], d[10], d[11], d[12], 
            d[14], d[16], d[19], d[20], d[22], d[23], 
            d[24], d[26], d[29], d[30], d[31]})); 
    defparam x29 .WIDTH = 22;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[1], d[2], d[3], d[5], d[7], 
            d[8], d[9], d[10], d[11], d[12], d[13], 
            d[15], d[17], d[20], d[21], d[23], d[24], 
            d[25], d[27], d[30], d[31]})); 
    defparam x30 .WIDTH = 21;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[2], d[3], d[4], d[6], d[8], 
            d[9], d[10], d[11], d[12], d[13], d[14], 
            d[16], d[18], d[21], d[22], d[24], d[25], 
            d[26], d[28], d[31]})); 
    defparam x31 .WIDTH = 20;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 15) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[3], d[5], d[6], d[7], d[10], 
            d[11], d[13], d[16], d[20], d[22], d[25], 
            d[26], d[27], d[30], d[31]})); 
    defparam x0 .WIDTH = 15;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[3], d[4], d[5], d[8], d[10], 
            d[12], d[13], d[14], d[16], d[17], d[20], 
            d[21], d[22], d[23], d[25], d[28], d[30]})); 
    defparam x1 .WIDTH = 17;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[3], d[4], d[7], d[9], d[10], 
            d[14], d[15], d[16], d[17], d[18], d[20], 
            d[21], d[23], d[24], d[25], d[27], d[29], 
            d[30]})); 
    defparam x2 .WIDTH = 18;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[4], d[5], d[8], d[10], d[11], 
            d[15], d[16], d[17], d[18], d[19], d[21], 
            d[22], d[24], d[25], d[26], d[28], d[30], 
            d[31]})); 
    defparam x3 .WIDTH = 18;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[3], d[7], d[9], d[10], d[12], 
            d[13], d[17], d[18], d[19], d[23], d[29], 
            d[30]})); 
    defparam x4 .WIDTH = 12;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[3], d[4], d[5], d[6], d[7], 
            d[8], d[14], d[16], d[18], d[19], d[22], 
            d[24], d[25], d[26], d[27]})); 
    defparam x5 .WIDTH = 15;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[4], d[5], d[6], d[7], d[8], 
            d[9], d[15], d[17], d[19], d[20], d[23], 
            d[25], d[26], d[27], d[28]})); 
    defparam x6 .WIDTH = 15;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[3], d[8], d[9], d[11], d[13], 
            d[18], d[21], d[22], d[24], d[25], d[28], 
            d[29], d[30], d[31]})); 
    defparam x7 .WIDTH = 14;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[0], d[3], d[4], d[5], d[6], 
            d[7], d[9], d[11], d[12], d[13], d[14], 
            d[16], d[19], d[20], d[23], d[27], d[29]})); 
    defparam x8 .WIDTH = 17;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[0], d[1], d[4], d[5], d[6], 
            d[7], d[8], d[10], d[12], d[13], d[14], 
            d[15], d[17], d[20], d[21], d[24], d[28], 
            d[30]})); 
    defparam x9 .WIDTH = 18;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[1], d[2], d[3], d[8], d[9], 
            d[10], d[14], d[15], d[18], d[20], d[21], 
            d[26], d[27], d[29], d[30]})); 
    defparam x10 .WIDTH = 15;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[2], d[4], d[5], d[6], d[7], 
            d[9], d[13], d[15], d[19], d[20], d[21], 
            d[25], d[26], d[28]})); 
    defparam x11 .WIDTH = 14;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[0], d[8], d[11], d[13], d[14], 
            d[21], d[25], d[29], d[30], d[31]})); 
    defparam x12 .WIDTH = 10;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[0], d[1], d[9], d[12], d[14], 
            d[15], d[22], d[26], d[30], d[31]})); 
    defparam x13 .WIDTH = 10;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[1], d[2], d[10], d[13], d[15], 
            d[16], d[23], d[27], d[31]})); 
    defparam x14 .WIDTH = 9;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[2], d[3], d[11], d[14], d[16], 
            d[17], d[24], d[28]})); 
    defparam x15 .WIDTH = 8;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[4], d[5], d[6], d[7], d[10], 
            d[11], d[12], d[13], d[15], d[16], d[17], 
            d[18], d[20], d[22], d[26], d[27], d[29], 
            d[30], d[31]})); 
    defparam x16 .WIDTH = 19;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[5], d[6], d[7], d[8], d[11], 
            d[12], d[13], d[14], d[16], d[17], d[18], 
            d[19], d[21], d[23], d[27], d[28], d[30], 
            d[31]})); 
    defparam x17 .WIDTH = 18;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[6], d[7], d[8], d[9], 
            d[12], d[13], d[14], d[15], d[17], d[18], 
            d[19], d[20], d[22], d[24], d[28], d[29], 
            d[31]})); 
    defparam x18 .WIDTH = 18;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[0], d[1], d[7], d[8], d[9], 
            d[10], d[13], d[14], d[15], d[16], d[18], 
            d[19], d[20], d[21], d[23], d[25], d[29], 
            d[30]})); 
    defparam x19 .WIDTH = 18;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[1], d[2], d[8], d[9], d[10], 
            d[11], d[14], d[15], d[16], d[17], d[19], 
            d[20], d[21], d[22], d[24], d[26], d[30], 
            d[31]})); 
    defparam x20 .WIDTH = 18;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[2], d[3], d[9], d[10], d[11], 
            d[12], d[15], d[16], d[17], d[18], d[20], 
            d[21], d[22], d[23], d[25], d[27], d[31]})); 
    defparam x21 .WIDTH = 17;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[0], d[4], d[5], d[6], d[7], 
            d[12], d[17], d[18], d[19], d[20], d[21], 
            d[23], d[24], d[25], d[27], d[28], d[30], 
            d[31]})); 
    defparam x22 .WIDTH = 18;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[0], d[1], d[3], d[8], d[10], 
            d[11], d[16], d[18], d[19], d[21], d[24], 
            d[27], d[28], d[29], d[30]})); 
    defparam x23 .WIDTH = 15;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[1], d[2], d[4], d[9], d[11], 
            d[12], d[17], d[19], d[20], d[22], d[25], 
            d[28], d[29], d[30], d[31]})); 
    defparam x24 .WIDTH = 15;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[0], d[2], d[3], d[5], d[10], 
            d[12], d[13], d[18], d[20], d[21], d[23], 
            d[26], d[29], d[30], d[31]})); 
    defparam x25 .WIDTH = 15;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[0], d[1], d[4], d[5], d[7], 
            d[10], d[14], d[16], d[19], d[20], d[21], 
            d[24], d[25], d[26]})); 
    defparam x26 .WIDTH = 14;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[0], d[1], d[2], d[5], d[6], 
            d[8], d[11], d[15], d[17], d[20], d[21], 
            d[22], d[25], d[26], d[27]})); 
    defparam x27 .WIDTH = 15;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[1], d[2], d[3], d[6], d[7], 
            d[9], d[12], d[16], d[18], d[21], d[22], 
            d[23], d[26], d[27], d[28]})); 
    defparam x28 .WIDTH = 15;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[0], d[2], d[3], d[4], d[7], 
            d[8], d[10], d[13], d[17], d[19], d[22], 
            d[23], d[24], d[27], d[28], d[29]})); 
    defparam x29 .WIDTH = 16;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[1], d[3], d[4], d[5], d[8], 
            d[9], d[11], d[14], d[18], d[20], d[23], 
            d[24], d[25], d[28], d[29], d[30]})); 
    defparam x30 .WIDTH = 16;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[2], d[4], d[5], d[6], d[9], 
            d[10], d[12], d[15], d[19], d[21], d[24], 
            d[25], d[26], d[29], d[30], d[31]})); 
    defparam x31 .WIDTH = 16;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 16) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[0], d[2], d[4], d[6], d[7], 
            d[8], d[12], d[13], d[14], d[16], d[17], 
            d[19], d[20], d[23], d[24], d[26], d[27], 
            d[29]})); 
    defparam x0 .WIDTH = 18;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[6], d[9], d[12], d[15], d[16], 
            d[18], d[19], d[21], d[23], d[25], d[26], 
            d[28], d[29], d[30]})); 
    defparam x1 .WIDTH = 20;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[1], d[3], d[5], d[8], d[10], 
            d[12], d[14], d[22], d[23], d[30], d[31]})); 
    defparam x2 .WIDTH = 11;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[0], d[2], d[4], d[6], d[9], 
            d[11], d[13], d[15], d[23], d[24], d[31]})); 
    defparam x3 .WIDTH = 11;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[1], d[2], d[3], d[4], d[5], 
            d[6], d[8], d[10], d[13], d[17], d[19], 
            d[20], d[23], d[25], d[26], d[27], d[29]})); 
    defparam x4 .WIDTH = 17;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[0], d[3], d[5], d[8], d[9], 
            d[11], d[12], d[13], d[16], d[17], d[18], 
            d[19], d[21], d[23], d[28], d[29], d[30]})); 
    defparam x5 .WIDTH = 17;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[0], d[1], d[4], d[6], d[9], 
            d[10], d[12], d[13], d[14], d[17], d[18], 
            d[19], d[20], d[22], d[24], d[29], d[30], 
            d[31]})); 
    defparam x6 .WIDTH = 18;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[1], d[4], d[5], d[6], 
            d[8], d[10], d[11], d[12], d[15], d[16], 
            d[17], d[18], d[21], d[24], d[25], d[26], 
            d[27], d[29], d[30], d[31]})); 
    defparam x7 .WIDTH = 21;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[0], d[1], d[4], d[5], d[8], 
            d[9], d[11], d[14], d[18], d[20], d[22], 
            d[23], d[24], d[25], d[28], d[29], d[30], 
            d[31]})); 
    defparam x8 .WIDTH = 18;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[1], d[2], d[5], d[6], d[9], 
            d[10], d[12], d[15], d[19], d[21], d[23], 
            d[24], d[25], d[26], d[29], d[30], d[31]})); 
    defparam x9 .WIDTH = 17;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[3], d[4], d[8], d[10], 
            d[11], d[12], d[14], d[17], d[19], d[22], 
            d[23], d[25], d[29], d[30], d[31]})); 
    defparam x10 .WIDTH = 16;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[1], d[2], d[5], d[6], 
            d[7], d[8], d[9], d[11], d[14], d[15], 
            d[16], d[17], d[18], d[19], d[27], d[29], 
            d[30], d[31]})); 
    defparam x11 .WIDTH = 19;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[0], d[1], d[3], d[4], d[9], 
            d[10], d[13], d[14], d[15], d[18], d[23], 
            d[24], d[26], d[27], d[28], d[29], d[30], 
            d[31]})); 
    defparam x12 .WIDTH = 18;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[1], d[2], d[4], d[5], d[10], 
            d[11], d[14], d[15], d[16], d[19], d[24], 
            d[25], d[27], d[28], d[29], d[30], d[31]})); 
    defparam x13 .WIDTH = 17;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[0], d[2], d[3], d[5], d[6], 
            d[11], d[12], d[15], d[16], d[17], d[20], 
            d[25], d[26], d[28], d[29], d[30], d[31]})); 
    defparam x14 .WIDTH = 17;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[0], d[1], d[3], d[4], d[6], 
            d[7], d[12], d[13], d[16], d[17], d[18], 
            d[21], d[26], d[27], d[29], d[30], d[31]})); 
    defparam x15 .WIDTH = 17;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[0], d[1], d[5], d[6], d[12], 
            d[16], d[18], d[20], d[22], d[23], d[24], 
            d[26], d[28], d[29], d[30], d[31]})); 
    defparam x16 .WIDTH = 16;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[0], d[1], d[2], d[6], d[7], 
            d[13], d[17], d[19], d[21], d[23], d[24], 
            d[25], d[27], d[29], d[30], d[31]})); 
    defparam x17 .WIDTH = 16;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[1], d[2], d[3], d[7], 
            d[8], d[14], d[18], d[20], d[22], d[24], 
            d[25], d[26], d[28], d[30], d[31]})); 
    defparam x18 .WIDTH = 16;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[8], d[9], d[15], d[19], d[21], d[23], 
            d[25], d[26], d[27], d[29], d[31]})); 
    defparam x19 .WIDTH = 16;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[9], d[10], d[16], d[20], d[22], 
            d[24], d[26], d[27], d[28], d[30]})); 
    defparam x20 .WIDTH = 16;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[6], d[10], d[11], d[17], d[21], 
            d[23], d[25], d[27], d[28], d[29], d[31]})); 
    defparam x21 .WIDTH = 17;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[0], d[1], d[3], d[5], d[8], 
            d[11], d[13], d[14], d[16], d[17], d[18], 
            d[19], d[20], d[22], d[23], d[27], d[28], 
            d[30]})); 
    defparam x22 .WIDTH = 18;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[1], d[7], d[8], d[9], d[13], 
            d[15], d[16], d[18], d[21], d[26], d[27], 
            d[28], d[31]})); 
    defparam x23 .WIDTH = 13;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[2], d[8], d[9], d[10], d[14], 
            d[16], d[17], d[19], d[22], d[27], d[28], 
            d[29]})); 
    defparam x24 .WIDTH = 12;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[0], d[3], d[9], d[10], d[11], 
            d[15], d[17], d[18], d[20], d[23], d[28], 
            d[29], d[30]})); 
    defparam x25 .WIDTH = 13;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[0], d[1], d[2], d[6], d[7], 
            d[8], d[10], d[11], d[13], d[14], d[17], 
            d[18], d[20], d[21], d[23], d[26], d[27], 
            d[30], d[31]})); 
    defparam x26 .WIDTH = 19;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[1], d[2], d[3], d[7], d[8], 
            d[9], d[11], d[12], d[14], d[15], d[18], 
            d[19], d[21], d[22], d[24], d[27], d[28], 
            d[31]})); 
    defparam x27 .WIDTH = 18;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[0], d[2], d[3], d[4], d[8], 
            d[9], d[10], d[12], d[13], d[15], d[16], 
            d[19], d[20], d[22], d[23], d[25], d[28], 
            d[29]})); 
    defparam x28 .WIDTH = 18;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[1], d[3], d[4], d[5], d[9], 
            d[10], d[11], d[13], d[14], d[16], d[17], 
            d[20], d[21], d[23], d[24], d[26], d[29], 
            d[30]})); 
    defparam x29 .WIDTH = 18;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[2], d[4], d[5], d[6], 
            d[10], d[11], d[12], d[14], d[15], d[17], 
            d[18], d[21], d[22], d[24], d[25], d[27], 
            d[30], d[31]})); 
    defparam x30 .WIDTH = 19;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[1], d[3], d[5], d[6], d[7], 
            d[11], d[12], d[13], d[15], d[16], d[18], 
            d[19], d[22], d[23], d[25], d[26], d[28], 
            d[31]})); 
    defparam x31 .WIDTH = 18;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 17) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[4], d[9], d[10], d[11], d[12], 
            d[15], d[17], d[18], d[20], d[23], d[25], 
            d[26], d[29]})); 
    defparam x0 .WIDTH = 13;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[4], d[5], d[9], d[13], d[15], 
            d[16], d[17], d[19], d[20], d[21], d[23], 
            d[24], d[25], d[27], d[29], d[30]})); 
    defparam x1 .WIDTH = 16;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[0], d[4], d[5], d[6], d[9], 
            d[11], d[12], d[14], d[15], d[16], d[21], 
            d[22], d[23], d[24], d[28], d[29], d[30], 
            d[31]})); 
    defparam x2 .WIDTH = 18;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[0], d[1], d[5], d[6], d[7], 
            d[10], d[12], d[13], d[15], d[16], d[17], 
            d[22], d[23], d[24], d[25], d[29], d[30], 
            d[31]})); 
    defparam x3 .WIDTH = 18;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[0], d[1], d[2], d[4], d[6], 
            d[7], d[8], d[9], d[10], d[12], d[13], 
            d[14], d[15], d[16], d[20], d[24], d[29], 
            d[30], d[31]})); 
    defparam x4 .WIDTH = 19;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[7], d[8], d[12], d[13], d[14], 
            d[16], d[18], d[20], d[21], d[23], d[26], 
            d[29], d[30], d[31]})); 
    defparam x5 .WIDTH = 20;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[6], d[8], d[9], d[13], d[14], 
            d[15], d[17], d[19], d[21], d[22], d[24], 
            d[27], d[30], d[31]})); 
    defparam x6 .WIDTH = 20;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[1], d[2], d[3], d[5], d[6], 
            d[7], d[11], d[12], d[14], d[16], d[17], 
            d[22], d[26], d[28], d[29], d[31]})); 
    defparam x7 .WIDTH = 16;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[0], d[2], d[3], d[6], d[7], 
            d[8], d[9], d[10], d[11], d[13], d[20], 
            d[25], d[26], d[27], d[30]})); 
    defparam x8 .WIDTH = 15;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[1], d[3], d[4], d[7], d[8], 
            d[9], d[10], d[11], d[12], d[14], d[21], 
            d[26], d[27], d[28], d[31]})); 
    defparam x9 .WIDTH = 15;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[2], d[5], d[8], d[13], 
            d[17], d[18], d[20], d[22], d[23], d[25], 
            d[26], d[27], d[28]})); 
    defparam x10 .WIDTH = 14;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[1], d[3], d[4], d[6], 
            d[10], d[11], d[12], d[14], d[15], d[17], 
            d[19], d[20], d[21], d[24], d[25], d[27], 
            d[28]})); 
    defparam x11 .WIDTH = 18;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[1], d[2], d[5], d[7], d[9], 
            d[10], d[13], d[16], d[17], d[21], d[22], 
            d[23], d[28]})); 
    defparam x12 .WIDTH = 13;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[2], d[3], d[6], d[8], d[10], 
            d[11], d[14], d[17], d[18], d[22], d[23], 
            d[24], d[29]})); 
    defparam x13 .WIDTH = 13;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[0], d[3], d[4], d[7], d[9], 
            d[11], d[12], d[15], d[18], d[19], d[23], 
            d[24], d[25], d[30]})); 
    defparam x14 .WIDTH = 14;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[1], d[4], d[5], d[8], d[10], 
            d[12], d[13], d[16], d[19], d[20], d[24], 
            d[25], d[26], d[31]})); 
    defparam x15 .WIDTH = 14;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[0], d[2], d[4], d[5], d[6], 
            d[10], d[12], d[13], d[14], d[15], d[18], 
            d[21], d[23], d[27], d[29]})); 
    defparam x16 .WIDTH = 15;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[1], d[3], d[5], d[6], d[7], 
            d[11], d[13], d[14], d[15], d[16], d[19], 
            d[22], d[24], d[28], d[30]})); 
    defparam x17 .WIDTH = 15;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[2], d[4], d[6], d[7], 
            d[8], d[12], d[14], d[15], d[16], d[17], 
            d[20], d[23], d[25], d[29], d[31]})); 
    defparam x18 .WIDTH = 16;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[0], d[1], d[3], d[5], d[7], 
            d[8], d[9], d[13], d[15], d[16], d[17], 
            d[18], d[21], d[24], d[26], d[30]})); 
    defparam x19 .WIDTH = 16;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[1], d[2], d[4], d[6], 
            d[8], d[9], d[10], d[14], d[16], d[17], 
            d[18], d[19], d[22], d[25], d[27], d[31]})); 
    defparam x20 .WIDTH = 17;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[0], d[1], d[2], d[3], d[5], 
            d[7], d[9], d[10], d[11], d[15], d[17], 
            d[18], d[19], d[20], d[23], d[26], d[28]})); 
    defparam x21 .WIDTH = 17;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[1], d[2], d[3], d[6], d[8], 
            d[9], d[15], d[16], d[17], d[19], d[21], 
            d[23], d[24], d[25], d[26], d[27]})); 
    defparam x22 .WIDTH = 16;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[0], d[2], d[3], d[7], d[11], 
            d[12], d[15], d[16], d[22], d[23], d[24], 
            d[27], d[28], d[29]})); 
    defparam x23 .WIDTH = 14;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[1], d[3], d[4], d[8], d[12], 
            d[13], d[16], d[17], d[23], d[24], d[25], 
            d[28], d[29], d[30]})); 
    defparam x24 .WIDTH = 14;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[2], d[4], d[5], d[9], d[13], 
            d[14], d[17], d[18], d[24], d[25], d[26], 
            d[29], d[30], d[31]})); 
    defparam x25 .WIDTH = 14;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[3], d[4], d[5], d[6], d[9], 
            d[11], d[12], d[14], d[17], d[19], d[20], 
            d[23], d[27], d[29], d[30], d[31]})); 
    defparam x26 .WIDTH = 16;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[4], d[5], d[6], d[7], d[10], 
            d[12], d[13], d[15], d[18], d[20], d[21], 
            d[24], d[28], d[30], d[31]})); 
    defparam x27 .WIDTH = 15;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[0], d[5], d[6], d[7], d[8], 
            d[11], d[13], d[14], d[16], d[19], d[21], 
            d[22], d[25], d[29], d[31]})); 
    defparam x28 .WIDTH = 15;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[1], d[6], d[7], d[8], d[9], 
            d[12], d[14], d[15], d[17], d[20], d[22], 
            d[23], d[26], d[30]})); 
    defparam x29 .WIDTH = 14;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[2], d[7], d[8], d[9], d[10], 
            d[13], d[15], d[16], d[18], d[21], d[23], 
            d[24], d[27], d[31]})); 
    defparam x30 .WIDTH = 14;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[3], d[8], d[9], d[10], d[11], 
            d[14], d[16], d[17], d[19], d[22], d[24], 
            d[25], d[28]})); 
    defparam x31 .WIDTH = 13;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 18) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[0], d[3], d[4], d[7], d[10], 
            d[12], d[13], d[14], d[16], d[17], d[18], 
            d[20], d[22], d[28], d[29]})); 
    defparam x0 .WIDTH = 15;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[0], d[1], d[3], d[5], d[7], 
            d[8], d[10], d[11], d[12], d[15], d[16], 
            d[19], d[20], d[21], d[22], d[23], d[28], 
            d[30]})); 
    defparam x1 .WIDTH = 18;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[1], d[2], d[3], d[6], d[7], 
            d[8], d[9], d[10], d[11], d[14], d[18], 
            d[21], d[23], d[24], d[28], d[31]})); 
    defparam x2 .WIDTH = 16;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[0], d[2], d[3], d[4], d[7], 
            d[8], d[9], d[10], d[11], d[12], d[15], 
            d[19], d[22], d[24], d[25], d[29]})); 
    defparam x3 .WIDTH = 16;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[0], d[1], d[5], d[7], d[8], 
            d[9], d[11], d[14], d[17], d[18], d[22], 
            d[23], d[25], d[26], d[28], d[29], d[30]})); 
    defparam x4 .WIDTH = 17;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[1], d[2], d[3], d[4], d[6], 
            d[7], d[8], d[9], d[13], d[14], d[15], 
            d[16], d[17], d[19], d[20], d[22], d[23], 
            d[24], d[26], d[27], d[28], d[30], d[31]})); 
    defparam x5 .WIDTH = 23;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[0], d[2], d[3], d[4], d[5], 
            d[7], d[8], d[9], d[10], d[14], d[15], 
            d[16], d[17], d[18], d[20], d[21], d[23], 
            d[24], d[25], d[27], d[28], d[29], d[31]})); 
    defparam x6 .WIDTH = 23;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[1], d[5], d[6], d[7], 
            d[8], d[9], d[11], d[12], d[13], d[14], 
            d[15], d[19], d[20], d[21], d[24], d[25], 
            d[26], d[30]})); 
    defparam x7 .WIDTH = 19;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[1], d[2], d[3], d[4], d[6], 
            d[8], d[9], d[15], d[17], d[18], d[21], 
            d[25], d[26], d[27], d[28], d[29], d[31]})); 
    defparam x8 .WIDTH = 17;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[0], d[2], d[3], d[4], d[5], 
            d[7], d[9], d[10], d[16], d[18], d[19], 
            d[22], d[26], d[27], d[28], d[29], d[30]})); 
    defparam x9 .WIDTH = 17;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[1], d[5], d[6], d[7], d[8], 
            d[11], d[12], d[13], d[14], d[16], d[18], 
            d[19], d[22], d[23], d[27], d[30], d[31]})); 
    defparam x10 .WIDTH = 17;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[2], d[3], d[4], d[6], 
            d[8], d[9], d[10], d[15], d[16], d[18], 
            d[19], d[22], d[23], d[24], d[29], d[31]})); 
    defparam x11 .WIDTH = 17;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[1], d[5], d[9], d[11], d[12], 
            d[13], d[14], d[18], d[19], d[22], d[23], 
            d[24], d[25], d[28], d[29], d[30]})); 
    defparam x12 .WIDTH = 16;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[0], d[2], d[6], d[10], d[12], 
            d[13], d[14], d[15], d[19], d[20], d[23], 
            d[24], d[25], d[26], d[29], d[30], d[31]})); 
    defparam x13 .WIDTH = 17;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[1], d[3], d[7], d[11], d[13], 
            d[14], d[15], d[16], d[20], d[21], d[24], 
            d[25], d[26], d[27], d[30], d[31]})); 
    defparam x14 .WIDTH = 16;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[2], d[4], d[8], d[12], d[14], 
            d[15], d[16], d[17], d[21], d[22], d[25], 
            d[26], d[27], d[28], d[31]})); 
    defparam x15 .WIDTH = 15;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[0], d[4], d[5], d[7], d[9], 
            d[10], d[12], d[14], d[15], d[20], d[23], 
            d[26], d[27]})); 
    defparam x16 .WIDTH = 13;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[1], d[5], d[6], d[8], d[10], 
            d[11], d[13], d[15], d[16], d[21], d[24], 
            d[27], d[28]})); 
    defparam x17 .WIDTH = 13;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[2], d[6], d[7], d[9], d[11], 
            d[12], d[14], d[16], d[17], d[22], d[25], 
            d[28], d[29]})); 
    defparam x18 .WIDTH = 13;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[3], d[7], d[8], d[10], d[12], 
            d[13], d[15], d[17], d[18], d[23], d[26], 
            d[29], d[30]})); 
    defparam x19 .WIDTH = 13;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[4], d[8], d[9], d[11], d[13], 
            d[14], d[16], d[18], d[19], d[24], d[27], 
            d[30], d[31]})); 
    defparam x20 .WIDTH = 13;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[5], d[9], d[10], d[12], d[14], 
            d[15], d[17], d[19], d[20], d[25], d[28], 
            d[31]})); 
    defparam x21 .WIDTH = 12;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[3], d[4], d[6], d[7], d[11], 
            d[12], d[14], d[15], d[17], d[21], d[22], 
            d[26], d[28]})); 
    defparam x22 .WIDTH = 13;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[0], d[3], d[5], d[8], d[10], 
            d[14], d[15], d[17], d[20], d[23], d[27], 
            d[28]})); 
    defparam x23 .WIDTH = 12;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[1], d[4], d[6], d[9], d[11], 
            d[15], d[16], d[18], d[21], d[24], d[28], 
            d[29]})); 
    defparam x24 .WIDTH = 12;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[0], d[2], d[5], d[7], d[10], 
            d[12], d[16], d[17], d[19], d[22], d[25], 
            d[29], d[30]})); 
    defparam x25 .WIDTH = 13;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[1], d[4], d[6], d[7], d[8], 
            d[10], d[11], d[12], d[14], d[16], d[22], 
            d[23], d[26], d[28], d[29], d[30], d[31]})); 
    defparam x26 .WIDTH = 17;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[2], d[5], d[7], d[8], d[9], 
            d[11], d[12], d[13], d[15], d[17], d[23], 
            d[24], d[27], d[29], d[30], d[31]})); 
    defparam x27 .WIDTH = 16;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[0], d[3], d[6], d[8], d[9], 
            d[10], d[12], d[13], d[14], d[16], d[18], 
            d[24], d[25], d[28], d[30], d[31]})); 
    defparam x28 .WIDTH = 16;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[0], d[1], d[4], d[7], d[9], 
            d[10], d[11], d[13], d[14], d[15], d[17], 
            d[19], d[25], d[26], d[29], d[31]})); 
    defparam x29 .WIDTH = 16;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[1], d[2], d[5], d[8], d[10], 
            d[11], d[12], d[14], d[15], d[16], d[18], 
            d[20], d[26], d[27], d[30]})); 
    defparam x30 .WIDTH = 15;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[2], d[3], d[6], d[9], d[11], 
            d[12], d[13], d[15], d[16], d[17], d[19], 
            d[21], d[27], d[28], d[31]})); 
    defparam x31 .WIDTH = 15;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 19) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[1], d[3], d[4], d[9], d[10], 
            d[11], d[12], d[13], d[15], d[16], d[17], 
            d[22], d[23], d[24], d[25], d[26], d[27], 
            d[30], d[31]})); 
    defparam x0 .WIDTH = 19;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[1], d[2], d[3], d[5], d[9], 
            d[14], d[15], d[18], d[22], d[28], d[30]})); 
    defparam x1 .WIDTH = 11;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[0], d[1], d[2], d[6], d[9], 
            d[11], d[12], d[13], d[17], d[19], d[22], 
            d[24], d[25], d[26], d[27], d[29], d[30]})); 
    defparam x2 .WIDTH = 17;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[0], d[1], d[2], d[3], d[7], 
            d[10], d[12], d[13], d[14], d[18], d[20], 
            d[23], d[25], d[26], d[27], d[28], d[30], 
            d[31]})); 
    defparam x3 .WIDTH = 18;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[0], d[2], d[8], d[9], d[10], 
            d[12], d[14], d[16], d[17], d[19], d[21], 
            d[22], d[23], d[25], d[28], d[29], d[30]})); 
    defparam x4 .WIDTH = 17;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[4], d[12], d[16], d[18], d[20], 
            d[25], d[27], d[29]})); 
    defparam x5 .WIDTH = 8;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[5], d[13], d[17], d[19], d[21], 
            d[26], d[28], d[30]})); 
    defparam x6 .WIDTH = 8;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[1], d[3], d[4], d[6], 
            d[9], d[10], d[11], d[12], d[13], d[14], 
            d[15], d[16], d[17], d[18], d[20], d[23], 
            d[24], d[25], d[26], d[29], d[30]})); 
    defparam x7 .WIDTH = 22;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[2], d[3], d[5], d[7], d[9], 
            d[14], d[18], d[19], d[21], d[22], d[23]})); 
    defparam x8 .WIDTH = 11;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[0], d[3], d[4], d[6], d[8], 
            d[10], d[15], d[19], d[20], d[22], d[23], 
            d[24]})); 
    defparam x9 .WIDTH = 12;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[3], d[5], d[7], d[10], 
            d[12], d[13], d[15], d[17], d[20], d[21], 
            d[22], d[26], d[27], d[30], d[31]})); 
    defparam x10 .WIDTH = 16;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[3], d[6], d[8], d[9], d[10], 
            d[12], d[14], d[15], d[17], d[18], d[21], 
            d[24], d[25], d[26], d[28], d[30]})); 
    defparam x11 .WIDTH = 16;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[0], d[1], d[3], d[7], d[12], 
            d[17], d[18], d[19], d[23], d[24], d[29], 
            d[30]})); 
    defparam x12 .WIDTH = 12;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[1], d[2], d[4], d[8], d[13], 
            d[18], d[19], d[20], d[24], d[25], d[30], 
            d[31]})); 
    defparam x13 .WIDTH = 12;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[2], d[3], d[5], d[9], d[14], 
            d[19], d[20], d[21], d[25], d[26], d[31]})); 
    defparam x14 .WIDTH = 11;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[0], d[3], d[4], d[6], d[10], 
            d[15], d[20], d[21], d[22], d[26], d[27]})); 
    defparam x15 .WIDTH = 11;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[3], d[5], d[7], d[9], d[10], 
            d[12], d[13], d[15], d[17], d[21], d[24], 
            d[25], d[26], d[28], d[30], d[31]})); 
    defparam x16 .WIDTH = 16;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[4], d[6], d[8], d[10], d[11], 
            d[13], d[14], d[16], d[18], d[22], d[25], 
            d[26], d[27], d[29], d[31]})); 
    defparam x17 .WIDTH = 15;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[5], d[7], d[9], d[11], 
            d[12], d[14], d[15], d[17], d[19], d[23], 
            d[26], d[27], d[28], d[30]})); 
    defparam x18 .WIDTH = 15;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[0], d[1], d[6], d[8], d[10], 
            d[12], d[13], d[15], d[16], d[18], d[20], 
            d[24], d[27], d[28], d[29], d[31]})); 
    defparam x19 .WIDTH = 16;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[1], d[2], d[7], d[9], d[11], 
            d[13], d[14], d[16], d[17], d[19], d[21], 
            d[25], d[28], d[29], d[30]})); 
    defparam x20 .WIDTH = 15;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[2], d[3], d[8], d[10], d[12], 
            d[14], d[15], d[17], d[18], d[20], d[22], 
            d[26], d[29], d[30], d[31]})); 
    defparam x21 .WIDTH = 15;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[0], d[1], d[10], d[12], d[17], 
            d[18], d[19], d[21], d[22], d[24], d[25], 
            d[26]})); 
    defparam x22 .WIDTH = 12;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[2], d[3], d[4], d[9], d[10], 
            d[12], d[15], d[16], d[17], d[18], d[19], 
            d[20], d[24], d[30], d[31]})); 
    defparam x23 .WIDTH = 15;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[3], d[4], d[5], d[10], d[11], 
            d[13], d[16], d[17], d[18], d[19], d[20], 
            d[21], d[25], d[31]})); 
    defparam x24 .WIDTH = 14;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[0], d[4], d[5], d[6], d[11], 
            d[12], d[14], d[17], d[18], d[19], d[20], 
            d[21], d[22], d[26]})); 
    defparam x25 .WIDTH = 14;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[3], d[4], d[5], d[6], d[7], 
            d[9], d[10], d[11], d[16], d[17], d[18], 
            d[19], d[20], d[21], d[24], d[25], d[26], 
            d[30], d[31]})); 
    defparam x26 .WIDTH = 19;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[4], d[5], d[6], d[7], d[8], 
            d[10], d[11], d[12], d[17], d[18], d[19], 
            d[20], d[21], d[22], d[25], d[26], d[27], 
            d[31]})); 
    defparam x27 .WIDTH = 18;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[0], d[5], d[6], d[7], d[8], 
            d[9], d[11], d[12], d[13], d[18], d[19], 
            d[20], d[21], d[22], d[23], d[26], d[27], 
            d[28]})); 
    defparam x28 .WIDTH = 18;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[0], d[1], d[6], d[7], d[8], 
            d[9], d[10], d[12], d[13], d[14], d[19], 
            d[20], d[21], d[22], d[23], d[24], d[27], 
            d[28], d[29]})); 
    defparam x29 .WIDTH = 19;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[1], d[2], d[7], d[8], d[9], 
            d[10], d[11], d[13], d[14], d[15], d[20], 
            d[21], d[22], d[23], d[24], d[25], d[28], 
            d[29], d[30]})); 
    defparam x30 .WIDTH = 19;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[0], d[2], d[3], d[8], d[9], 
            d[10], d[11], d[12], d[14], d[15], d[16], 
            d[21], d[22], d[23], d[24], d[25], d[26], 
            d[29], d[30], d[31]})); 
    defparam x31 .WIDTH = 20;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 20) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[2], d[6], d[8], d[9], d[10], 
            d[15], d[16], d[17], d[19], d[21], d[27], 
            d[31]})); 
    defparam x0 .WIDTH = 12;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[2], d[3], d[6], d[7], d[8], 
            d[11], d[15], d[18], d[19], d[20], d[21], 
            d[22], d[27], d[28], d[31]})); 
    defparam x1 .WIDTH = 15;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[2], d[3], d[4], d[6], d[7], 
            d[10], d[12], d[15], d[17], d[20], d[22], 
            d[23], d[27], d[28], d[29], d[31]})); 
    defparam x2 .WIDTH = 16;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[3], d[4], d[5], d[7], d[8], 
            d[11], d[13], d[16], d[18], d[21], d[23], 
            d[24], d[28], d[29], d[30]})); 
    defparam x3 .WIDTH = 15;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[0], d[2], d[4], d[5], d[10], 
            d[12], d[14], d[15], d[16], d[21], d[22], 
            d[24], d[25], d[27], d[29], d[30]})); 
    defparam x4 .WIDTH = 16;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[0], d[1], d[2], d[3], d[5], 
            d[8], d[9], d[10], d[11], d[13], d[19], 
            d[21], d[22], d[23], d[25], d[26], d[27], 
            d[28], d[30]})); 
    defparam x5 .WIDTH = 19;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[6], d[9], d[10], d[11], d[12], d[14], 
            d[20], d[22], d[23], d[24], d[26], d[27], 
            d[28], d[29], d[31]})); 
    defparam x6 .WIDTH = 20;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[1], d[3], d[4], d[5], d[6], 
            d[7], d[8], d[9], d[11], d[12], d[13], 
            d[16], d[17], d[19], d[23], d[24], d[25], 
            d[28], d[29], d[30], d[31]})); 
    defparam x7 .WIDTH = 21;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[0], d[4], d[5], d[7], d[12], 
            d[13], d[14], d[15], d[16], d[18], d[19], 
            d[20], d[21], d[24], d[25], d[26], d[27], 
            d[29], d[30]})); 
    defparam x8 .WIDTH = 19;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[1], d[5], d[6], d[8], d[13], 
            d[14], d[15], d[16], d[17], d[19], d[20], 
            d[21], d[22], d[25], d[26], d[27], d[28], 
            d[30], d[31]})); 
    defparam x9 .WIDTH = 19;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[7], d[8], d[10], d[14], 
            d[18], d[19], d[20], d[22], d[23], d[26], 
            d[28], d[29]})); 
    defparam x10 .WIDTH = 13;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[1], d[2], d[6], d[10], d[11], 
            d[16], d[17], d[20], d[23], d[24], d[29], 
            d[30], d[31]})); 
    defparam x11 .WIDTH = 13;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[0], d[3], d[6], d[7], d[8], 
            d[9], d[10], d[11], d[12], d[15], d[16], 
            d[18], d[19], d[24], d[25], d[27], d[30]})); 
    defparam x12 .WIDTH = 17;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[0], d[1], d[4], d[7], d[8], 
            d[9], d[10], d[11], d[12], d[13], d[16], 
            d[17], d[19], d[20], d[25], d[26], d[28], 
            d[31]})); 
    defparam x13 .WIDTH = 18;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[0], d[1], d[2], d[5], d[8], 
            d[9], d[10], d[11], d[12], d[13], d[14], 
            d[17], d[18], d[20], d[21], d[26], d[27], 
            d[29]})); 
    defparam x14 .WIDTH = 18;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[1], d[2], d[3], d[6], d[9], 
            d[10], d[11], d[12], d[13], d[14], d[15], 
            d[18], d[19], d[21], d[22], d[27], d[28], 
            d[30]})); 
    defparam x15 .WIDTH = 18;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[0], d[3], d[4], d[6], d[7], 
            d[8], d[9], d[11], d[12], d[13], d[14], 
            d[17], d[20], d[21], d[22], d[23], d[27], 
            d[28], d[29]})); 
    defparam x16 .WIDTH = 19;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[0], d[1], d[4], d[5], d[7], 
            d[8], d[9], d[10], d[12], d[13], d[14], 
            d[15], d[18], d[21], d[22], d[23], d[24], 
            d[28], d[29], d[30]})); 
    defparam x17 .WIDTH = 20;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[1], d[2], d[5], d[6], 
            d[8], d[9], d[10], d[11], d[13], d[14], 
            d[15], d[16], d[19], d[22], d[23], d[24], 
            d[25], d[29], d[30], d[31]})); 
    defparam x18 .WIDTH = 21;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[1], d[2], d[3], d[6], d[7], 
            d[9], d[10], d[11], d[12], d[14], d[15], 
            d[16], d[17], d[20], d[23], d[24], d[25], 
            d[26], d[30], d[31]})); 
    defparam x19 .WIDTH = 20;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[2], d[3], d[4], d[7], d[8], 
            d[10], d[11], d[12], d[13], d[15], d[16], 
            d[17], d[18], d[21], d[24], d[25], d[26], 
            d[27], d[31]})); 
    defparam x20 .WIDTH = 19;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[0], d[3], d[4], d[5], d[8], 
            d[9], d[11], d[12], d[13], d[14], d[16], 
            d[17], d[18], d[19], d[22], d[25], d[26], 
            d[27], d[28]})); 
    defparam x21 .WIDTH = 19;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[0], d[1], d[2], d[4], d[5], 
            d[8], d[12], d[13], d[14], d[16], d[18], 
            d[20], d[21], d[23], d[26], d[28], d[29], 
            d[31]})); 
    defparam x22 .WIDTH = 18;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[0], d[1], d[3], d[5], d[8], 
            d[10], d[13], d[14], d[16], d[22], d[24], 
            d[29], d[30], d[31]})); 
    defparam x23 .WIDTH = 14;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[1], d[2], d[4], d[6], d[9], 
            d[11], d[14], d[15], d[17], d[23], d[25], 
            d[30], d[31]})); 
    defparam x24 .WIDTH = 13;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[2], d[3], d[5], d[7], d[10], 
            d[12], d[15], d[16], d[18], d[24], d[26], 
            d[31]})); 
    defparam x25 .WIDTH = 12;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[0], d[2], d[3], d[4], d[9], 
            d[10], d[11], d[13], d[15], d[21], d[25], 
            d[31]})); 
    defparam x26 .WIDTH = 12;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[1], d[3], d[4], d[5], d[10], 
            d[11], d[12], d[14], d[16], d[22], d[26]})); 
    defparam x27 .WIDTH = 11;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[2], d[4], d[5], d[6], d[11], 
            d[12], d[13], d[15], d[17], d[23], d[27]})); 
    defparam x28 .WIDTH = 11;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[3], d[5], d[6], d[7], d[12], 
            d[13], d[14], d[16], d[18], d[24], d[28]})); 
    defparam x29 .WIDTH = 11;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[4], d[6], d[7], d[8], 
            d[13], d[14], d[15], d[17], d[19], d[25], 
            d[29]})); 
    defparam x30 .WIDTH = 12;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[1], d[5], d[7], d[8], d[9], 
            d[14], d[15], d[16], d[18], d[20], d[26], 
            d[30]})); 
    defparam x31 .WIDTH = 12;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 21) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[0], d[1], d[3], d[4], d[10], 
            d[11], d[12], d[13], d[16], d[19], d[20], 
            d[22], d[26], d[29], d[31]})); 
    defparam x0 .WIDTH = 15;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[0], d[2], d[3], d[5], d[10], 
            d[14], d[16], d[17], d[19], d[21], d[22], 
            d[23], d[26], d[27], d[29], d[30], d[31]})); 
    defparam x1 .WIDTH = 17;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[0], d[6], d[10], d[12], d[13], 
            d[15], d[16], d[17], d[18], d[19], d[23], 
            d[24], d[26], d[27], d[28], d[29], d[30]})); 
    defparam x2 .WIDTH = 17;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[1], d[7], d[11], d[13], d[14], 
            d[16], d[17], d[18], d[19], d[20], d[24], 
            d[25], d[27], d[28], d[29], d[30], d[31]})); 
    defparam x3 .WIDTH = 17;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[1], d[2], d[3], d[4], d[8], 
            d[10], d[11], d[13], d[14], d[15], d[16], 
            d[17], d[18], d[21], d[22], d[25], d[28], 
            d[30]})); 
    defparam x4 .WIDTH = 18;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[1], d[2], d[5], d[9], d[10], 
            d[13], d[14], d[15], d[17], d[18], d[20], 
            d[23]})); 
    defparam x5 .WIDTH = 12;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[2], d[3], d[6], d[10], d[11], 
            d[14], d[15], d[16], d[18], d[19], d[21], 
            d[24]})); 
    defparam x6 .WIDTH = 12;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[1], d[7], d[10], d[13], 
            d[15], d[17], d[25], d[26], d[29], d[31]})); 
    defparam x7 .WIDTH = 11;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[2], d[3], d[4], d[8], d[10], 
            d[12], d[13], d[14], d[18], d[19], d[20], 
            d[22], d[27], d[29], d[30], d[31]})); 
    defparam x8 .WIDTH = 16;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[0], d[3], d[4], d[5], d[9], 
            d[11], d[13], d[14], d[15], d[19], d[20], 
            d[21], d[23], d[28], d[30], d[31]})); 
    defparam x9 .WIDTH = 16;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[3], d[5], d[6], d[11], 
            d[13], d[14], d[15], d[19], d[21], d[24], 
            d[26]})); 
    defparam x10 .WIDTH = 12;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[3], d[6], d[7], d[10], 
            d[11], d[13], d[14], d[15], d[19], d[25], 
            d[26], d[27], d[29], d[31]})); 
    defparam x11 .WIDTH = 15;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[3], d[7], d[8], d[10], d[13], 
            d[14], d[15], d[19], d[22], d[27], d[28], 
            d[29], d[30], d[31]})); 
    defparam x12 .WIDTH = 14;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[4], d[8], d[9], d[11], d[14], 
            d[15], d[16], d[20], d[23], d[28], d[29], 
            d[30], d[31]})); 
    defparam x13 .WIDTH = 13;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[0], d[5], d[9], d[10], d[12], 
            d[15], d[16], d[17], d[21], d[24], d[29], 
            d[30], d[31]})); 
    defparam x14 .WIDTH = 13;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[1], d[6], d[10], d[11], d[13], 
            d[16], d[17], d[18], d[22], d[25], d[30], 
            d[31]})); 
    defparam x15 .WIDTH = 12;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[1], d[2], d[3], d[4], d[7], 
            d[10], d[13], d[14], d[16], d[17], d[18], 
            d[20], d[22], d[23], d[29]})); 
    defparam x16 .WIDTH = 15;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[2], d[3], d[4], d[5], d[8], 
            d[11], d[14], d[15], d[17], d[18], d[19], 
            d[21], d[23], d[24], d[30]})); 
    defparam x17 .WIDTH = 15;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[3], d[4], d[5], d[6], 
            d[9], d[12], d[15], d[16], d[18], d[19], 
            d[20], d[22], d[24], d[25], d[31]})); 
    defparam x18 .WIDTH = 16;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[0], d[1], d[4], d[5], d[6], 
            d[7], d[10], d[13], d[16], d[17], d[19], 
            d[20], d[21], d[23], d[25], d[26]})); 
    defparam x19 .WIDTH = 16;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[1], d[2], d[5], d[6], d[7], 
            d[8], d[11], d[14], d[17], d[18], d[20], 
            d[21], d[22], d[24], d[26], d[27]})); 
    defparam x20 .WIDTH = 16;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[2], d[3], d[6], d[7], d[8], 
            d[9], d[12], d[15], d[18], d[19], d[21], 
            d[22], d[23], d[25], d[27], d[28]})); 
    defparam x21 .WIDTH = 16;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[0], d[1], d[7], d[8], d[9], 
            d[11], d[12], d[23], d[24], d[28], d[31]})); 
    defparam x22 .WIDTH = 11;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[0], d[2], d[3], d[4], d[8], 
            d[9], d[11], d[16], d[19], d[20], d[22], 
            d[24], d[25], d[26], d[31]})); 
    defparam x23 .WIDTH = 15;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[1], d[3], d[4], d[5], d[9], 
            d[10], d[12], d[17], d[20], d[21], d[23], 
            d[25], d[26], d[27]})); 
    defparam x24 .WIDTH = 14;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[0], d[2], d[4], d[5], d[6], 
            d[10], d[11], d[13], d[18], d[21], d[22], 
            d[24], d[26], d[27], d[28]})); 
    defparam x25 .WIDTH = 15;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[4], d[5], d[6], d[7], d[10], 
            d[13], d[14], d[16], d[20], d[23], d[25], 
            d[26], d[27], d[28], d[31]})); 
    defparam x26 .WIDTH = 15;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[5], d[6], d[7], d[8], d[11], 
            d[14], d[15], d[17], d[21], d[24], d[26], 
            d[27], d[28], d[29]})); 
    defparam x27 .WIDTH = 14;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[0], d[6], d[7], d[8], d[9], 
            d[12], d[15], d[16], d[18], d[22], d[25], 
            d[27], d[28], d[29], d[30]})); 
    defparam x28 .WIDTH = 15;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[0], d[1], d[7], d[8], d[9], 
            d[10], d[13], d[16], d[17], d[19], d[23], 
            d[26], d[28], d[29], d[30], d[31]})); 
    defparam x29 .WIDTH = 16;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[1], d[2], d[8], d[9], d[10], 
            d[11], d[14], d[17], d[18], d[20], d[24], 
            d[27], d[29], d[30], d[31]})); 
    defparam x30 .WIDTH = 15;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[0], d[2], d[3], d[9], d[10], 
            d[11], d[12], d[15], d[18], d[19], d[21], 
            d[25], d[28], d[30], d[31]})); 
    defparam x31 .WIDTH = 15;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 22) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[2], d[3], d[5], d[7], d[8], 
            d[9], d[10], d[12], d[14], d[17], d[20], 
            d[25], d[26], d[27], d[28], d[29], d[30]})); 
    defparam x0 .WIDTH = 17;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[0], d[2], d[4], d[5], d[6], 
            d[7], d[11], d[12], d[13], d[14], d[15], 
            d[17], d[18], d[20], d[21], d[25], d[31]})); 
    defparam x1 .WIDTH = 17;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[0], d[1], d[2], d[6], d[9], 
            d[10], d[13], d[15], d[16], d[17], d[18], 
            d[19], d[20], d[21], d[22], d[25], d[27], 
            d[28], d[29], d[30]})); 
    defparam x2 .WIDTH = 20;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[0], d[1], d[2], d[3], d[7], 
            d[10], d[11], d[14], d[16], d[17], d[18], 
            d[19], d[20], d[21], d[22], d[23], d[26], 
            d[28], d[29], d[30], d[31]})); 
    defparam x3 .WIDTH = 21;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[0], d[1], d[4], d[5], d[7], 
            d[9], d[10], d[11], d[14], d[15], d[18], 
            d[19], d[21], d[22], d[23], d[24], d[25], 
            d[26], d[28], d[31]})); 
    defparam x4 .WIDTH = 20;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[1], d[3], d[6], d[7], d[9], 
            d[11], d[14], d[15], d[16], d[17], d[19], 
            d[22], d[23], d[24], d[28], d[30]})); 
    defparam x5 .WIDTH = 16;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[2], d[4], d[7], d[8], d[10], 
            d[12], d[15], d[16], d[17], d[18], d[20], 
            d[23], d[24], d[25], d[29], d[31]})); 
    defparam x6 .WIDTH = 16;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[2], d[7], d[10], d[11], d[12], 
            d[13], d[14], d[16], d[18], d[19], d[20], 
            d[21], d[24], d[27], d[28], d[29]})); 
    defparam x7 .WIDTH = 16;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[2], d[5], d[7], d[9], d[10], 
            d[11], d[13], d[15], d[19], d[21], d[22], 
            d[26], d[27]})); 
    defparam x8 .WIDTH = 13;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[0], d[3], d[6], d[8], d[10], 
            d[11], d[12], d[14], d[16], d[20], d[22], 
            d[23], d[27], d[28]})); 
    defparam x9 .WIDTH = 14;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[1], d[2], d[3], d[4], d[5], 
            d[8], d[10], d[11], d[13], d[14], d[15], 
            d[20], d[21], d[23], d[24], d[25], d[26], 
            d[27], d[30]})); 
    defparam x10 .WIDTH = 19;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[4], d[6], d[7], d[8], d[10], 
            d[11], d[15], d[16], d[17], d[20], d[21], 
            d[22], d[24], d[29], d[30], d[31]})); 
    defparam x11 .WIDTH = 16;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[0], d[2], d[3], d[10], d[11], 
            d[14], d[16], d[18], d[20], d[21], d[22], 
            d[23], d[26], d[27], d[28], d[29], d[31]})); 
    defparam x12 .WIDTH = 17;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[0], d[1], d[3], d[4], d[11], 
            d[12], d[15], d[17], d[19], d[21], d[22], 
            d[23], d[24], d[27], d[28], d[29], d[30]})); 
    defparam x13 .WIDTH = 17;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[1], d[2], d[4], d[5], d[12], 
            d[13], d[16], d[18], d[20], d[22], d[23], 
            d[24], d[25], d[28], d[29], d[30], d[31]})); 
    defparam x14 .WIDTH = 17;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[0], d[2], d[3], d[5], d[6], 
            d[13], d[14], d[17], d[19], d[21], d[23], 
            d[24], d[25], d[26], d[29], d[30], d[31]})); 
    defparam x15 .WIDTH = 17;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[1], d[2], d[4], d[5], d[6], 
            d[8], d[9], d[10], d[12], d[15], d[17], 
            d[18], d[22], d[24], d[28], d[29], d[31]})); 
    defparam x16 .WIDTH = 17;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[2], d[3], d[5], d[6], d[7], 
            d[9], d[10], d[11], d[13], d[16], d[18], 
            d[19], d[23], d[25], d[29], d[30]})); 
    defparam x17 .WIDTH = 16;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[3], d[4], d[6], d[7], 
            d[8], d[10], d[11], d[12], d[14], d[17], 
            d[19], d[20], d[24], d[26], d[30], d[31]})); 
    defparam x18 .WIDTH = 17;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[1], d[4], d[5], d[7], d[8], 
            d[9], d[11], d[12], d[13], d[15], d[18], 
            d[20], d[21], d[25], d[27], d[31]})); 
    defparam x19 .WIDTH = 16;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[2], d[5], d[6], d[8], 
            d[9], d[10], d[12], d[13], d[14], d[16], 
            d[19], d[21], d[22], d[26], d[28]})); 
    defparam x20 .WIDTH = 16;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[1], d[3], d[6], d[7], d[9], 
            d[10], d[11], d[13], d[14], d[15], d[17], 
            d[20], d[22], d[23], d[27], d[29]})); 
    defparam x21 .WIDTH = 16;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[0], d[3], d[4], d[5], d[9], 
            d[11], d[15], d[16], d[17], d[18], d[20], 
            d[21], d[23], d[24], d[25], d[26], d[27], 
            d[29]})); 
    defparam x22 .WIDTH = 18;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[1], d[2], d[3], d[4], d[6], 
            d[7], d[8], d[9], d[14], d[16], d[18], 
            d[19], d[20], d[21], d[22], d[24], d[29]})); 
    defparam x23 .WIDTH = 17;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[2], d[3], d[4], d[5], d[7], 
            d[8], d[9], d[10], d[15], d[17], d[19], 
            d[20], d[21], d[22], d[23], d[25], d[30]})); 
    defparam x24 .WIDTH = 17;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[0], d[3], d[4], d[5], d[6], 
            d[8], d[9], d[10], d[11], d[16], d[18], 
            d[20], d[21], d[22], d[23], d[24], d[26], 
            d[31]})); 
    defparam x25 .WIDTH = 18;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[1], d[2], d[3], d[4], d[6], 
            d[8], d[11], d[14], d[19], d[20], d[21], 
            d[22], d[23], d[24], d[26], d[28], d[29], 
            d[30]})); 
    defparam x26 .WIDTH = 18;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[0], d[2], d[3], d[4], d[5], 
            d[7], d[9], d[12], d[15], d[20], d[21], 
            d[22], d[23], d[24], d[25], d[27], d[29], 
            d[30], d[31]})); 
    defparam x27 .WIDTH = 19;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[1], d[3], d[4], d[5], d[6], 
            d[8], d[10], d[13], d[16], d[21], d[22], 
            d[23], d[24], d[25], d[26], d[28], d[30], 
            d[31]})); 
    defparam x28 .WIDTH = 18;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[0], d[2], d[4], d[5], d[6], 
            d[7], d[9], d[11], d[14], d[17], d[22], 
            d[23], d[24], d[25], d[26], d[27], d[29], 
            d[31]})); 
    defparam x29 .WIDTH = 18;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[1], d[3], d[5], d[6], 
            d[7], d[8], d[10], d[12], d[15], d[18], 
            d[23], d[24], d[25], d[26], d[27], d[28], 
            d[30]})); 
    defparam x30 .WIDTH = 18;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[1], d[2], d[4], d[6], d[7], 
            d[8], d[9], d[11], d[13], d[16], d[19], 
            d[24], d[25], d[26], d[27], d[28], d[29], 
            d[31]})); 
    defparam x31 .WIDTH = 18;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 23) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[6], d[7], d[8], d[9], d[10], d[11], 
            d[13], d[14], d[16], d[18], d[23], d[24], 
            d[25], d[26], d[28], d[31]})); 
    defparam x0 .WIDTH = 21;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[5], d[6], d[12], d[13], d[15], 
            d[16], d[17], d[18], d[19], d[23], d[27], 
            d[28], d[29], d[31]})); 
    defparam x1 .WIDTH = 14;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[1], d[2], d[3], d[4], d[8], 
            d[9], d[10], d[11], d[17], d[19], d[20], 
            d[23], d[25], d[26], d[29], d[30], d[31]})); 
    defparam x2 .WIDTH = 17;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[2], d[3], d[4], d[5], d[9], 
            d[10], d[11], d[12], d[18], d[20], d[21], 
            d[24], d[26], d[27], d[30], d[31]})); 
    defparam x3 .WIDTH = 16;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[1], d[2], d[5], d[7], d[8], 
            d[9], d[12], d[14], d[16], d[18], d[19], 
            d[21], d[22], d[23], d[24], d[26], d[27]})); 
    defparam x4 .WIDTH = 17;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[1], d[4], d[7], d[11], d[14], 
            d[15], d[16], d[17], d[18], d[19], d[20], 
            d[22], d[26], d[27], d[31]})); 
    defparam x5 .WIDTH = 15;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[0], d[2], d[5], d[8], d[12], 
            d[15], d[16], d[17], d[18], d[19], d[20], 
            d[21], d[23], d[27], d[28]})); 
    defparam x6 .WIDTH = 15;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[2], d[4], d[7], d[8], d[10], 
            d[11], d[14], d[17], d[19], d[20], d[21], 
            d[22], d[23], d[25], d[26], d[29], d[31]})); 
    defparam x7 .WIDTH = 17;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[0], d[1], d[2], d[4], d[5], 
            d[6], d[7], d[10], d[12], d[13], d[14], 
            d[15], d[16], d[20], d[21], d[22], d[25], 
            d[27], d[28], d[30], d[31]})); 
    defparam x8 .WIDTH = 21;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[0], d[1], d[2], d[3], d[5], 
            d[6], d[7], d[8], d[11], d[13], d[14], 
            d[15], d[16], d[17], d[21], d[22], d[23], 
            d[26], d[28], d[29], d[31]})); 
    defparam x9 .WIDTH = 21;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[10], d[11], d[12], d[13], 
            d[15], d[17], d[22], d[25], d[26], d[27], 
            d[28], d[29], d[30], d[31]})); 
    defparam x10 .WIDTH = 15;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[2], d[3], d[4], d[6], d[7], 
            d[8], d[9], d[10], d[12], d[24], d[25], 
            d[27], d[29], d[30]})); 
    defparam x11 .WIDTH = 14;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[1], d[2], d[5], d[6], d[14], 
            d[16], d[18], d[23], d[24], d[30]})); 
    defparam x12 .WIDTH = 10;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[2], d[3], d[6], d[7], d[15], 
            d[17], d[19], d[24], d[25], d[31]})); 
    defparam x13 .WIDTH = 10;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[3], d[4], d[7], d[8], d[16], 
            d[18], d[20], d[25], d[26]})); 
    defparam x14 .WIDTH = 9;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[4], d[5], d[8], d[9], d[17], 
            d[19], d[21], d[26], d[27]})); 
    defparam x15 .WIDTH = 9;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[1], d[2], d[3], d[4], d[5], 
            d[7], d[8], d[11], d[13], d[14], d[16], 
            d[20], d[22], d[23], d[24], d[25], d[26], 
            d[27], d[31]})); 
    defparam x16 .WIDTH = 19;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[2], d[3], d[4], d[5], d[6], 
            d[8], d[9], d[12], d[14], d[15], d[17], 
            d[21], d[23], d[24], d[25], d[26], d[27], 
            d[28]})); 
    defparam x17 .WIDTH = 18;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[3], d[4], d[5], d[6], 
            d[7], d[9], d[10], d[13], d[15], d[16], 
            d[18], d[22], d[24], d[25], d[26], d[27], 
            d[28], d[29]})); 
    defparam x18 .WIDTH = 19;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[1], d[4], d[5], d[6], d[7], 
            d[8], d[10], d[11], d[14], d[16], d[17], 
            d[19], d[23], d[25], d[26], d[27], d[28], 
            d[29], d[30]})); 
    defparam x19 .WIDTH = 19;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[2], d[5], d[6], d[7], 
            d[8], d[9], d[11], d[12], d[15], d[17], 
            d[18], d[20], d[24], d[26], d[27], d[28], 
            d[29], d[30], d[31]})); 
    defparam x20 .WIDTH = 20;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[0], d[1], d[3], d[6], d[7], 
            d[8], d[9], d[10], d[12], d[13], d[16], 
            d[18], d[19], d[21], d[25], d[27], d[28], 
            d[29], d[30], d[31]})); 
    defparam x21 .WIDTH = 20;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[0], d[3], d[6], d[16], d[17], 
            d[18], d[19], d[20], d[22], d[23], d[24], 
            d[25], d[29], d[30]})); 
    defparam x22 .WIDTH = 14;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[2], d[3], d[6], d[8], d[9], 
            d[10], d[11], d[13], d[14], d[16], d[17], 
            d[19], d[20], d[21], d[28], d[30]})); 
    defparam x23 .WIDTH = 16;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[3], d[4], d[7], d[9], d[10], 
            d[11], d[12], d[14], d[15], d[17], d[18], 
            d[20], d[21], d[22], d[29], d[31]})); 
    defparam x24 .WIDTH = 16;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[4], d[5], d[8], d[10], d[11], 
            d[12], d[13], d[15], d[16], d[18], d[19], 
            d[21], d[22], d[23], d[30]})); 
    defparam x25 .WIDTH = 15;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[7], d[8], d[10], d[12], d[17], 
            d[18], d[19], d[20], d[22], d[25], d[26], 
            d[28]})); 
    defparam x26 .WIDTH = 18;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[1], d[2], d[3], d[4], d[5], 
            d[6], d[8], d[9], d[11], d[13], d[18], 
            d[19], d[20], d[21], d[23], d[26], d[27], 
            d[29]})); 
    defparam x27 .WIDTH = 18;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[0], d[2], d[3], d[4], d[5], 
            d[6], d[7], d[9], d[10], d[12], d[14], 
            d[19], d[20], d[21], d[22], d[24], d[27], 
            d[28], d[30]})); 
    defparam x28 .WIDTH = 19;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[0], d[1], d[3], d[4], d[5], 
            d[6], d[7], d[8], d[10], d[11], d[13], 
            d[15], d[20], d[21], d[22], d[23], d[25], 
            d[28], d[29], d[31]})); 
    defparam x29 .WIDTH = 20;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[1], d[2], d[4], d[5], 
            d[6], d[7], d[8], d[9], d[11], d[12], 
            d[14], d[16], d[21], d[22], d[23], d[24], 
            d[26], d[29], d[30]})); 
    defparam x30 .WIDTH = 20;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[0], d[1], d[2], d[3], d[5], 
            d[6], d[7], d[8], d[9], d[10], d[12], 
            d[13], d[15], d[17], d[22], d[23], d[24], 
            d[25], d[27], d[30], d[31]})); 
    defparam x31 .WIDTH = 21;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 24) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[1], d[2], d[4], d[8], d[10], 
            d[13], d[15], d[18], d[19], d[21], d[23], 
            d[26], d[27], d[28], d[29], d[30]})); 
    defparam x0 .WIDTH = 16;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[0], d[1], d[3], d[4], d[5], 
            d[8], d[9], d[10], d[11], d[13], d[14], 
            d[15], d[16], d[18], d[20], d[21], d[22], 
            d[23], d[24], d[26], d[31]})); 
    defparam x1 .WIDTH = 21;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[0], d[5], d[6], d[8], d[9], 
            d[11], d[12], d[13], d[14], d[16], d[17], 
            d[18], d[22], d[24], d[25], d[26], d[28], 
            d[29], d[30]})); 
    defparam x2 .WIDTH = 19;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[1], d[6], d[7], d[9], d[10], 
            d[12], d[13], d[14], d[15], d[17], d[18], 
            d[19], d[23], d[25], d[26], d[27], d[29], 
            d[30], d[31]})); 
    defparam x3 .WIDTH = 19;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[1], d[4], d[7], d[11], d[14], 
            d[16], d[20], d[21], d[23], d[24], d[29], 
            d[31]})); 
    defparam x4 .WIDTH = 12;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[1], d[4], d[5], d[10], d[12], 
            d[13], d[17], d[18], d[19], d[22], d[23], 
            d[24], d[25], d[26], d[27], d[28], d[29]})); 
    defparam x5 .WIDTH = 17;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[0], d[2], d[5], d[6], d[11], 
            d[13], d[14], d[18], d[19], d[20], d[23], 
            d[24], d[25], d[26], d[27], d[28], d[29], 
            d[30]})); 
    defparam x6 .WIDTH = 18;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[2], d[3], d[4], d[6], d[7], 
            d[8], d[10], d[12], d[13], d[14], d[18], 
            d[20], d[23], d[24], d[25], d[31]})); 
    defparam x7 .WIDTH = 16;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[0], d[1], d[2], d[3], d[5], 
            d[7], d[9], d[10], d[11], d[14], d[18], 
            d[23], d[24], d[25], d[27], d[28], d[29], 
            d[30]})); 
    defparam x8 .WIDTH = 18;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[1], d[2], d[3], d[4], d[6], 
            d[8], d[10], d[11], d[12], d[15], d[19], 
            d[24], d[25], d[26], d[28], d[29], d[30], 
            d[31]})); 
    defparam x9 .WIDTH = 18;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[1], d[3], d[5], d[7], 
            d[8], d[9], d[10], d[11], d[12], d[15], 
            d[16], d[18], d[19], d[20], d[21], d[23], 
            d[25], d[28], d[31]})); 
    defparam x10 .WIDTH = 20;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[6], d[9], d[11], d[12], 
            d[15], d[16], d[17], d[18], d[20], d[22], 
            d[23], d[24], d[27], d[28], d[30]})); 
    defparam x11 .WIDTH = 16;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[2], d[4], d[7], d[8], d[12], 
            d[15], d[16], d[17], d[24], d[25], d[26], 
            d[27], d[30], d[31]})); 
    defparam x12 .WIDTH = 14;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[0], d[3], d[5], d[8], d[9], 
            d[13], d[16], d[17], d[18], d[25], d[26], 
            d[27], d[28], d[31]})); 
    defparam x13 .WIDTH = 14;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[0], d[1], d[4], d[6], d[9], 
            d[10], d[14], d[17], d[18], d[19], d[26], 
            d[27], d[28], d[29]})); 
    defparam x14 .WIDTH = 14;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[1], d[2], d[5], d[7], d[10], 
            d[11], d[15], d[18], d[19], d[20], d[27], 
            d[28], d[29], d[30]})); 
    defparam x15 .WIDTH = 14;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[0], d[1], d[3], d[4], d[6], 
            d[10], d[11], d[12], d[13], d[15], d[16], 
            d[18], d[20], d[23], d[26], d[27], d[31]})); 
    defparam x16 .WIDTH = 17;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[0], d[1], d[2], d[4], d[5], 
            d[7], d[11], d[12], d[13], d[14], d[16], 
            d[17], d[19], d[21], d[24], d[27], d[28]})); 
    defparam x17 .WIDTH = 17;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[1], d[2], d[3], d[5], d[6], 
            d[8], d[12], d[13], d[14], d[15], d[17], 
            d[18], d[20], d[22], d[25], d[28], d[29]})); 
    defparam x18 .WIDTH = 17;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[2], d[3], d[4], d[6], d[7], 
            d[9], d[13], d[14], d[15], d[16], d[18], 
            d[19], d[21], d[23], d[26], d[29], d[30]})); 
    defparam x19 .WIDTH = 17;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[3], d[4], d[5], d[7], 
            d[8], d[10], d[14], d[15], d[16], d[17], 
            d[19], d[20], d[22], d[24], d[27], d[30], 
            d[31]})); 
    defparam x20 .WIDTH = 18;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[1], d[4], d[5], d[6], d[8], 
            d[9], d[11], d[15], d[16], d[17], d[18], 
            d[20], d[21], d[23], d[25], d[28], d[31]})); 
    defparam x21 .WIDTH = 17;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[0], d[1], d[4], d[5], d[6], 
            d[7], d[8], d[9], d[12], d[13], d[15], 
            d[16], d[17], d[22], d[23], d[24], d[27], 
            d[28], d[30]})); 
    defparam x22 .WIDTH = 19;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[4], d[5], d[6], d[7], d[9], 
            d[14], d[15], d[16], d[17], d[19], d[21], 
            d[24], d[25], d[26], d[27], d[30], d[31]})); 
    defparam x23 .WIDTH = 17;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[5], d[6], d[7], d[8], d[10], 
            d[15], d[16], d[17], d[18], d[20], d[22], 
            d[25], d[26], d[27], d[28], d[31]})); 
    defparam x24 .WIDTH = 16;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[0], d[6], d[7], d[8], d[9], 
            d[11], d[16], d[17], d[18], d[19], d[21], 
            d[23], d[26], d[27], d[28], d[29]})); 
    defparam x25 .WIDTH = 16;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[2], d[4], d[7], d[9], d[12], 
            d[13], d[15], d[17], d[20], d[21], d[22], 
            d[23], d[24], d[26]})); 
    defparam x26 .WIDTH = 14;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[3], d[5], d[8], d[10], d[13], 
            d[14], d[16], d[18], d[21], d[22], d[23], 
            d[24], d[25], d[27]})); 
    defparam x27 .WIDTH = 14;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[0], d[4], d[6], d[9], d[11], 
            d[14], d[15], d[17], d[19], d[22], d[23], 
            d[24], d[25], d[26], d[28]})); 
    defparam x28 .WIDTH = 15;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[1], d[5], d[7], d[10], d[12], 
            d[15], d[16], d[18], d[20], d[23], d[24], 
            d[25], d[26], d[27], d[29]})); 
    defparam x29 .WIDTH = 15;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[2], d[6], d[8], d[11], 
            d[13], d[16], d[17], d[19], d[21], d[24], 
            d[25], d[26], d[27], d[28], d[30]})); 
    defparam x30 .WIDTH = 16;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[0], d[1], d[3], d[7], d[9], 
            d[12], d[14], d[17], d[18], d[20], d[22], 
            d[25], d[26], d[27], d[28], d[29], d[31]})); 
    defparam x31 .WIDTH = 17;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 25) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[1], d[2], d[4], d[5], d[6], 
            d[7], d[8], d[10], d[11], d[12], d[14], 
            d[15], d[17], d[19], d[20], d[22], d[26], 
            d[29]})); 
    defparam x0 .WIDTH = 18;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[1], d[3], d[4], d[9], d[10], 
            d[13], d[14], d[16], d[17], d[18], d[19], 
            d[21], d[22], d[23], d[26], d[27], d[29], 
            d[30]})); 
    defparam x1 .WIDTH = 18;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[0], d[1], d[6], d[7], d[8], 
            d[12], d[18], d[23], d[24], d[26], d[27], 
            d[28], d[29], d[30], d[31]})); 
    defparam x2 .WIDTH = 15;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[0], d[1], d[2], d[7], d[8], 
            d[9], d[13], d[19], d[24], d[25], d[27], 
            d[28], d[29], d[30], d[31]})); 
    defparam x3 .WIDTH = 15;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[3], d[4], d[5], d[6], d[7], 
            d[9], d[11], d[12], d[15], d[17], d[19], 
            d[22], d[25], d[28], d[30], d[31]})); 
    defparam x4 .WIDTH = 16;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[1], d[2], d[11], d[13], d[14], 
            d[15], d[16], d[17], d[18], d[19], d[22], 
            d[23], d[31]})); 
    defparam x5 .WIDTH = 13;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[0], d[2], d[3], d[12], d[14], 
            d[15], d[16], d[17], d[18], d[19], d[20], 
            d[23], d[24]})); 
    defparam x6 .WIDTH = 13;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[2], d[3], d[5], d[6], 
            d[7], d[8], d[10], d[11], d[12], d[13], 
            d[14], d[16], d[18], d[21], d[22], d[24], 
            d[25], d[26], d[29]})); 
    defparam x7 .WIDTH = 20;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[0], d[2], d[3], d[5], d[9], 
            d[10], d[13], d[20], d[23], d[25], d[27], 
            d[29], d[30]})); 
    defparam x8 .WIDTH = 13;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[0], d[1], d[3], d[4], d[6], 
            d[10], d[11], d[14], d[21], d[24], d[26], 
            d[28], d[30], d[31]})); 
    defparam x9 .WIDTH = 14;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[6], d[8], d[10], d[14], 
            d[17], d[19], d[20], d[25], d[26], d[27], 
            d[31]})); 
    defparam x10 .WIDTH = 12;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[2], d[4], d[5], d[6], 
            d[8], d[9], d[10], d[12], d[14], d[17], 
            d[18], d[19], d[21], d[22], d[27], d[28], 
            d[29]})); 
    defparam x11 .WIDTH = 18;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[0], d[2], d[3], d[4], d[8], 
            d[9], d[12], d[13], d[14], d[17], d[18], 
            d[23], d[26], d[28], d[30]})); 
    defparam x12 .WIDTH = 15;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[1], d[3], d[4], d[5], d[9], 
            d[10], d[13], d[14], d[15], d[18], d[19], 
            d[24], d[27], d[29], d[31]})); 
    defparam x13 .WIDTH = 15;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[0], d[2], d[4], d[5], d[6], 
            d[10], d[11], d[14], d[15], d[16], d[19], 
            d[20], d[25], d[28], d[30]})); 
    defparam x14 .WIDTH = 15;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[0], d[1], d[3], d[5], d[6], 
            d[7], d[11], d[12], d[15], d[16], d[17], 
            d[20], d[21], d[26], d[29], d[31]})); 
    defparam x15 .WIDTH = 16;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[0], d[5], d[10], d[11], d[13], 
            d[14], d[15], d[16], d[18], d[19], d[20], 
            d[21], d[26], d[27], d[29], d[30]})); 
    defparam x16 .WIDTH = 16;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[0], d[1], d[6], d[11], d[12], 
            d[14], d[15], d[16], d[17], d[19], d[20], 
            d[21], d[22], d[27], d[28], d[30], d[31]})); 
    defparam x17 .WIDTH = 17;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[1], d[2], d[7], d[12], d[13], 
            d[15], d[16], d[17], d[18], d[20], d[21], 
            d[22], d[23], d[28], d[29], d[31]})); 
    defparam x18 .WIDTH = 16;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[2], d[3], d[8], d[13], d[14], 
            d[16], d[17], d[18], d[19], d[21], d[22], 
            d[23], d[24], d[29], d[30]})); 
    defparam x19 .WIDTH = 15;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[3], d[4], d[9], d[14], 
            d[15], d[17], d[18], d[19], d[20], d[22], 
            d[23], d[24], d[25], d[30], d[31]})); 
    defparam x20 .WIDTH = 16;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[1], d[4], d[5], d[10], d[15], 
            d[16], d[18], d[19], d[20], d[21], d[23], 
            d[24], d[25], d[26], d[31]})); 
    defparam x21 .WIDTH = 15;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[0], d[1], d[4], d[7], d[8], 
            d[10], d[12], d[14], d[15], d[16], d[21], 
            d[24], d[25], d[27], d[29]})); 
    defparam x22 .WIDTH = 15;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[4], d[6], d[7], d[9], d[10], 
            d[12], d[13], d[14], d[16], d[19], d[20], 
            d[25], d[28], d[29], d[30]})); 
    defparam x23 .WIDTH = 15;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[5], d[7], d[8], d[10], d[11], 
            d[13], d[14], d[15], d[17], d[20], d[21], 
            d[26], d[29], d[30], d[31]})); 
    defparam x24 .WIDTH = 15;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[6], d[8], d[9], d[11], d[12], 
            d[14], d[15], d[16], d[18], d[21], d[22], 
            d[27], d[30], d[31]})); 
    defparam x25 .WIDTH = 14;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[0], d[1], d[2], d[4], d[5], 
            d[6], d[8], d[9], d[11], d[13], d[14], 
            d[16], d[20], d[23], d[26], d[28], d[29], 
            d[31]})); 
    defparam x26 .WIDTH = 18;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[0], d[1], d[2], d[3], d[5], 
            d[6], d[7], d[9], d[10], d[12], d[14], 
            d[15], d[17], d[21], d[24], d[27], d[29], 
            d[30]})); 
    defparam x27 .WIDTH = 18;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[6], d[7], d[8], d[10], d[11], d[13], 
            d[15], d[16], d[18], d[22], d[25], d[28], 
            d[30], d[31]})); 
    defparam x28 .WIDTH = 19;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[1], d[2], d[3], d[4], d[5], 
            d[7], d[8], d[9], d[11], d[12], d[14], 
            d[16], d[17], d[19], d[23], d[26], d[29], 
            d[31]})); 
    defparam x29 .WIDTH = 18;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[2], d[3], d[4], d[5], 
            d[6], d[8], d[9], d[10], d[12], d[13], 
            d[15], d[17], d[18], d[20], d[24], d[27], 
            d[30]})); 
    defparam x30 .WIDTH = 18;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[0], d[1], d[3], d[4], d[5], 
            d[6], d[7], d[9], d[10], d[11], d[13], 
            d[14], d[16], d[18], d[19], d[21], d[25], 
            d[28], d[31]})); 
    defparam x31 .WIDTH = 19;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 26) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[2], d[6], d[7], d[8], d[13], 
            d[15], d[16], d[18], d[20], d[23], d[25], 
            d[28], d[30]})); 
    defparam x0 .WIDTH = 13;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[2], d[3], d[6], d[9], d[13], 
            d[14], d[15], d[17], d[18], d[19], d[20], 
            d[21], d[23], d[24], d[25], d[26], d[28], 
            d[29], d[30], d[31]})); 
    defparam x1 .WIDTH = 20;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[0], d[2], d[3], d[4], d[6], 
            d[8], d[10], d[13], d[14], d[19], d[21], 
            d[22], d[23], d[24], d[26], d[27], d[28], 
            d[29], d[31]})); 
    defparam x2 .WIDTH = 19;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[1], d[3], d[4], d[5], d[7], 
            d[9], d[11], d[14], d[15], d[20], d[22], 
            d[23], d[24], d[25], d[27], d[28], d[29], 
            d[30]})); 
    defparam x3 .WIDTH = 18;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[0], d[4], d[5], d[7], d[10], 
            d[12], d[13], d[18], d[20], d[21], d[24], 
            d[26], d[29], d[31]})); 
    defparam x4 .WIDTH = 14;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[1], d[2], d[5], d[7], d[11], 
            d[14], d[15], d[16], d[18], d[19], d[20], 
            d[21], d[22], d[23], d[27], d[28]})); 
    defparam x5 .WIDTH = 16;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[2], d[3], d[6], d[8], d[12], 
            d[15], d[16], d[17], d[19], d[20], d[21], 
            d[22], d[23], d[24], d[28], d[29]})); 
    defparam x6 .WIDTH = 16;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[2], d[3], d[4], d[6], 
            d[8], d[9], d[15], d[17], d[21], d[22], 
            d[24], d[28], d[29]})); 
    defparam x7 .WIDTH = 14;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[1], d[2], d[3], d[4], d[5], 
            d[6], d[8], d[9], d[10], d[13], d[15], 
            d[20], d[22], d[28], d[29]})); 
    defparam x8 .WIDTH = 15;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[2], d[3], d[4], d[5], d[6], 
            d[7], d[9], d[10], d[11], d[14], d[16], 
            d[21], d[23], d[29], d[30]})); 
    defparam x9 .WIDTH = 15;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[2], d[3], d[4], d[5], d[10], 
            d[11], d[12], d[13], d[16], d[17], d[18], 
            d[20], d[22], d[23], d[24], d[25], d[28], 
            d[31]})); 
    defparam x10 .WIDTH = 18;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[2], d[3], d[4], d[5], 
            d[7], d[8], d[11], d[12], d[14], d[15], 
            d[16], d[17], d[19], d[20], d[21], d[24], 
            d[26], d[28], d[29], d[30]})); 
    defparam x11 .WIDTH = 21;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[7], d[9], d[12], d[17], d[21], 
            d[22], d[23], d[27], d[28], d[29], d[31]})); 
    defparam x12 .WIDTH = 17;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[6], d[8], d[10], d[13], d[18], 
            d[22], d[23], d[24], d[28], d[29], d[30]})); 
    defparam x13 .WIDTH = 17;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[6], d[7], d[9], d[11], d[14], 
            d[19], d[23], d[24], d[25], d[29], d[30], 
            d[31]})); 
    defparam x14 .WIDTH = 18;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[1], d[2], d[3], d[4], d[5], 
            d[6], d[7], d[8], d[10], d[12], d[15], 
            d[20], d[24], d[25], d[26], d[30], d[31]})); 
    defparam x15 .WIDTH = 17;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[0], d[3], d[4], d[5], d[9], 
            d[11], d[15], d[18], d[20], d[21], d[23], 
            d[26], d[27], d[28], d[30], d[31]})); 
    defparam x16 .WIDTH = 16;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[1], d[4], d[5], d[6], d[10], 
            d[12], d[16], d[19], d[21], d[22], d[24], 
            d[27], d[28], d[29], d[31]})); 
    defparam x17 .WIDTH = 15;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[2], d[5], d[6], d[7], 
            d[11], d[13], d[17], d[20], d[22], d[23], 
            d[25], d[28], d[29], d[30]})); 
    defparam x18 .WIDTH = 15;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[1], d[3], d[6], d[7], d[8], 
            d[12], d[14], d[18], d[21], d[23], d[24], 
            d[26], d[29], d[30], d[31]})); 
    defparam x19 .WIDTH = 15;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[2], d[4], d[7], d[8], d[9], 
            d[13], d[15], d[19], d[22], d[24], d[25], 
            d[27], d[30], d[31]})); 
    defparam x20 .WIDTH = 14;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[0], d[3], d[5], d[8], d[9], 
            d[10], d[14], d[16], d[20], d[23], d[25], 
            d[26], d[28], d[31]})); 
    defparam x21 .WIDTH = 14;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[1], d[2], d[4], d[7], d[8], 
            d[9], d[10], d[11], d[13], d[16], d[17], 
            d[18], d[20], d[21], d[23], d[24], d[25], 
            d[26], d[27], d[28], d[29], d[30]})); 
    defparam x22 .WIDTH = 22;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[3], d[5], d[6], d[7], d[9], 
            d[10], d[11], d[12], d[13], d[14], d[15], 
            d[16], d[17], d[19], d[20], d[21], d[22], 
            d[23], d[24], d[26], d[27], d[29], d[31]})); 
    defparam x23 .WIDTH = 23;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[4], d[6], d[7], d[8], d[10], 
            d[11], d[12], d[13], d[14], d[15], d[16], 
            d[17], d[18], d[20], d[21], d[22], d[23], 
            d[24], d[25], d[27], d[28], d[30]})); 
    defparam x24 .WIDTH = 22;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[0], d[5], d[7], d[8], d[9], 
            d[11], d[12], d[13], d[14], d[15], d[16], 
            d[17], d[18], d[19], d[21], d[22], d[23], 
            d[24], d[25], d[26], d[28], d[29], d[31]})); 
    defparam x25 .WIDTH = 23;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[0], d[1], d[2], d[7], d[9], 
            d[10], d[12], d[14], d[17], d[19], d[22], 
            d[24], d[26], d[27], d[28], d[29]})); 
    defparam x26 .WIDTH = 16;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[1], d[2], d[3], d[8], d[10], 
            d[11], d[13], d[15], d[18], d[20], d[23], 
            d[25], d[27], d[28], d[29], d[30]})); 
    defparam x27 .WIDTH = 16;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[2], d[3], d[4], d[9], d[11], 
            d[12], d[14], d[16], d[19], d[21], d[24], 
            d[26], d[28], d[29], d[30], d[31]})); 
    defparam x28 .WIDTH = 16;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[3], d[4], d[5], d[10], d[12], 
            d[13], d[15], d[17], d[20], d[22], d[25], 
            d[27], d[29], d[30], d[31]})); 
    defparam x29 .WIDTH = 15;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[4], d[5], d[6], d[11], 
            d[13], d[14], d[16], d[18], d[21], d[23], 
            d[26], d[28], d[30], d[31]})); 
    defparam x30 .WIDTH = 15;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[1], d[5], d[6], d[7], d[12], 
            d[14], d[15], d[17], d[19], d[22], d[24], 
            d[27], d[29], d[31]})); 
    defparam x31 .WIDTH = 14;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 27) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[0], d[1], d[3], d[6], d[7], 
            d[9], d[12], d[13], d[14], d[15], d[17], 
            d[18], d[20], d[21], d[22], d[27], d[28], 
            d[31]})); 
    defparam x0 .WIDTH = 18;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[0], d[2], d[3], d[4], d[6], 
            d[8], d[9], d[10], d[12], d[16], d[17], 
            d[19], d[20], d[23], d[27], d[29], d[31]})); 
    defparam x1 .WIDTH = 17;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[4], d[5], d[6], d[10], d[11], 
            d[12], d[14], d[15], d[22], d[24], d[27], 
            d[30], d[31]})); 
    defparam x2 .WIDTH = 13;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[0], d[5], d[6], d[7], d[11], 
            d[12], d[13], d[15], d[16], d[23], d[25], 
            d[28], d[31]})); 
    defparam x3 .WIDTH = 13;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[3], d[8], d[9], d[15], d[16], 
            d[18], d[20], d[21], d[22], d[24], d[26], 
            d[27], d[28], d[29], d[31]})); 
    defparam x4 .WIDTH = 15;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[0], d[1], d[3], d[4], d[6], 
            d[7], d[10], d[12], d[13], d[14], d[15], 
            d[16], d[18], d[19], d[20], d[23], d[25], 
            d[29], d[30], d[31]})); 
    defparam x5 .WIDTH = 20;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[1], d[2], d[4], d[5], d[7], 
            d[8], d[11], d[13], d[14], d[15], d[16], 
            d[17], d[19], d[20], d[21], d[24], d[26], 
            d[30], d[31]})); 
    defparam x6 .WIDTH = 19;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[1], d[2], d[5], d[7], d[8], 
            d[13], d[16], d[25], d[28]})); 
    defparam x7 .WIDTH = 9;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[1], d[2], d[7], d[8], d[12], 
            d[13], d[15], d[18], d[20], d[21], d[22], 
            d[26], d[27], d[28], d[29], d[31]})); 
    defparam x8 .WIDTH = 16;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[2], d[3], d[8], d[9], d[13], 
            d[14], d[16], d[19], d[21], d[22], d[23], 
            d[27], d[28], d[29], d[30]})); 
    defparam x9 .WIDTH = 15;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[1], d[4], d[6], d[7], 
            d[10], d[12], d[13], d[18], d[21], d[23], 
            d[24], d[27], d[29], d[30]})); 
    defparam x10 .WIDTH = 15;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[2], d[3], d[5], d[6], d[8], 
            d[9], d[11], d[12], d[15], d[17], d[18], 
            d[19], d[20], d[21], d[24], d[25], d[27], 
            d[30]})); 
    defparam x11 .WIDTH = 18;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[1], d[4], d[10], d[14], d[15], 
            d[16], d[17], d[19], d[25], d[26], d[27]})); 
    defparam x12 .WIDTH = 11;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[0], d[2], d[5], d[11], d[15], 
            d[16], d[17], d[18], d[20], d[26], d[27], 
            d[28]})); 
    defparam x13 .WIDTH = 12;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[0], d[1], d[3], d[6], d[12], 
            d[16], d[17], d[18], d[19], d[21], d[27], 
            d[28], d[29]})); 
    defparam x14 .WIDTH = 13;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[0], d[1], d[2], d[4], d[7], 
            d[13], d[17], d[18], d[19], d[20], d[22], 
            d[28], d[29], d[30]})); 
    defparam x15 .WIDTH = 14;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[2], d[5], d[6], d[7], d[8], 
            d[9], d[12], d[13], d[15], d[17], d[19], 
            d[22], d[23], d[27], d[28], d[29], d[30]})); 
    defparam x16 .WIDTH = 17;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[0], d[3], d[6], d[7], d[8], 
            d[9], d[10], d[13], d[14], d[16], d[18], 
            d[20], d[23], d[24], d[28], d[29], d[30], 
            d[31]})); 
    defparam x17 .WIDTH = 18;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[1], d[4], d[7], d[8], 
            d[9], d[10], d[11], d[14], d[15], d[17], 
            d[19], d[21], d[24], d[25], d[29], d[30], 
            d[31]})); 
    defparam x18 .WIDTH = 18;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[0], d[1], d[2], d[5], d[8], 
            d[9], d[10], d[11], d[12], d[15], d[16], 
            d[18], d[20], d[22], d[25], d[26], d[30], 
            d[31]})); 
    defparam x19 .WIDTH = 18;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[1], d[2], d[3], d[6], 
            d[9], d[10], d[11], d[12], d[13], d[16], 
            d[17], d[19], d[21], d[23], d[26], d[27], 
            d[31]})); 
    defparam x20 .WIDTH = 18;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[7], d[10], d[11], d[12], d[13], d[14], 
            d[17], d[18], d[20], d[22], d[24], d[27], 
            d[28]})); 
    defparam x21 .WIDTH = 18;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[0], d[2], d[4], d[5], d[6], 
            d[7], d[8], d[9], d[11], d[17], d[19], 
            d[20], d[22], d[23], d[25], d[27], d[29], 
            d[31]})); 
    defparam x22 .WIDTH = 18;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[5], d[8], d[10], d[13], d[14], 
            d[15], d[17], d[22], d[23], d[24], d[26], 
            d[27], d[30], d[31]})); 
    defparam x23 .WIDTH = 14;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[6], d[9], d[11], d[14], d[15], 
            d[16], d[18], d[23], d[24], d[25], d[27], 
            d[28], d[31]})); 
    defparam x24 .WIDTH = 13;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[7], d[10], d[12], d[15], d[16], 
            d[17], d[19], d[24], d[25], d[26], d[28], 
            d[29]})); 
    defparam x25 .WIDTH = 12;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[0], d[1], d[3], d[6], d[7], 
            d[8], d[9], d[11], d[12], d[14], d[15], 
            d[16], d[21], d[22], d[25], d[26], d[28], 
            d[29], d[30], d[31]})); 
    defparam x26 .WIDTH = 20;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[1], d[2], d[4], d[7], d[8], 
            d[9], d[10], d[12], d[13], d[15], d[16], 
            d[17], d[22], d[23], d[26], d[27], d[29], 
            d[30], d[31]})); 
    defparam x27 .WIDTH = 19;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[2], d[3], d[5], d[8], d[9], 
            d[10], d[11], d[13], d[14], d[16], d[17], 
            d[18], d[23], d[24], d[27], d[28], d[30], 
            d[31]})); 
    defparam x28 .WIDTH = 18;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[0], d[3], d[4], d[6], d[9], 
            d[10], d[11], d[12], d[14], d[15], d[17], 
            d[18], d[19], d[24], d[25], d[28], d[29], 
            d[31]})); 
    defparam x29 .WIDTH = 18;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[1], d[4], d[5], d[7], d[10], 
            d[11], d[12], d[13], d[15], d[16], d[18], 
            d[19], d[20], d[25], d[26], d[29], d[30]})); 
    defparam x30 .WIDTH = 17;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[0], d[2], d[5], d[6], d[8], 
            d[11], d[12], d[13], d[14], d[16], d[17], 
            d[19], d[20], d[21], d[26], d[27], d[30], 
            d[31]})); 
    defparam x31 .WIDTH = 18;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 28) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[1], d[2], d[5], d[8], d[9], 
            d[11], d[14], d[18], d[20], d[23], d[26], 
            d[29], d[30]})); 
    defparam x0 .WIDTH = 13;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[0], d[1], d[3], d[5], d[6], 
            d[8], d[10], d[11], d[12], d[14], d[15], 
            d[18], d[19], d[20], d[21], d[23], d[24], 
            d[26], d[27], d[29], d[31]})); 
    defparam x1 .WIDTH = 21;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[0], d[4], d[5], d[6], d[7], 
            d[8], d[12], d[13], d[14], d[15], d[16], 
            d[18], d[19], d[21], d[22], d[23], d[24], 
            d[25], d[26], d[27], d[28], d[29]})); 
    defparam x2 .WIDTH = 22;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[1], d[5], d[6], d[7], d[8], 
            d[9], d[13], d[14], d[15], d[16], d[17], 
            d[19], d[20], d[22], d[23], d[24], d[25], 
            d[26], d[27], d[28], d[29], d[30]})); 
    defparam x3 .WIDTH = 22;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[0], d[1], d[5], d[6], d[7], 
            d[10], d[11], d[15], d[16], d[17], d[21], 
            d[24], d[25], d[27], d[28], d[31]})); 
    defparam x4 .WIDTH = 16;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[5], d[6], d[7], d[9], d[12], 
            d[14], d[16], d[17], d[20], d[22], d[23], 
            d[25], d[28], d[30]})); 
    defparam x5 .WIDTH = 14;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[0], d[6], d[7], d[8], d[10], 
            d[13], d[15], d[17], d[18], d[21], d[23], 
            d[24], d[26], d[29], d[31]})); 
    defparam x6 .WIDTH = 15;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[2], d[5], d[7], d[16], 
            d[19], d[20], d[22], d[23], d[24], d[25], 
            d[26], d[27], d[29]})); 
    defparam x7 .WIDTH = 14;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[2], d[3], d[5], d[6], d[9], 
            d[11], d[14], d[17], d[18], d[21], d[24], 
            d[25], d[27], d[28], d[29]})); 
    defparam x8 .WIDTH = 15;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[3], d[4], d[6], d[7], d[10], 
            d[12], d[15], d[18], d[19], d[22], d[25], 
            d[26], d[28], d[29], d[30]})); 
    defparam x9 .WIDTH = 15;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[1], d[2], d[4], d[7], d[9], 
            d[13], d[14], d[16], d[18], d[19], d[27], 
            d[31]})); 
    defparam x10 .WIDTH = 12;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[1], d[3], d[9], d[10], 
            d[11], d[15], d[17], d[18], d[19], d[23], 
            d[26], d[28], d[29], d[30]})); 
    defparam x11 .WIDTH = 15;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[0], d[4], d[5], d[8], d[9], 
            d[10], d[12], d[14], d[16], d[19], d[23], 
            d[24], d[26], d[27], d[31]})); 
    defparam x12 .WIDTH = 15;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[0], d[1], d[5], d[6], d[9], 
            d[10], d[11], d[13], d[15], d[17], d[20], 
            d[24], d[25], d[27], d[28]})); 
    defparam x13 .WIDTH = 15;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[1], d[2], d[6], d[7], d[10], 
            d[11], d[12], d[14], d[16], d[18], d[21], 
            d[25], d[26], d[28], d[29]})); 
    defparam x14 .WIDTH = 15;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[0], d[2], d[3], d[7], d[8], 
            d[11], d[12], d[13], d[15], d[17], d[19], 
            d[22], d[26], d[27], d[29], d[30]})); 
    defparam x15 .WIDTH = 16;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[2], d[3], d[4], d[5], d[11], 
            d[12], d[13], d[16], d[26], d[27], d[28], 
            d[29], d[31]})); 
    defparam x16 .WIDTH = 13;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[3], d[4], d[5], d[6], d[12], 
            d[13], d[14], d[17], d[27], d[28], d[29], 
            d[30]})); 
    defparam x17 .WIDTH = 12;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[4], d[5], d[6], d[7], 
            d[13], d[14], d[15], d[18], d[28], d[29], 
            d[30], d[31]})); 
    defparam x18 .WIDTH = 13;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[1], d[5], d[6], d[7], d[8], 
            d[14], d[15], d[16], d[19], d[29], d[30], 
            d[31]})); 
    defparam x19 .WIDTH = 12;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[2], d[6], d[7], d[8], 
            d[9], d[15], d[16], d[17], d[20], d[30], 
            d[31]})); 
    defparam x20 .WIDTH = 12;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[1], d[3], d[7], d[8], d[9], 
            d[10], d[16], d[17], d[18], d[21], d[31]})); 
    defparam x21 .WIDTH = 11;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[0], d[1], d[4], d[5], d[10], 
            d[14], d[17], d[19], d[20], d[22], d[23], 
            d[26], d[29], d[30]})); 
    defparam x22 .WIDTH = 14;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[0], d[6], d[8], d[9], d[14], 
            d[15], d[21], d[24], d[26], d[27], d[29], 
            d[31]})); 
    defparam x23 .WIDTH = 12;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[1], d[7], d[9], d[10], d[15], 
            d[16], d[22], d[25], d[27], d[28], d[30]})); 
    defparam x24 .WIDTH = 11;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[0], d[2], d[8], d[10], d[11], 
            d[16], d[17], d[23], d[26], d[28], d[29], 
            d[31]})); 
    defparam x25 .WIDTH = 12;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[2], d[3], d[5], d[8], d[12], 
            d[14], d[17], d[20], d[23], d[24], d[26], 
            d[27]})); 
    defparam x26 .WIDTH = 12;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[0], d[3], d[4], d[6], d[9], 
            d[13], d[15], d[18], d[21], d[24], d[25], 
            d[27], d[28]})); 
    defparam x27 .WIDTH = 13;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[1], d[4], d[5], d[7], d[10], 
            d[14], d[16], d[19], d[22], d[25], d[26], 
            d[28], d[29]})); 
    defparam x28 .WIDTH = 13;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[2], d[5], d[6], d[8], d[11], 
            d[15], d[17], d[20], d[23], d[26], d[27], 
            d[29], d[30]})); 
    defparam x29 .WIDTH = 13;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[3], d[6], d[7], d[9], 
            d[12], d[16], d[18], d[21], d[24], d[27], 
            d[28], d[30], d[31]})); 
    defparam x30 .WIDTH = 14;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[0], d[1], d[4], d[7], d[8], 
            d[10], d[13], d[17], d[19], d[22], d[25], 
            d[28], d[29], d[31]})); 
    defparam x31 .WIDTH = 14;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 29) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[2], d[4], d[5], d[7], d[8], 
            d[11], d[14], d[21], d[23], d[24], d[25], 
            d[28]})); 
    defparam x0 .WIDTH = 12;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[0], d[2], d[3], d[4], d[6], 
            d[7], d[9], d[11], d[12], d[14], d[15], 
            d[21], d[22], d[23], d[26], d[28], d[29]})); 
    defparam x1 .WIDTH = 17;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[1], d[2], d[3], d[10], d[11], 
            d[12], d[13], d[14], d[15], d[16], d[21], 
            d[22], d[25], d[27], d[28], d[29], d[30]})); 
    defparam x2 .WIDTH = 17;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[2], d[3], d[4], d[11], d[12], 
            d[13], d[14], d[15], d[16], d[17], d[22], 
            d[23], d[26], d[28], d[29], d[30], d[31]})); 
    defparam x3 .WIDTH = 17;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[2], d[3], d[7], d[8], d[11], 
            d[12], d[13], d[15], d[16], d[17], d[18], 
            d[21], d[25], d[27], d[28], d[29], d[30], 
            d[31]})); 
    defparam x4 .WIDTH = 18;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[0], d[2], d[3], d[5], d[7], 
            d[9], d[11], d[12], d[13], d[16], d[17], 
            d[18], d[19], d[21], d[22], d[23], d[24], 
            d[25], d[26], d[29], d[30], d[31]})); 
    defparam x5 .WIDTH = 22;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[0], d[1], d[3], d[4], d[6], 
            d[8], d[10], d[12], d[13], d[14], d[17], 
            d[18], d[19], d[20], d[22], d[23], d[24], 
            d[25], d[26], d[27], d[30], d[31]})); 
    defparam x6 .WIDTH = 22;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[1], d[8], d[9], d[13], 
            d[15], d[18], d[19], d[20], d[26], d[27], 
            d[31]})); 
    defparam x7 .WIDTH = 12;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[0], d[1], d[4], d[5], d[7], 
            d[8], d[9], d[10], d[11], d[16], d[19], 
            d[20], d[23], d[24], d[25], d[27]})); 
    defparam x8 .WIDTH = 16;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[1], d[2], d[5], d[6], d[8], 
            d[9], d[10], d[11], d[12], d[17], d[20], 
            d[21], d[24], d[25], d[26], d[28]})); 
    defparam x9 .WIDTH = 16;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[3], d[4], d[5], d[6], 
            d[8], d[9], d[10], d[12], d[13], d[14], 
            d[18], d[22], d[23], d[24], d[26], d[27], 
            d[28], d[29]})); 
    defparam x10 .WIDTH = 19;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[1], d[2], d[6], d[8], 
            d[9], d[10], d[13], d[15], d[19], d[21], 
            d[27], d[29], d[30]})); 
    defparam x11 .WIDTH = 14;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[0], d[1], d[3], d[4], d[5], 
            d[8], d[9], d[10], d[16], d[20], d[21], 
            d[22], d[23], d[24], d[25], d[30], d[31]})); 
    defparam x12 .WIDTH = 17;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[1], d[2], d[4], d[5], d[6], 
            d[9], d[10], d[11], d[17], d[21], d[22], 
            d[23], d[24], d[25], d[26], d[31]})); 
    defparam x13 .WIDTH = 16;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[2], d[3], d[5], d[6], d[7], 
            d[10], d[11], d[12], d[18], d[22], d[23], 
            d[24], d[25], d[26], d[27]})); 
    defparam x14 .WIDTH = 15;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[0], d[3], d[4], d[6], d[7], 
            d[8], d[11], d[12], d[13], d[19], d[23], 
            d[24], d[25], d[26], d[27], d[28]})); 
    defparam x15 .WIDTH = 16;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[0], d[1], d[2], d[9], d[11], 
            d[12], d[13], d[20], d[21], d[23], d[26], 
            d[27], d[29]})); 
    defparam x16 .WIDTH = 13;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[0], d[1], d[2], d[3], d[10], 
            d[12], d[13], d[14], d[21], d[22], d[24], 
            d[27], d[28], d[30]})); 
    defparam x17 .WIDTH = 14;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[1], d[2], d[3], d[4], d[11], 
            d[13], d[14], d[15], d[22], d[23], d[25], 
            d[28], d[29], d[31]})); 
    defparam x18 .WIDTH = 14;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[2], d[3], d[4], d[5], d[12], 
            d[14], d[15], d[16], d[23], d[24], d[26], 
            d[29], d[30]})); 
    defparam x19 .WIDTH = 13;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[3], d[4], d[5], d[6], 
            d[13], d[15], d[16], d[17], d[24], d[25], 
            d[27], d[30], d[31]})); 
    defparam x20 .WIDTH = 14;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[0], d[1], d[4], d[5], d[6], 
            d[7], d[14], d[16], d[17], d[18], d[25], 
            d[26], d[28], d[31]})); 
    defparam x21 .WIDTH = 14;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[0], d[1], d[4], d[6], d[11], 
            d[14], d[15], d[17], d[18], d[19], d[21], 
            d[23], d[24], d[25], d[26], d[27], d[28], 
            d[29]})); 
    defparam x22 .WIDTH = 18;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[1], d[4], d[8], d[11], d[12], 
            d[14], d[15], d[16], d[18], d[19], d[20], 
            d[21], d[22], d[23], d[26], d[27], d[29], 
            d[30]})); 
    defparam x23 .WIDTH = 18;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[2], d[5], d[9], d[12], d[13], 
            d[15], d[16], d[17], d[19], d[20], d[21], 
            d[22], d[23], d[24], d[27], d[28], d[30], 
            d[31]})); 
    defparam x24 .WIDTH = 18;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[0], d[3], d[6], d[10], d[13], 
            d[14], d[16], d[17], d[18], d[20], d[21], 
            d[22], d[23], d[24], d[25], d[28], d[29], 
            d[31]})); 
    defparam x25 .WIDTH = 18;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[1], d[2], d[5], d[8], d[15], 
            d[17], d[18], d[19], d[22], d[26], d[28], 
            d[29], d[30]})); 
    defparam x26 .WIDTH = 13;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[0], d[2], d[3], d[6], d[9], 
            d[16], d[18], d[19], d[20], d[23], d[27], 
            d[29], d[30], d[31]})); 
    defparam x27 .WIDTH = 14;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[0], d[1], d[3], d[4], d[7], 
            d[10], d[17], d[19], d[20], d[21], d[24], 
            d[28], d[30], d[31]})); 
    defparam x28 .WIDTH = 14;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[1], d[2], d[4], d[5], d[8], 
            d[11], d[18], d[20], d[21], d[22], d[25], 
            d[29], d[31]})); 
    defparam x29 .WIDTH = 13;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[2], d[3], d[5], d[6], 
            d[9], d[12], d[19], d[21], d[22], d[23], 
            d[26], d[30]})); 
    defparam x30 .WIDTH = 13;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[1], d[3], d[4], d[6], d[7], 
            d[10], d[13], d[20], d[22], d[23], d[24], 
            d[27], d[31]})); 
    defparam x31 .WIDTH = 13;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 30) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[0], d[3], d[4], d[5], d[6], 
            d[10], d[12], d[15], d[16], d[22]})); 
    defparam x0 .WIDTH = 10;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[1], d[3], d[7], d[10], d[11], 
            d[12], d[13], d[15], d[17], d[22], d[23]})); 
    defparam x1 .WIDTH = 11;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[2], d[3], d[5], d[6], d[8], 
            d[10], d[11], d[13], d[14], d[15], d[18], 
            d[22], d[23], d[24]})); 
    defparam x2 .WIDTH = 14;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[3], d[4], d[6], d[7], d[9], 
            d[11], d[12], d[14], d[15], d[16], d[19], 
            d[23], d[24], d[25]})); 
    defparam x3 .WIDTH = 14;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[0], d[3], d[6], d[7], d[8], 
            d[13], d[17], d[20], d[22], d[24], d[25], 
            d[26]})); 
    defparam x4 .WIDTH = 12;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[0], d[1], d[3], d[5], d[6], 
            d[7], d[8], d[9], d[10], d[12], d[14], 
            d[15], d[16], d[18], d[21], d[22], d[23], 
            d[25], d[26], d[27]})); 
    defparam x5 .WIDTH = 20;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[0], d[1], d[2], d[4], d[6], 
            d[7], d[8], d[9], d[10], d[11], d[13], 
            d[15], d[16], d[17], d[19], d[22], d[23], 
            d[24], d[26], d[27], d[28]})); 
    defparam x6 .WIDTH = 21;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[1], d[2], d[4], d[6], 
            d[7], d[8], d[9], d[11], d[14], d[15], 
            d[17], d[18], d[20], d[22], d[23], d[24], 
            d[25], d[27], d[28], d[29]})); 
    defparam x7 .WIDTH = 21;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[0], d[1], d[2], d[4], d[6], 
            d[7], d[8], d[9], d[18], d[19], d[21], 
            d[22], d[23], d[24], d[25], d[26], d[28], 
            d[29], d[30]})); 
    defparam x8 .WIDTH = 19;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[0], d[1], d[2], d[3], d[5], 
            d[7], d[8], d[9], d[10], d[19], d[20], 
            d[22], d[23], d[24], d[25], d[26], d[27], 
            d[29], d[30], d[31]})); 
    defparam x9 .WIDTH = 20;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[1], d[2], d[5], d[8], d[9], 
            d[11], d[12], d[15], d[16], d[20], d[21], 
            d[22], d[23], d[24], d[25], d[26], d[27], 
            d[28], d[30], d[31]})); 
    defparam x10 .WIDTH = 20;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[0], d[2], d[4], d[5], d[9], 
            d[13], d[15], d[17], d[21], d[23], d[24], 
            d[25], d[26], d[27], d[28], d[29], d[31]})); 
    defparam x11 .WIDTH = 17;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[1], d[4], d[12], d[14], d[15], 
            d[18], d[24], d[25], d[26], d[27], d[28], 
            d[29], d[30]})); 
    defparam x12 .WIDTH = 13;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[2], d[5], d[13], d[15], d[16], 
            d[19], d[25], d[26], d[27], d[28], d[29], 
            d[30], d[31]})); 
    defparam x13 .WIDTH = 13;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[0], d[3], d[6], d[14], d[16], 
            d[17], d[20], d[26], d[27], d[28], d[29], 
            d[30], d[31]})); 
    defparam x14 .WIDTH = 13;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[1], d[4], d[7], d[15], d[17], 
            d[18], d[21], d[27], d[28], d[29], d[30], 
            d[31]})); 
    defparam x15 .WIDTH = 12;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[0], d[2], d[3], d[4], d[6], 
            d[8], d[10], d[12], d[15], d[18], d[19], 
            d[28], d[29], d[30], d[31]})); 
    defparam x16 .WIDTH = 15;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[0], d[1], d[3], d[4], d[5], 
            d[7], d[9], d[11], d[13], d[16], d[19], 
            d[20], d[29], d[30], d[31]})); 
    defparam x17 .WIDTH = 15;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[1], d[2], d[4], d[5], d[6], 
            d[8], d[10], d[12], d[14], d[17], d[20], 
            d[21], d[30], d[31]})); 
    defparam x18 .WIDTH = 14;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[2], d[3], d[5], d[6], d[7], 
            d[9], d[11], d[13], d[15], d[18], d[21], 
            d[22], d[31]})); 
    defparam x19 .WIDTH = 13;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[3], d[4], d[6], d[7], 
            d[8], d[10], d[12], d[14], d[16], d[19], 
            d[22], d[23]})); 
    defparam x20 .WIDTH = 13;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[0], d[1], d[4], d[5], d[7], 
            d[8], d[9], d[11], d[13], d[15], d[17], 
            d[20], d[23], d[24]})); 
    defparam x21 .WIDTH = 14;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[1], d[2], d[3], d[4], d[8], 
            d[9], d[14], d[15], d[18], d[21], d[22], 
            d[24], d[25]})); 
    defparam x22 .WIDTH = 13;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[0], d[2], d[6], d[9], d[12], 
            d[19], d[23], d[25], d[26]})); 
    defparam x23 .WIDTH = 9;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[1], d[3], d[7], d[10], d[13], 
            d[20], d[24], d[26], d[27]})); 
    defparam x24 .WIDTH = 9;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[2], d[4], d[8], d[11], d[14], 
            d[21], d[25], d[27], d[28]})); 
    defparam x25 .WIDTH = 9;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[0], d[4], d[6], d[9], d[10], 
            d[16], d[26], d[28], d[29]})); 
    defparam x26 .WIDTH = 9;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[0], d[1], d[5], d[7], d[10], 
            d[11], d[17], d[27], d[29], d[30]})); 
    defparam x27 .WIDTH = 10;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[0], d[1], d[2], d[6], d[8], 
            d[11], d[12], d[18], d[28], d[30], d[31]})); 
    defparam x28 .WIDTH = 11;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[0], d[1], d[2], d[3], d[7], 
            d[9], d[12], d[13], d[19], d[29], d[31]})); 
    defparam x29 .WIDTH = 11;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[1], d[2], d[3], d[4], d[8], 
            d[10], d[13], d[14], d[20], d[30]})); 
    defparam x30 .WIDTH = 10;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[2], d[3], d[4], d[5], d[9], 
            d[11], d[14], d[15], d[21], d[31]})); 
    defparam x31 .WIDTH = 10;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 31) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[2], d[3], d[4], d[5], d[8], 
            d[9], d[17], d[18], d[21], d[25], d[26], 
            d[31]})); 
    defparam x0 .WIDTH = 12;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[2], d[6], d[8], d[10], d[17], 
            d[19], d[21], d[22], d[25], d[27], d[31]})); 
    defparam x1 .WIDTH = 11;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[2], d[4], d[5], d[7], d[8], 
            d[11], d[17], d[20], d[21], d[22], d[23], 
            d[25], d[28], d[31]})); 
    defparam x2 .WIDTH = 14;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[0], d[3], d[5], d[6], d[8], 
            d[9], d[12], d[18], d[21], d[22], d[23], 
            d[24], d[26], d[29]})); 
    defparam x3 .WIDTH = 14;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[1], d[2], d[3], d[5], d[6], 
            d[7], d[8], d[10], d[13], d[17], d[18], 
            d[19], d[21], d[22], d[23], d[24], d[26], 
            d[27], d[30], d[31]})); 
    defparam x4 .WIDTH = 20;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[5], d[6], d[7], d[11], d[14], 
            d[17], d[19], d[20], d[21], d[22], d[23], 
            d[24], d[26], d[27], d[28]})); 
    defparam x5 .WIDTH = 15;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[0], d[6], d[7], d[8], d[12], 
            d[15], d[18], d[20], d[21], d[22], d[23], 
            d[24], d[25], d[27], d[28], d[29]})); 
    defparam x6 .WIDTH = 16;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[5], d[7], d[13], d[16], d[17], d[18], 
            d[19], d[22], d[23], d[24], d[28], d[29], 
            d[30], d[31]})); 
    defparam x7 .WIDTH = 19;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[0], d[1], d[6], d[9], d[14], 
            d[19], d[20], d[21], d[23], d[24], d[26], 
            d[29], d[30]})); 
    defparam x8 .WIDTH = 13;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[0], d[1], d[2], d[7], d[10], 
            d[15], d[20], d[21], d[22], d[24], d[25], 
            d[27], d[30], d[31]})); 
    defparam x9 .WIDTH = 14;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[0], d[1], d[4], d[5], d[9], 
            d[11], d[16], d[17], d[18], d[22], d[23], 
            d[28]})); 
    defparam x10 .WIDTH = 12;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[1], d[3], d[4], d[6], d[8], 
            d[9], d[10], d[12], d[19], d[21], d[23], 
            d[24], d[25], d[26], d[29], d[31]})); 
    defparam x11 .WIDTH = 16;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[0], d[3], d[7], d[8], d[10], 
            d[11], d[13], d[17], d[18], d[20], d[21], 
            d[22], d[24], d[27], d[30], d[31]})); 
    defparam x12 .WIDTH = 16;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[1], d[4], d[8], d[9], d[11], 
            d[12], d[14], d[18], d[19], d[21], d[22], 
            d[23], d[25], d[28], d[31]})); 
    defparam x13 .WIDTH = 15;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[2], d[5], d[9], d[10], d[12], 
            d[13], d[15], d[19], d[20], d[22], d[23], 
            d[24], d[26], d[29]})); 
    defparam x14 .WIDTH = 14;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[3], d[6], d[10], d[11], d[13], 
            d[14], d[16], d[20], d[21], d[23], d[24], 
            d[25], d[27], d[30]})); 
    defparam x15 .WIDTH = 14;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[2], d[3], d[5], d[7], d[8], 
            d[9], d[11], d[12], d[14], d[15], d[18], 
            d[22], d[24], d[28]})); 
    defparam x16 .WIDTH = 14;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[3], d[4], d[6], d[8], d[9], 
            d[10], d[12], d[13], d[15], d[16], d[19], 
            d[23], d[25], d[29]})); 
    defparam x17 .WIDTH = 14;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[4], d[5], d[7], d[9], 
            d[10], d[11], d[13], d[14], d[16], d[17], 
            d[20], d[24], d[26], d[30]})); 
    defparam x18 .WIDTH = 15;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[1], d[5], d[6], d[8], d[10], 
            d[11], d[12], d[14], d[15], d[17], d[18], 
            d[21], d[25], d[27], d[31]})); 
    defparam x19 .WIDTH = 15;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[2], d[6], d[7], d[9], d[11], 
            d[12], d[13], d[15], d[16], d[18], d[19], 
            d[22], d[26], d[28]})); 
    defparam x20 .WIDTH = 14;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[3], d[7], d[8], d[10], d[12], 
            d[13], d[14], d[16], d[17], d[19], d[20], 
            d[23], d[27], d[29]})); 
    defparam x21 .WIDTH = 14;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[0], d[2], d[3], d[5], d[11], 
            d[13], d[14], d[15], d[20], d[24], d[25], 
            d[26], d[28], d[30], d[31]})); 
    defparam x22 .WIDTH = 15;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[1], d[2], d[5], d[6], d[8], 
            d[9], d[12], d[14], d[15], d[16], d[17], 
            d[18], d[27], d[29]})); 
    defparam x23 .WIDTH = 14;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[2], d[3], d[6], d[7], d[9], 
            d[10], d[13], d[15], d[16], d[17], d[18], 
            d[19], d[28], d[30]})); 
    defparam x24 .WIDTH = 14;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[3], d[4], d[7], d[8], d[10], 
            d[11], d[14], d[16], d[17], d[18], d[19], 
            d[20], d[29], d[31]})); 
    defparam x25 .WIDTH = 14;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[2], d[3], d[11], d[12], d[15], 
            d[19], d[20], d[25], d[26], d[30], d[31]})); 
    defparam x26 .WIDTH = 11;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[0], d[3], d[4], d[12], d[13], 
            d[16], d[20], d[21], d[26], d[27], d[31]})); 
    defparam x27 .WIDTH = 11;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[0], d[1], d[4], d[5], d[13], 
            d[14], d[17], d[21], d[22], d[27], d[28]})); 
    defparam x28 .WIDTH = 11;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[0], d[1], d[2], d[5], d[6], 
            d[14], d[15], d[18], d[22], d[23], d[28], 
            d[29]})); 
    defparam x29 .WIDTH = 12;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[0], d[1], d[2], d[3], d[6], 
            d[7], d[15], d[16], d[19], d[23], d[24], 
            d[29], d[30]})); 
    defparam x30 .WIDTH = 13;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[1], d[2], d[3], d[4], d[7], 
            d[8], d[16], d[17], d[20], d[24], d[25], 
            d[30], d[31]})); 
    defparam x31 .WIDTH = 13;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end


/////////////////////////////////////////////////////////////////

if (NUM_EVOS == 32) begin
    xor_2tick_b x0 (.clk(clk), .blank(blank), .dout(c[0]), .din({
        d[0], d[1], d[5], d[7], d[9], 
            d[11], d[12], d[15], d[16], d[17], d[20], 
            d[21], d[22], d[24], d[25], d[26], d[28], 
            d[29], d[31]})); 
    defparam x0 .WIDTH = 19;
    defparam x0 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x0 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x1 (.clk(clk), .blank(blank), .dout(c[1]), .din({
        d[0], d[2], d[5], d[6], d[7], 
            d[8], d[9], d[10], d[11], d[13], d[15], 
            d[18], d[20], d[23], d[24], d[27], d[28], 
            d[30], d[31]})); 
    defparam x1 .WIDTH = 19;
    defparam x1 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x1 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x2 (.clk(clk), .blank(blank), .dout(c[2]), .din({
        d[0], d[3], d[5], d[6], d[8], 
            d[10], d[14], d[15], d[17], d[19], d[20], 
            d[22], d[26]})); 
    defparam x2 .WIDTH = 13;
    defparam x2 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x2 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x3 (.clk(clk), .blank(blank), .dout(c[3]), .din({
        d[1], d[4], d[6], d[7], d[9], 
            d[11], d[15], d[16], d[18], d[20], d[21], 
            d[23], d[27]})); 
    defparam x3 .WIDTH = 13;
    defparam x3 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x3 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x4 (.clk(clk), .blank(blank), .dout(c[4]), .din({
        d[0], d[1], d[2], d[8], d[9], 
            d[10], d[11], d[15], d[19], d[20], d[25], 
            d[26], d[29], d[31]})); 
    defparam x4 .WIDTH = 14;
    defparam x4 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x4 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x5 (.clk(clk), .blank(blank), .dout(c[5]), .din({
        d[0], d[2], d[3], d[5], d[7], 
            d[10], d[15], d[17], d[22], d[24], d[25], 
            d[27], d[28], d[29], d[30], d[31]})); 
    defparam x5 .WIDTH = 16;
    defparam x5 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x5 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x6 (.clk(clk), .blank(blank), .dout(c[6]), .din({
        d[1], d[3], d[4], d[6], d[8], 
            d[11], d[16], d[18], d[23], d[25], d[26], 
            d[28], d[29], d[30], d[31]})); 
    defparam x6 .WIDTH = 15;
    defparam x6 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x6 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x7 (.clk(clk), .blank(blank), .dout(c[7]), .din({
        d[1], d[2], d[4], d[11], d[15], 
            d[16], d[19], d[20], d[21], d[22], d[25], 
            d[27], d[28], d[30]})); 
    defparam x7 .WIDTH = 14;
    defparam x7 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x7 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x8 (.clk(clk), .blank(blank), .dout(c[8]), .din({
        d[1], d[2], d[3], d[7], d[9], 
            d[11], d[15], d[23], d[24], d[25]})); 
    defparam x8 .WIDTH = 10;
    defparam x8 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x8 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x9 (.clk(clk), .blank(blank), .dout(c[9]), .din({
        d[0], d[2], d[3], d[4], d[8], 
            d[10], d[12], d[16], d[24], d[25], d[26]})); 
    defparam x9 .WIDTH = 11;
    defparam x9 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x9 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x10 (.clk(clk), .blank(blank), .dout(c[10]), .din({
        d[3], d[4], d[7], d[12], d[13], 
            d[15], d[16], d[20], d[21], d[22], d[24], 
            d[27], d[28], d[29], d[31]})); 
    defparam x10 .WIDTH = 15;
    defparam x10 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x10 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x11 (.clk(clk), .blank(blank), .dout(c[11]), .din({
        d[1], d[4], d[7], d[8], d[9], 
            d[11], d[12], d[13], d[14], d[15], d[20], 
            d[23], d[24], d[26], d[30], d[31]})); 
    defparam x11 .WIDTH = 16;
    defparam x11 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x11 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x12 (.clk(clk), .blank(blank), .dout(c[12]), .din({
        d[1], d[2], d[7], d[8], d[10], 
            d[11], d[13], d[14], d[17], d[20], d[22], 
            d[26], d[27], d[28], d[29]})); 
    defparam x12 .WIDTH = 15;
    defparam x12 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x12 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x13 (.clk(clk), .blank(blank), .dout(c[13]), .din({
        d[0], d[2], d[3], d[8], d[9], 
            d[11], d[12], d[14], d[15], d[18], d[21], 
            d[23], d[27], d[28], d[29], d[30]})); 
    defparam x13 .WIDTH = 16;
    defparam x13 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x13 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x14 (.clk(clk), .blank(blank), .dout(c[14]), .din({
        d[1], d[3], d[4], d[9], d[10], 
            d[12], d[13], d[15], d[16], d[19], d[22], 
            d[24], d[28], d[29], d[30], d[31]})); 
    defparam x14 .WIDTH = 16;
    defparam x14 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x14 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x15 (.clk(clk), .blank(blank), .dout(c[15]), .din({
        d[2], d[4], d[5], d[10], d[11], 
            d[13], d[14], d[16], d[17], d[20], d[23], 
            d[25], d[29], d[30], d[31]})); 
    defparam x15 .WIDTH = 15;
    defparam x15 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x15 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x16 (.clk(clk), .blank(blank), .dout(c[16]), .din({
        d[1], d[3], d[6], d[7], d[9], 
            d[14], d[16], d[18], d[20], d[22], d[25], 
            d[28], d[29], d[30]})); 
    defparam x16 .WIDTH = 14;
    defparam x16 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x16 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x17 (.clk(clk), .blank(blank), .dout(c[17]), .din({
        d[0], d[2], d[4], d[7], d[8], 
            d[10], d[15], d[17], d[19], d[21], d[23], 
            d[26], d[29], d[30], d[31]})); 
    defparam x17 .WIDTH = 15;
    defparam x17 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x17 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x18 (.clk(clk), .blank(blank), .dout(c[18]), .din({
        d[0], d[1], d[3], d[5], d[8], 
            d[9], d[11], d[16], d[18], d[20], d[22], 
            d[24], d[27], d[30], d[31]})); 
    defparam x18 .WIDTH = 15;
    defparam x18 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x18 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x19 (.clk(clk), .blank(blank), .dout(c[19]), .din({
        d[0], d[1], d[2], d[4], d[6], 
            d[9], d[10], d[12], d[17], d[19], d[21], 
            d[23], d[25], d[28], d[31]})); 
    defparam x19 .WIDTH = 15;
    defparam x19 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x19 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x20 (.clk(clk), .blank(blank), .dout(c[20]), .din({
        d[0], d[1], d[2], d[3], d[5], 
            d[7], d[10], d[11], d[13], d[18], d[20], 
            d[22], d[24], d[26], d[29]})); 
    defparam x20 .WIDTH = 15;
    defparam x20 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x20 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x21 (.clk(clk), .blank(blank), .dout(c[21]), .din({
        d[0], d[1], d[2], d[3], d[4], 
            d[6], d[8], d[11], d[12], d[14], d[19], 
            d[21], d[23], d[25], d[27], d[30]})); 
    defparam x21 .WIDTH = 16;
    defparam x21 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x21 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x22 (.clk(clk), .blank(blank), .dout(c[22]), .din({
        d[0], d[2], d[3], d[4], d[11], 
            d[13], d[16], d[17], d[21], d[25], d[29]})); 
    defparam x22 .WIDTH = 11;
    defparam x22 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x22 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x23 (.clk(clk), .blank(blank), .dout(c[23]), .din({
        d[0], d[3], d[4], d[7], d[9], 
            d[11], d[14], d[15], d[16], d[18], d[20], 
            d[21], d[24], d[25], d[28], d[29], d[30], 
            d[31]})); 
    defparam x23 .WIDTH = 18;
    defparam x23 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x23 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x24 (.clk(clk), .blank(blank), .dout(c[24]), .din({
        d[1], d[4], d[5], d[8], d[10], 
            d[12], d[15], d[16], d[17], d[19], d[21], 
            d[22], d[25], d[26], d[29], d[30], d[31]})); 
    defparam x24 .WIDTH = 17;
    defparam x24 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x24 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x25 (.clk(clk), .blank(blank), .dout(c[25]), .din({
        d[2], d[5], d[6], d[9], d[11], 
            d[13], d[16], d[17], d[18], d[20], d[22], 
            d[23], d[26], d[27], d[30], d[31]})); 
    defparam x25 .WIDTH = 16;
    defparam x25 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x25 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x26 (.clk(clk), .blank(blank), .dout(c[26]), .din({
        d[1], d[3], d[5], d[6], d[9], 
            d[10], d[11], d[14], d[15], d[16], d[18], 
            d[19], d[20], d[22], d[23], d[25], d[26], 
            d[27], d[29]})); 
    defparam x26 .WIDTH = 19;
    defparam x26 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x26 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x27 (.clk(clk), .blank(blank), .dout(c[27]), .din({
        d[0], d[2], d[4], d[6], d[7], 
            d[10], d[11], d[12], d[15], d[16], d[17], 
            d[19], d[20], d[21], d[23], d[24], d[26], 
            d[27], d[28], d[30]})); 
    defparam x27 .WIDTH = 20;
    defparam x27 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x27 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x28 (.clk(clk), .blank(blank), .dout(c[28]), .din({
        d[1], d[3], d[5], d[7], d[8], 
            d[11], d[12], d[13], d[16], d[17], d[18], 
            d[20], d[21], d[22], d[24], d[25], d[27], 
            d[28], d[29], d[31]})); 
    defparam x28 .WIDTH = 20;
    defparam x28 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x28 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x29 (.clk(clk), .blank(blank), .dout(c[29]), .din({
        d[2], d[4], d[6], d[8], d[9], 
            d[12], d[13], d[14], d[17], d[18], d[19], 
            d[21], d[22], d[23], d[25], d[26], d[28], 
            d[29], d[30]})); 
    defparam x29 .WIDTH = 19;
    defparam x29 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x29 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x30 (.clk(clk), .blank(blank), .dout(c[30]), .din({
        d[3], d[5], d[7], d[9], d[10], 
            d[13], d[14], d[15], d[18], d[19], d[20], 
            d[22], d[23], d[24], d[26], d[27], d[29], 
            d[30], d[31]})); 
    defparam x30 .WIDTH = 19;
    defparam x30 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x30 .TARGET_CHIP = TARGET_CHIP;

    xor_2tick_b x31 (.clk(clk), .blank(blank), .dout(c[31]), .din({
        d[0], d[4], d[6], d[8], d[10], 
            d[11], d[14], d[15], d[16], d[19], d[20], 
            d[21], d[23], d[24], d[25], d[27], d[28], 
            d[30], d[31]})); 
    defparam x31 .WIDTH = 19;
    defparam x31 .REDUCE_LATENCY = REDUCE_LATENCY;
    defparam x31 .TARGET_CHIP = TARGET_CHIP;

end

endgenerate
endmodule


// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 154
// BENCHMARK INFO :  Total pins : 66
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 155             ;       ;
// BENCHMARK INFO :  ALMs : 86 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.405 ns, From xor_2tick_b:x1|xor_r:lp[0].xr|dout_r, To xor_2tick_b:x1|xor_r_b:xh|dout_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.333 ns, From xor_2tick_b:x6|xor_r:lp[0].xr|dout_r, To xor_2tick_b:x6|xor_r_b:xh|dout_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.489 ns, From xor_2tick_b:x20|xor_r:lp[1].xr|dout_r, To xor_2tick_b:x20|xor_r_b:xh|dout_r}
