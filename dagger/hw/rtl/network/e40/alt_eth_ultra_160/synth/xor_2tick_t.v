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
// baeckler - 08-11-2012

module xor_2tick_t #(
	parameter TARGET_CHIP = 2,
	parameter WIDTH = 8,
	parameter LEAF_SIZE = ((WIDTH > 20) ? 6 :
						(WIDTH > 16) ? 5 :	4),
	parameter REDUCE_LATENCY = 1'b0  // eliminate the middle register layer
						
)(
	input clk,
	input thru,			// latency 1
	input thru_d,		// latency 1
	input [WIDTH-1:0] din, // latency 2
	output dout
);

localparam NUM_LEAVES = (((WIDTH / LEAF_SIZE) * LEAF_SIZE) < WIDTH) ?
			(WIDTH / LEAF_SIZE) + 1 :
			(WIDTH / LEAF_SIZE);

localparam PADDED_LEN = NUM_LEAVES * LEAF_SIZE;

wire [PADDED_LEN-1:0] padded = {PADDED_LEN{1'b0}} | din;
wire [NUM_LEAVES-1:0] leaf;

genvar i;
generate
	for (i=0; i<NUM_LEAVES; i=i+1) begin : lp
		if (REDUCE_LATENCY) begin
			xor_lut xr (
				.din(padded[(i+1)*LEAF_SIZE-1:i*LEAF_SIZE]),
				.dout(leaf[i])
			);
			defparam xr .WIDTH = LEAF_SIZE;
			defparam xr .TARGET_CHIP = TARGET_CHIP;
		end
		else begin
			xor_r xr (
				.clk(clk),
				.din(padded[(i+1)*LEAF_SIZE-1:i*LEAF_SIZE]),
				.dout(leaf[i])
			);
			defparam xr .WIDTH = LEAF_SIZE;
			defparam xr .TARGET_CHIP = TARGET_CHIP;
		end
	end
endgenerate

xor_r_t xh (
	.clk(clk),
	.thru(thru),
	.thru_d(thru_d),	
	.din(leaf),
	.dout(dout)
);
defparam xh .WIDTH = NUM_LEAVES;
defparam xh .TARGET_CHIP = TARGET_CHIP;

endmodule


// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 3
// BENCHMARK INFO :  Total pins : 12
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 4               ;       ;
// BENCHMARK INFO :  ALMs : 2 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.684 ns, From xor_r:lp[1].xr|dout_r, To xor_r_t:xh|dout_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.684 ns, From xor_r:lp[1].xr|dout_r, To xor_r_t:xh|dout_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.687 ns, From xor_r:lp[1].xr|dout_r, To xor_r_t:xh|dout_r}
