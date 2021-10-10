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
// baeckler - 08-27-2012
// throw away the 2 framing bits, then 2 more off the right hand side,
// connect to 5 of the next 12 using this pattern : 46c
// generates vlane number, or 1f for no match

module vlane_id #(
	parameter TARGET_CHIP = 2
)(
	input clk,
	input [4:0] din,
	output [4:0] vlane
);

//usable mask 46c (5)
//11101101111111110110110100001101
//11001101100111010111101110101111
//01001110101011111111100100101101
//11001110100011110111010111001101
//01011100110101010110000100001111

wire [4:0] vlane_num;

wys_lut w0 (.a(din[0]),.b(din[1]),.c(din[2]),.d(din[3]),.e(din[4]),.f(1'b0),.out(vlane_num[0]));
defparam w0 .MASK = {32'h0,32'b11101101111111110110110100001101};
defparam w0 .TARGET_CHIP = TARGET_CHIP;

wys_lut w1 (.a(din[0]),.b(din[1]),.c(din[2]),.d(din[3]),.e(din[4]),.f(1'b0),.out(vlane_num[1]));
defparam w1 .MASK = {32'h0,32'b11001101100111010111101110101111};
defparam w1 .TARGET_CHIP = TARGET_CHIP;

wys_lut w2 (.a(din[0]),.b(din[1]),.c(din[2]),.d(din[3]),.e(din[4]),.f(1'b0),.out(vlane_num[2]));
defparam w2 .MASK = {32'h0,32'b01001110101011111111100100101101};
defparam w2 .TARGET_CHIP = TARGET_CHIP;

wys_lut w3 (.a(din[0]),.b(din[1]),.c(din[2]),.d(din[3]),.e(din[4]),.f(1'b0),.out(vlane_num[3]));
defparam w3 .MASK = {32'h0,32'b11001110100011110111010111001101};
defparam w3 .TARGET_CHIP = TARGET_CHIP;

wys_lut w4 (.a(din[0]),.b(din[1]),.c(din[2]),.d(din[3]),.e(din[4]),.f(1'b0),.out(vlane_num[4]));
defparam w4 .MASK = {32'h0,32'b01011100110101010110000100001111};
defparam w4 .TARGET_CHIP = TARGET_CHIP;

reg [4:0] vlane_r = 0;
always @(posedge clk) vlane_r <= vlane_num;
assign vlane = vlane_r;

endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 5
// BENCHMARK INFO :  Total pins : 11
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 6               ;       ;
// BENCHMARK INFO :  ALMs : 4 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From clk~inputCLKENA0FMAX_CAP_FF0, To clk~inputCLKENA0FMAX_CAP_FF1}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From clk~inputCLKENA0FMAX_CAP_FF0, To clk~inputCLKENA0FMAX_CAP_FF1}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From clk~inputCLKENA0FMAX_CAP_FF0, To clk~inputCLKENA0FMAX_CAP_FF1}
