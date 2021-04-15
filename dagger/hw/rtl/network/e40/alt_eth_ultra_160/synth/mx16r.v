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

// baeckler - 01-14-2012
// five registered 4:1 MUX stacked to build 16:1

module mx16r #(
	parameter WIDTH = 16
)(
	input clk,
	input [16*WIDTH-1:0] din,
	input [3:0] sel,
	output [WIDTH-1:0] dout
);

wire [4*WIDTH-1:0] mid_dout;

genvar i;
generate
for (i=0; i<4; i=i+1) begin : lp
	mx4r m (
		.clk(clk),
		.din(din[(i+1)*4*WIDTH-1:i*4*WIDTH]),
		.sel(sel[1:0]),
		.dout(mid_dout[(i+1)*WIDTH-1:i*WIDTH])
	);
	defparam m .WIDTH = WIDTH;
end
endgenerate

reg [1:0] mid_sel = 2'b0 /* synthesis preserve */;
always @(posedge clk) mid_sel <= sel[3:2];

mx4r mh (
	.clk(clk),
	.din(mid_dout),
	.sel(mid_sel),
	.dout(dout)
);
defparam mh .WIDTH = WIDTH;

endmodule
// BENCHMARK INFO :  10AX115R3F40I2SGES
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 82
// BENCHMARK INFO :  Total pins : 277
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                           ; 81             ;       ;
// BENCHMARK INFO :  ALMs : 80 / 427,200 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.309 ns, From mid_sel[1], To mx4r:m|dout_r[12]}
