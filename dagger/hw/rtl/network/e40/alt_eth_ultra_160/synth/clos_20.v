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


// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/hsl18/clos_20.v#1 $
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
// baeckler - 08-26-2012

module clos_20 #(
	parameter WIDTH = 16
)(
	input clk,
	input [4*2*5+5*3*4+4*2*5-1:0] sels,
	input [20*WIDTH-1:0] din,
	output [20*WIDTH-1:0] dout	
);

wire [WIDTH*20-1:0] x0,x0p,x1,x1p;
wire [4*2*5-1:0] sel0,sel2;
wire [5*3*4-1:0] sel1;
assign {sel2,sel1,sel0} = sels;

//////////////////////////////
// 4x4 layer - five copies

genvar i;
generate
	for (i=0;i<5;i=i+1) begin : lp0
		xbar_4 xb0 (
			.clk(clk),
			.sel(sel0[(i+1)*2*4-1:i*2*4]),
			.din(din[(i+1)*4*WIDTH-1:i*4*WIDTH]),
			.dout(x0[(i+1)*4*WIDTH-1:i*4*WIDTH])
		);
		defparam xb0 .WIDTH = WIDTH;
	end
endgenerate

//////////////////////////////
// perm

clos_20_perm cp (
	.din(x0),
	.dout(x0p)	
);
defparam cp .WIDTH = 20*WIDTH;

//////////////////////////////
// 5x5 layer - four copies

generate
	for (i=0;i<4;i=i+1) begin : lp1
		xbar_5 xb1 (
			.clk(clk),
			.sel(sel1[(i+1)*3*5-1:i*3*5]),
			.din(x0p[(i+1)*5*WIDTH-1:i*5*WIDTH]),
			.dout(x1[(i+1)*5*WIDTH-1:i*5*WIDTH])
		);
		defparam xb1 .WIDTH = WIDTH;
	end
endgenerate

//////////////////////////////
// perm

clos_20_unperm cup (
	.din(x1),
	.dout(x1p)	
);
defparam cup .WIDTH = 20*WIDTH;

//////////////////////////////
// 4x4 layer - five copies

generate
	for (i=0;i<5;i=i+1) begin : lp2
		xbar_4 xb2 (
			.clk(clk),
			.sel(sel2[(i+1)*2*4-1:i*2*4]),
			.din(x1p[(i+1)*4*WIDTH-1:i*4*WIDTH]),
			.dout(dout[(i+1)*4*WIDTH-1:i*4*WIDTH])
		);
		defparam xb2 .WIDTH = WIDTH;
	end
endgenerate


endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2ES
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Combinational ALUTs : 960
// BENCHMARK INFO :  Memory ALUTs : 0
// BENCHMARK INFO :  Dedicated logic registers : 960
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.669 ns, From xbar_4:lp0[4].xb0|mx4r:lp[3].m|dout_r[1], To xbar_5:lp1[3].xb1|mx5r:lp[2].m|dout_r[1]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.586 ns, From xbar_4:lp0[4].xb0|mx4r:lp[1].m|dout_r[7], To xbar_5:lp1[1].xb1|mx5r:lp[1].m|dout_r[7]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.737 ns, From xbar_4:lp0[4].xb0|mx4r:lp[0].m|dout_r[2], To xbar_5:lp1[0].xb1|mx5r:lp[3].m|dout_r[2]}
