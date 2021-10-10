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

// baeckler - 01-09-2012

`timescale 1ps/1ps

module cross_handshake #(
	parameter WIDTH = 40
)(
	input din_clk,
	input [WIDTH-1:0] din,
	input din_valid,
	output din_ack,
	
	input dout_clk,
	output [WIDTH-1:0] dout,
	output dout_valid,
	input dout_ack	
);

reg [WIDTH-1:0] launch = {WIDTH{1'b0}} /* synthesis preserve dont_replicate */;
reg launch_valid = 1'b0 /* synthesis preserve dont_replicate */;
reg launch_fresh = 1'b0 /* synthesis preserve dont_replicate */;
always @(posedge din_clk) begin
	launch_fresh <= 1'b0;
	if (din_ack) launch_valid <= 1'b0;
	if (!launch_valid && din_valid) begin
		launch <= din;
		launch_valid <= 1'b1;
		launch_fresh <= 1'b1;
	end
end

// move capturing pulse to output side
wire capture_ena;
cross_strobe sc0 (
	.din_clk(din_clk),
	.din_pulse(launch_fresh),
	
	.dout_clk(dout_clk),
	.dout_pulse(capture_ena)
);

// manage the capture to occur when the input is very stable
reg [WIDTH-1:0] capture = {WIDTH{1'b0}};
wire capture_ack;
reg capture_valid = 1'b0;

always @(posedge dout_clk) begin
	if (capture_ack) capture_valid <= 1'b0;
	if (capture_ena) begin
		capture <= launch;
		capture_valid <= 1'b1;		
	end
end

// return the ack
cross_strobe sc1 (
	.din_clk(dout_clk),
	.din_pulse(dout_ack),
	
	.dout_clk(din_clk),
	.dout_pulse(din_ack)
);

assign dout = capture;
assign dout_valid = capture_valid;
assign capture_ack = dout_ack;

endmodule
	
	
	
	
	
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 93
// BENCHMARK INFO :  Total pins : 86
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 8               ;       ;
// BENCHMARK INFO :  ALMs : 26 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.746 ns, From launch_valid, To launch[14]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.690 ns, From launch_valid, To launch[1]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.753 ns, From launch_valid, To launch[4]}
