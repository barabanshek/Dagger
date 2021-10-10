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
// baeckler - 11-08-2012
// pipelined loadable clearable accumulator 

module accum #(
	parameter WIDTH = 64,	// must be even, and sized for a /2 adder pipeline to make sense.
							// overkill below 32, insufficient beyond ~128
	parameter INC_WIDTH = 16    // at most WIDTH/2
)(
	input clk,
	input aclr,
	input sclr,
	input sload,
	input [WIDTH-1:0] sload_val,
	input [INC_WIDTH-1:0] inc,
	output [WIDTH-1:0] sum
);

reg [WIDTH/2:0] cume_lower = {(WIDTH/2+1){1'b0}} /* synthesis preserve */;
reg [WIDTH/2-1:0] cume_upper = {(WIDTH/2){1'b0}} /* synthesis preserve */;
reg [WIDTH/2-1:0] cume_lower_d = {(WIDTH/2){1'b0}} /* synthesis preserve */;

always @(posedge clk or posedge aclr) begin
	if (aclr) begin
		cume_lower <= {(WIDTH/2+1){1'b0}};
		cume_lower_d <= {(WIDTH/2){1'b0}};
		cume_upper <= {(WIDTH/2){1'b0}};
	end
	else begin
		if (sclr) begin
			cume_lower <= {(WIDTH/2+1){1'b0}};
			cume_lower_d <= {(WIDTH/2){1'b0}};
			cume_upper <= {(WIDTH/2){1'b0}};
		end 
		else if (sload) begin
			cume_lower <= {1'b0,sload_val[(WIDTH/2)-1:0]};
			cume_lower_d <= sload_val[(WIDTH/2)-1:0];
			cume_upper <= sload_val[WIDTH-1:WIDTH/2];
		end
		else begin
			cume_lower <= {1'b0,cume_lower[WIDTH/2-1:0]} + inc;
			cume_lower_d <= cume_lower[WIDTH/2-1:0];
			cume_upper <= cume_upper + cume_lower[WIDTH/2];
		end	
	end	
end

assign sum = {cume_upper,cume_lower_d};

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  5.2 LUTs
// BENCHMARK INFO :  Total registers : 97
// BENCHMARK INFO :  Total pins : 148
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 67              ;       ;
// BENCHMARK INFO :  ALMs : 51 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.651 ns, From cume_lower[20], To cume_lower[32]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.704 ns, From cume_lower[24], To cume_lower[32]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.643 ns, From cume_lower[20], To cume_lower[32]}
