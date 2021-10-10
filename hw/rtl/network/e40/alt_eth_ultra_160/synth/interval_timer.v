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
// baeckler 08-25-2012
// interval pulse follower with hysteresis

module interval_timer #(
	parameter TARGET_CHIP = 2,
	parameter CNTR_BITS = 17,
	parameter WRAP_VAL = 16 * 5 - 2,
	parameter LEAD_VAL = WRAP_VAL - 5
)(
	input clk,
	
	input suggest_pulse,
	output reg locked,
	output predict_pulse,
	output lead_pulse
);

//////////////////////////////
// main counter
reg sclr_cntr = 1'b0;
reg [CNTR_BITS-1:0] cntr = 0;
always @(posedge clk) begin
	if (sclr_cntr) cntr <= {CNTR_BITS{1'b0}} | 2'h2;
	else cntr <= cntr + 1'b1;
end

//////////////////////////////
// wrap comparator, latency 2
wire match;
eq_18_const eq (
	.clk(clk),
	.din({1'b0,cntr}),
	.match(match)
);
defparam eq .TARGET_CHIP = TARGET_CHIP;
defparam eq .VAL = WRAP_VAL;

assign predict_pulse = match;

//////////////////////////////
// wrap comparator, latency 2
eq_18_const eq2 (
	.clk(clk),
	.din({1'b0,cntr}),
	.match(lead_pulse)
);
defparam eq2 .TARGET_CHIP = TARGET_CHIP;
defparam eq2 .VAL = LEAD_VAL;

//////////////////////////////
// control 

localparam ST_INIT = 2'd0,
		ST_AGAIN = 2'd1,
		ST_LOCKED = 2'd2,
		ST_DANGER = 2'd3;
		
reg [1:0] st = 2'b0 /* synthesis preserve */;
always @(posedge clk) begin
	sclr_cntr <= 1'b0;
	locked <= 1'b0;
	
	case (st) 
		ST_INIT: begin
			// look for a starting point
			if (suggest_pulse) begin
				sclr_cntr <= 1'b1;
				st <= ST_AGAIN;
			end
		end
		ST_AGAIN: begin
			// look for a 2nd pulse at the predicted separation
			if (predict_pulse) begin
				sclr_cntr <= 1'b1;
				if (suggest_pulse) st <= ST_LOCKED;
				else st <= ST_INIT;
			end
		end
		ST_LOCKED: begin
			locked <= 1'b1;
			if (predict_pulse) begin
				sclr_cntr <= 1'b1;
				if (!suggest_pulse) st <= ST_DANGER;				
			end		
		end
		ST_DANGER: begin
			// a predicted pulse wasn't there, if it happens a second time lose lock
			locked <= 1'b1;
			if (predict_pulse) begin
				sclr_cntr <= 1'b1;
				if (!suggest_pulse) begin
					// second missing pulse, drop out if lock
					st <= ST_INIT;
				end
				else begin
					// false alarm
					st <= ST_LOCKED;				
				end
			end		
		end
	endcase
end

endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  2.6 LUTs
// BENCHMARK INFO :  Total registers : 29
// BENCHMARK INFO :  Total pins : 5
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 29              ;       ;
// BENCHMARK INFO :  ALMs : 17 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.230 ns, From cntr[1], To cntr[15]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.952 ns, From cntr[8], To cntr[11]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.245 ns, From cntr[0], To cntr[15]}
