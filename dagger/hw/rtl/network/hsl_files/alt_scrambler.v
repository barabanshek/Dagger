// Copyright 2011 Altera Corporation. All rights reserved.  
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

// baeckler - 12-17-2008
// Unrolled scrambler LFSR

// DESCRIPTION
// 
// This is a 40/100G Ethernet style self synchronizing scrambler. It uses a fixed 57 bit sparse polynomial.
// Although used successfully at speed in Altera Ethernet cores at up to 320 bits wide we have observed
// some unusually deep LUT paths compiling this block standalone. It may be converted to a more
// structured version in the near future. The library now contains a highly pipelined version for 1024 bits.
// The structured building blocks could be adapted fairly quickly to other widths.
// 
//  



// CONFIDENCE
// This has been used successfully in multiple Altera Ethernet cores and other test designs.
// 

module alt_scrambler # (
	parameter WIDTH = 512,
	parameter SCRAM_INIT = 58'h3ff_ffff_ffff_ffff,
	parameter DEBUG_DONT_SCRAMBLE = 1'b0
)(
	input clk,srst,ena,
	input [WIDTH-1:0] din,		// bit 0 is to be sent first
	output reg [WIDTH-1:0] dout
);

reg [57:0] scram_state = SCRAM_INIT;
wire [WIDTH+58-1:0] history;
assign history [57:0] = scram_state;

genvar i;
generate
	for (i=58; i<WIDTH+58; i=i+1) begin : lp
		assign history[i] = 
			(DEBUG_DONT_SCRAMBLE ? 1'b0 : (history[i-58] ^ history[i-39])) ^ din[i-58];		
	end
endgenerate

// suppress secondary signal inference

wire [WIDTH-1:0] dout_w /* synthesis keep */;
assign dout_w = srst ? {WIDTH{1'b0}} : (ena ? history[WIDTH+58-1:58] : dout);
always @(posedge clk) dout <= dout_w;

wire [57:0] scram_state_w /* synthesis keep */;
assign scram_state_w = srst ? SCRAM_INIT : (ena ? history[WIDTH+58-1:WIDTH] : scram_state);
always @(posedge clk) scram_state <= scram_state_w;

/*
always @(posedge clk) begin
	if (srst) begin
		dout <= 0;
		scram_state <= SCRAM_INIT;
	end
	else if (ena) begin
		dout <= history[WIDTH+58-1:58];
		scram_state <= history[WIDTH+58-1:WIDTH];
	end
end
*/
endmodule
	

// BENCHMARK INFO :  10AX115U2F45I2SGE2
// BENCHMARK INFO :  Quartus Prime Version 15.1.0 Internal Build 99 06/10/2015 TO Standard Edition
// BENCHMARK INFO :  Uses helper file :  alt_scrambler.v
// BENCHMARK INFO :  Max depth :  6.0 LUTs
// BENCHMARK INFO :  Total registers : 570
// BENCHMARK INFO :  Total pins : 1,027
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :  1,913          
// BENCHMARK INFO :  ALMs : 957 / 427,200 ( < 1 % )
