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
// baeckler - 06-07-2012
// latency 3

module opposite_36 #(
	parameter TARGET_CHIP = 2
)(
	input clk,
	input [35:0] din_a,
	input [35:0] din_b,
	output opp
);

wire [17:0] din_a_hi, din_b_hi, din_a_lo, din_b_lo;
assign {din_a_hi,din_a_lo} = din_a;
assign {din_b_hi,din_b_lo} = din_b;
wire opp_hi, opp_lo;

opposite_18 o1 (
	.clk(clk),
	.din_a(din_a_hi),
	.din_b(din_b_hi),
	.opp(opp_hi)
);
defparam o1 .TARGET_CHIP = TARGET_CHIP;

opposite_18 o0 (
	.clk(clk),
	.din_a(din_a_lo),
	.din_b(din_b_lo),
	.opp(opp_lo)
);
defparam o0 .TARGET_CHIP = TARGET_CHIP;

reg opp_r = 1'b0 /* synthesis preserve */;
always @(posedge clk) opp_r <= opp_hi & opp_lo;
assign opp = opp_r;
	
endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 15
// BENCHMARK INFO :  Total pins : 74
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 16              ;       ;
// BENCHMARK INFO :  ALMs : 16 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.554 ns, From opposite_18:o0|mid_opp_r[1], To opposite_18:o0|opp_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.510 ns, From opposite_18:o0|mid_opp_r[1], To opposite_18:o0|opp_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.553 ns, From opposite_18:o1|mid_opp_r[3], To opposite_18:o1|opp_r}
