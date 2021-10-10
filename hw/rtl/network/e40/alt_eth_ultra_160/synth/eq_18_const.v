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
////////////////////////////////////////////////////////////////////////////

// baeckler - 08-26-2012
// latency 2

`timescale 1 ps / 1 ps

module eq_18_const #(
	parameter TARGET_CHIP = 2,
	parameter VAL = 18'h1fe
)(
	input clk,
	input [17:0] din,
	output match
);

wire match0, match1, match2;

wys_lut w0 (
	.a(din[0]),
	.b(din[1]),
	.c(din[2]),
	.d(din[3]),
	.e(din[4]),
	.f(din[5]),
	.out (match0)
);
defparam w0 .TARGET_CHIP = TARGET_CHIP;
defparam w0 .MASK = 64'h0 | (64'b1 << VAL[5:0]);

wys_lut w1 (
	.a(din[6]),
	.b(din[7]),
	.c(din[8]),
	.d(din[9]),
	.e(din[10]),
	.f(din[11]),
	.out (match1)
);
defparam w1 .TARGET_CHIP = TARGET_CHIP;
defparam w1 .MASK = 64'h0 | (64'b1 << VAL[11:6]);

wys_lut w2 (
	.a(din[12]),
	.b(din[13]),
	.c(din[14]),
	.d(din[15]),
	.e(din[16]),
	.f(din[17]),
	.out (match2)
);
defparam w2 .TARGET_CHIP = TARGET_CHIP;
defparam w2 .MASK = 64'h0 | (64'b1 << VAL[17:12]);

reg match0_r = 1'b0;
reg match1_r = 1'b0;
reg match2_r = 1'b0;
reg match_r = 1'b0;
always @(posedge clk) begin
	match0_r <= match0;
	match1_r <= match1;
	match2_r <= match2;
	match_r <= match0_r & match1_r & match2_r;
end
assign match = match_r;

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 4
// BENCHMARK INFO :  Total pins : 20
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 5               ;       ;
// BENCHMARK INFO :  ALMs : 4 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.645 ns, From match2_r, To match_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.648 ns, From match2_r, To match_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.661 ns, From match1_r, To match_r}
