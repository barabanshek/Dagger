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

module bip_xor (
	input clk,
	input restart,
	input [65:0] din,
	output [7:0] dout
);

wire [7:0] xa,xb;
wire [65:0] d = din;

xor_r x0 (.clk(clk), .dout(xa[0]),.din({d[2], d[10], d[18], d[26]}));
xor_r xx0 (.clk(clk), .dout(xb[0]),.din({d[34], d[42], d[50], d[58]}));
xor_r x1 (.clk(clk), .dout(xa[1]),.din({d[3], d[11], d[19], d[27]}));
xor_r xx1 (.clk(clk), .dout(xb[1]),.din({d[35], d[43], d[51], d[59]}));
xor_r x2 (.clk(clk), .dout(xa[2]),.din({d[4], d[12], d[20], d[28]}));
xor_r xx2 (.clk(clk), .dout(xb[2]),.din({d[36], d[44], d[52], d[60]}));
xor_r x3 (.clk(clk), .dout(xa[3]),.din({d[0], d[5], d[13], d[21]})); 
xor_r xx3 (.clk(clk), .dout(xb[3]),.din({d[29], d[37], d[45], d[53], d[61]}));
xor_r x4 (.clk(clk), .dout(xa[4]),.din({d[1], d[6], d[14], d[22]})); 
xor_r xx4 (.clk(clk), .dout(xb[4]),.din({d[30], d[38], d[46], d[54], d[62]}));
xor_r x5 (.clk(clk), .dout(xa[5]),.din({d[7], d[15], d[23], d[31]}));
xor_r xx5 (.clk(clk), .dout(xb[5]),.din({d[39], d[47], d[55], d[63]}));
xor_r x6 (.clk(clk), .dout(xa[6]),.din({d[8], d[16], d[24], d[32]}));
xor_r xx6 (.clk(clk), .dout(xb[6]),.din({d[40], d[48], d[56], d[64]}));
xor_r x7 (.clk(clk), .dout(xa[7]),.din({d[9], d[17], d[25], d[33]}));
xor_r xx7 (.clk(clk), .dout(xb[7]),.din({d[41], d[49], d[57], d[65]}));

defparam x0 .WIDTH = 4;
defparam x1 .WIDTH = 4;
defparam x2 .WIDTH = 4;
defparam x3 .WIDTH = 4; 
defparam x4 .WIDTH = 4;
defparam x5 .WIDTH = 4;
defparam x6 .WIDTH = 4;
defparam x7 .WIDTH = 4;

defparam xx0 .WIDTH = 4;
defparam xx1 .WIDTH = 4;
defparam xx2 .WIDTH = 4;
defparam xx3 .WIDTH = 5; 
defparam xx4 .WIDTH = 5;
defparam xx5 .WIDTH = 4;
defparam xx6 .WIDTH = 4;
defparam xx7 .WIDTH = 4;

// accumulator
reg [7:0] out_r = 8'h0;
always @(posedge clk) begin
	if (restart) out_r <= 8'h8; // the BIP of any vlane tag is 08
	else out_r <= out_r ^ xa ^ xb;
end
assign dout = out_r;

endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 24
// BENCHMARK INFO :  Total pins : 76
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 25              ;       ;
// BENCHMARK INFO :  ALMs : 16 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.598 ns, From xor_r:xx3|dout_r, To out_r[3]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.601 ns, From out_r[5], To out_r[5]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.607 ns, From xor_r:x4|dout_r, To out_r[4]}
