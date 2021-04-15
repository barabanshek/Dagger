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

// baeckler - 03-12-2012
// 8:1 built from 4:1 and 2:1,  probably faster on average than the bridged 7 LUT variant

module mx8r #(
	parameter WIDTH = 16
)(
	input clk,
	input [8*WIDTH-1:0] din,
	input [2:0] sel,
	output [WIDTH-1:0] dout
);

wire [2*WIDTH-1:0] mid_dout;

genvar i;
generate
for (i=0; i<2; i=i+1) begin : lp
	mx4r m (
		.clk(clk),
		.din(din[(i+1)*4*WIDTH-1:i*4*WIDTH]),
		.sel(sel[1:0]),
		.dout(mid_dout[(i+1)*WIDTH-1:i*WIDTH])
	);
	defparam m .WIDTH = WIDTH;
end
endgenerate

reg mid_sel = 1'b0 /* synthesis preserve */;
always @(posedge clk) mid_sel <= sel[2];

// final 2:1
reg [WIDTH-1:0] dout_r = {WIDTH{1'b0}} /* synthesis preserve */;
wire [WIDTH-1:0] mid_dout_hi, mid_dout_lo;
assign {mid_dout_hi, mid_dout_lo} = mid_dout;
always @(posedge clk) begin
	dout_r <= mid_sel ? mid_dout_hi : mid_dout_lo;
end
assign dout = dout_r;

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 49
// BENCHMARK INFO :  Total pins : 148
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 33              ;       ;
// BENCHMARK INFO :  ALMs : 44 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.474 ns, From mx4r:lp[1].m|dout_r[5], To dout_r[5]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.502 ns, From mx4r:lp[0].m|dout_r[0], To dout_r[0]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.465 ns, From mid_sel, To dout_r[5]}
