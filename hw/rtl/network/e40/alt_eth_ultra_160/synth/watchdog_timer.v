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

// baeckler - 01-07-2012

module watchdog_timer #(
	parameter PRESCALE = 1'b0,
	parameter CNTR_BITS = 8	
)(
	input clk,
	input srst,
	output expired
);

wire cnt_ena;

generate
	if (PRESCALE) begin
		reg [15:0] pcntr = 16'h0;
		reg last_msb = 1'b0;
		reg ping = 1'b0;
		always @(posedge clk) begin
			pcntr <= pcntr + 1'b1;
			last_msb <= pcntr[15];
			ping <= pcntr[15] && !last_msb;
		end
		assign cnt_ena = ping;
	end
	else begin
		assign cnt_ena = 1'b1;
	end
endgenerate

reg [CNTR_BITS:0] cntr = {(CNTR_BITS+1){1'b0}};

always @(posedge clk) begin
	if (srst) cntr <= {(CNTR_BITS+1){1'b0}};
	else if (!cntr[CNTR_BITS]) cntr <= cntr + cnt_ena;
end
assign expired = cntr[CNTR_BITS];

endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  2.8 LUTs
// BENCHMARK INFO :  Total registers : 9
// BENCHMARK INFO :  Total pins : 3
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 12              ;       ;
// BENCHMARK INFO :  ALMs : 6 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.048 ns, From cntr[1], To cntr[8]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.153 ns, From cntr[1], To cntr[8]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.154 ns, From cntr[1], To cntr[8]}
