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
// baeckler - 08-14-2012
// registered XOR together bits with a MUX in front

module xor_r_t #(
	parameter TARGET_CHIP = 2,
	parameter WIDTH = 4
)(
	input clk,
	input thru, // force dout to thru_d
	input thru_d,
	input [WIDTH-1:0] din,
	output dout
);

genvar i;
generate
	if (WIDTH <= 4) begin
		reg dout_r = 1'b0;
		always @(posedge clk) dout_r <= thru ? thru_d : ^din;
		assign dout = dout_r;
	end
	else begin
		// synthesis translate_off
		initial begin
			$display ("Error : xor_r_t needs to be expanded for width %d",WIDTH);
			$stop();
		end
		// synthesis translate_on		
	end
endgenerate

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 1
// BENCHMARK INFO :  Total pins : 8
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 2               ;       ;
// BENCHMARK INFO :  ALMs : 2 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.992 ns, From (primary), To dout_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.747 ns, From (primary), To dout_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.728 ns, From (primary), To dout_r}
