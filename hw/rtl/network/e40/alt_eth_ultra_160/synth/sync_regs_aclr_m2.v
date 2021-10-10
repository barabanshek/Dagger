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

// baeckler - 01-08-2012

module sync_regs_aclr_m2 #(
	parameter WIDTH = 32,
	parameter DEPTH = 2		// minimum of 2
)(
	input clk,
	input aclr,
	input [WIDTH-1:0] din,
	output [WIDTH-1:0] dout
);

reg [WIDTH-1:0] din_meta = 0 /* synthesis preserve dont_replicate */
/* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_multicycle_path -to [get_keepers *sync_regs_aclr_m*din_meta\[*\]] 2\" " */ ;

reg [WIDTH*(DEPTH-1)-1:0] sync_sr = 0 /* synthesis preserve dont_replicate */
/* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -hold -to [get_keepers *sync_regs_aclr_m*din_meta\[*\]]\" " */ ;


always @(posedge clk or posedge aclr) begin
	if (aclr) begin 
		din_meta <= {WIDTH{1'b0}};
		sync_sr <= {(WIDTH*(DEPTH-1)){1'b0}};
	end
	else begin
		din_meta <= din;
		sync_sr <= (sync_sr << WIDTH) | din_meta;
	end
end
assign dout = sync_sr[WIDTH*(DEPTH-1)-1:WIDTH*(DEPTH-2)];

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  0.0 LUTs
// BENCHMARK INFO :  Total registers : 64
// BENCHMARK INFO :  Total pins : 66
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 1               ;       ;
// BENCHMARK INFO :  ALMs : 17 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.702 ns, From din_meta[22], To sync_sr[22]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.705 ns, From din_meta[13], To sync_sr[13]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.708 ns, From din_meta[13], To sync_sr[13]}
