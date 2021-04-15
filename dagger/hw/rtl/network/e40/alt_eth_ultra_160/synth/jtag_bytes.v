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
// Copyright 2013 Altera Corporation. All rights reserved.  
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

// baeckler -12-16-2012
// buffered byte stream over jtag

module jtag_bytes #(
	parameter SIM_FAKE = 1'b0     // this is a little flakey, just for testing
)(
	input clk,
	input sclr,
	
	input [7:0] byte_to_jtag,
	input byte_to_jtag_valid,
	output reg to_jtag_pfull,
	
	output reg [7:0] byte_from_jtag,
	input byte_from_jtag_ack,
	output reg from_jtag_pfull	
);

wire [7:0] ur_fromj;
wire [7:0] ur_toj;
wire ur_fromj_valid;
reg ur_toj_valid = 1'b0;
wire ur_toj_ack;

generate
	if (SIM_FAKE) begin
		assign ur_fromj = ur_toj;
		assign ur_fromj_valid = ur_toj_valid;
		assign ur_toj_ack = 1'b1;
	end
	else begin
		jtag_shift_reg ur (
			// Hub sigs
			// (automatic)
			
			// internal sigs
			// data to and from host PC
			.core_clock(clk),
			
			.dat_from_jtag(ur_fromj),
			.dat_from_jtag_valid(ur_fromj_valid),
			
			.dat_to_jtag(ur_toj),
			.dat_to_jtag_valid(ur_toj_valid),
			.dat_to_jtag_ack(ur_toj_ack)
		);
		defparam ur .NODE_ID = 8'h99;
		defparam ur .DAT_WIDTH = 8;
	end
endgenerate

/////////////////////////////////////
// FPGA core to JTAG TX buffer

wire tx_empty;
wire tx_rd;
wire [11:0] tx_used;

initial to_jtag_pfull = 1'b0;
always @(posedge clk) begin
	to_jtag_pfull <= tx_used[11] | (tx_used[10] & tx_used[9]);
end

scfifo_s5m20k txb (
	.clk(clk),
	.sclr(sclr),
	
	.wrreq(byte_to_jtag_valid),
	.data(byte_to_jtag),
	.full(),
	
	.rdreq(tx_rd),
	.q(ur_toj),
	.empty(tx_empty),
	.usedw(tx_used)
);
defparam txb .WIDTH = 8;
defparam txb .ADDR_WIDTH = 11;

assign tx_rd = (!ur_toj_valid | ur_toj_ack) & !tx_empty;
always @(posedge clk) begin
	if (ur_toj_ack) ur_toj_valid <= 1'b0;
	if (tx_rd) ur_toj_valid <= 1'b1;
end

/////////////////////////////////////
// JTAG RX to FPGA core buffer

wire rx_empty;
wire rx_rd;
wire [7:0] rx_q;
wire [11:0] rx_used;

scfifo_s5m20k rxb (
	.clk(clk),
	.sclr(sclr),
	
	.wrreq(ur_fromj_valid & (|ur_fromj)),
	.data(ur_fromj),
	.full(),
	
	.rdreq(rx_rd),
	.q(rx_q),
	.empty(rx_empty),
	.usedw(rx_used)
);
defparam rxb .WIDTH = 8;
defparam rxb .ADDR_WIDTH = 11;

initial from_jtag_pfull = 1'b0;
always @(posedge clk) begin
	from_jtag_pfull <= rx_used[11] | (rx_used[10] & rx_used[9]);
end

reg rx_q_fresh = 1'b0;

initial byte_from_jtag = 8'h0;
assign rx_rd = byte_from_jtag_ack && !rx_empty;
always @(posedge clk) begin
	rx_q_fresh <= rx_rd;
	if (byte_from_jtag_ack) begin
		byte_from_jtag <= 8'h0;
	end
	if (rx_q_fresh) begin
		byte_from_jtag <= rx_q;
	end
end

endmodule 

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  3.0 LUTs
// BENCHMARK INFO :  Total registers : 220
// BENCHMARK INFO :  Total pins : 21
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 32,768
// BENCHMARK INFO :  Comb ALUTs :                         ; 214                 ;       ;
// BENCHMARK INFO :  ALMs : 143 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.256 ns, From sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|sld_shadow_jsm:shadow_jsm|state[4], To sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|tdo}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.468 ns, From sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|irsr_reg[2], To sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|tdo}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.455 ns, From sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|irsr_reg[1], To sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|tdo}
