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
// Copyright 2009 Altera Corporation. All rights reserved.  
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

// baeckler - 01-15-2009
// MII encode next state logic

module sim_block_decoder_ns (
	input [1:0] state,
	
	input next_start_or_control,
	input [2:0] behavior_tag,		// 1xx error
										// 0 start
										// 1 control
										// 2 terminating
										// 3 data
	output reg [1:0] next_state	
);

localparam 	RX_C = 2'd0,
			RX_D = 2'd1,
			RX_T = 2'd2,
			RX_E = 2'd3;

localparam START = 2'd0,
			CONTROL = 2'd1,
			TERMINATE = 2'd2,
			DATA = 2'd3;

always @(*) begin	
	if (behavior_tag[2]) next_state = RX_E;
	else begin
		next_state = state;
		case (state)
			RX_C: begin
				if (behavior_tag[1:0] == START) next_state = RX_D;
				else if (behavior_tag[1:0] != CONTROL) next_state = RX_E;
			end
			RX_D : begin
				if (behavior_tag[1:0] == TERMINATE &&
					next_start_or_control) next_state = RX_T;
				else if (behavior_tag[1:0] != DATA) next_state = RX_E;				
			end
			RX_T : begin
				if (behavior_tag[1:0] == START) next_state = RX_D;
				else if (behavior_tag[1:0] == CONTROL) next_state = RX_C;				
				else next_state = RX_E;
			end
			RX_E : begin
				if (behavior_tag[1:0] == TERMINATE &&
					next_start_or_control) next_state = RX_T;
				else if (behavior_tag[1:0] == CONTROL) next_state = RX_C;				
				else if (behavior_tag[1:0] == DATA) next_state = RX_D;				
			end
			default : next_state = state;	// LEDA
		endcase
	end		
end

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 0
// BENCHMARK INFO :  Total pins : 8
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 3               ;       ;
// BENCHMARK INFO :  ALMs : 3 / 234,720 ( < 1 % )
