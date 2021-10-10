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


// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/hsl18/scrambler.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
//-----------------------------------------------------------------------------
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

module scrambler # (
	parameter WIDTH = 512,
	parameter SCRAM_INIT = 58'h3ff_ffff_ffff_ffff,
	parameter DEBUG_DONT_SCRAMBLE = 1'b0
)(
	input clk,srst,ena,
	input [WIDTH-1:0] din,		// bit 0 is to be sent first
	output reg [WIDTH-1:0] dout=0
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

//wire [WIDTH-1:0] dout_w /* synthesis keep */;
//assign dout_w = srst ? {WIDTH{1'b0}} : (ena ? history[WIDTH+58-1:58] : dout);
//always @(posedge clk) dout <= dout_w;

//wire [57:0] scram_state_w /* synthesis keep */;
//assign scram_state_w = srst ? SCRAM_INIT : (ena ? history[WIDTH+58-1:WIDTH] : scram_state);
//always @(posedge clk) scram_state <= scram_state_w;

   reg [7:0] cnt;
   reg 		 rst_out;
   
   always @(posedge clk)
	 begin
		if (srst)
		  begin
			 cnt <= 8'd0;
			 rst_out <= 1'b1;
		  end
		else
		  begin
			 if (cnt != 8'd255)
			   begin
				  rst_out <= 1'b1;
				  cnt <= cnt + 8'd1;
			   end
			 else
			   begin
				  rst_out <= 1'b0;
			   end
		  end // else: !if(srst)
	 end // always @ (posedge clk)
			   
always @(posedge clk) begin
	if (rst_out) begin
		dout <= 0;
		scram_state <= SCRAM_INIT;
	end
	else if (ena) begin
		dout <= history[WIDTH+58-1:58];
		scram_state <= history[WIDTH+58-1:WIDTH];
	end
end

endmodule
	
// BENCHMARK INFO :  5SGXEA7N2F45C2ES
// BENCHMARK INFO :  Max depth :  6.0 LUTs
// BENCHMARK INFO :  Combinational ALUTs : 1,940
// BENCHMARK INFO :  Memory ALUTs : 0
// BENCHMARK INFO :  Dedicated logic registers : 570
// BENCHMARK INFO :  Total block memory bits : 0
