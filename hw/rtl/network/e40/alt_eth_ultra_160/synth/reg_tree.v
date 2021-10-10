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
// baeckler - 07-16-2012

module reg_tree #(
	parameter BRANCH_FACTOR = 4,
	parameter NUM_OUTS = 16	
)(
	input clk,
	input din,
	output [NUM_OUTS-1:0] dout
);

reg [NUM_OUTS-1:0] dout_r = {NUM_OUTS{1'b0}} /* synthesis preserve */;
assign dout = dout_r;

localparam NUM_INS = NUM_OUTS / BRANCH_FACTOR;
localparam NUM_INS_PAD = ((NUM_INS * BRANCH_FACTOR) < NUM_OUTS) ?
							NUM_INS + 1 : NUM_INS;

wire [NUM_INS_PAD-1:0] tmp_ins;

genvar i;
generate 
	for (i=0; i<NUM_OUTS; i=i+1) begin : lp
		always @(posedge clk) begin
			dout_r[i] <= tmp_ins[i/BRANCH_FACTOR];
		end		
	end
endgenerate

generate
	if (NUM_INS_PAD > 1) begin
		reg_tree rt (
			.clk(clk),
			.din(din),
			.dout(tmp_ins)
		);
		defparam rt .BRANCH_FACTOR = BRANCH_FACTOR;
		defparam rt .NUM_OUTS = NUM_INS_PAD;
	end
	else begin
		assign tmp_ins[0] = din;
	end
endgenerate	

endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  0.0 LUTs
// BENCHMARK INFO :  Total registers : 20
// BENCHMARK INFO :  Total pins : 18
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 1               ;       ;
// BENCHMARK INFO :  ALMs : 6 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.674 ns, From reg_tree:rt|dout_r[1], To dout_r[6]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.636 ns, From reg_tree:rt|dout_r[3], To dout_r[13]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.648 ns, From reg_tree:rt|dout_r[2], To dout_r[9]}
