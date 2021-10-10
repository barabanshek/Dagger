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

// 01-15-2012
// compare two 18 bit values - 2 ticks

module eq_18 #(
	parameter TARGET_CHIP = 2
)(
	input clk,
	input [17:0] din_a,
	input [17:0] din_b,
	output reg match
);

reg [5:0] cmp3 = 6'b0;

genvar i;
generate 
for (i=0; i<6; i=i+1) begin :lp
	wire eq_w;
	eq_3 eq (
		.da(din_a[(i+1)*3-1:i*3]),
		.db(din_b[(i+1)*3-1:i*3]),
		.eq(eq_w)
	);
	defparam eq .TARGET_CHIP = TARGET_CHIP;
	
	always @(posedge clk) begin
		cmp3[i] <= eq_w;
	end
end
endgenerate

initial match = 1'b0;
always @(posedge clk) begin
	match <= &cmp3;
end

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 7
// BENCHMARK INFO :  Total pins : 38
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 8               ;       ;
// BENCHMARK INFO :  ALMs : 8 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.612 ns, From cmp3[1], To match~reg0}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.626 ns, From cmp3[0], To match~reg0}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.627 ns, From cmp3[2], To match~reg0}
