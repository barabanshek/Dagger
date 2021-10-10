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

// baeckler - 12-14-2012

module scfifo_s5m20k #(
	parameter WIDTH = 8,
	parameter ADDR_WIDTH = 11
)(
	input clk,
	input sclr,
	
	input wrreq,
	input [WIDTH-1:0] data,
	output full,
	
	input rdreq,
	output [WIDTH-1:0] q,
	output empty,
	
	output reg [ADDR_WIDTH+1-1:0] usedw
);

wire qualified_write = wrreq & !full;
wire qualified_read = rdreq & !empty;

reg [ADDR_WIDTH+1-1:0] waddr = {(ADDR_WIDTH+1){1'b0}};
reg [ADDR_WIDTH+1-1:0] raddr = {(ADDR_WIDTH+1){1'b0}};

always @(posedge clk) begin
	if (sclr) waddr <= {(ADDR_WIDTH+1){1'b0}};
	else if (qualified_write) waddr <= waddr + 1'b1;
end

always @(posedge clk) begin
	if (sclr) raddr <= {(ADDR_WIDTH+1){1'b0}};
	else if (qualified_read) raddr <= raddr + 1'b1;
end

assign empty = (waddr == raddr) ? 1'b1 : 1'b0;
assign full = (waddr == (raddr ^ {1'b1,{ADDR_WIDTH{1'b0}}})) ? 1'b1 : 1'b0;

initial usedw = {(ADDR_WIDTH+1){1'b0}};
always @(posedge clk) begin
	usedw <= waddr - raddr;
end

altsyncram	altsyncram_component (
				.address_a (waddr[ADDR_WIDTH-1:0]),
				.clock0 (clk),
				.data_a (data),
				.wren_a (qualified_write),
				.address_b (raddr[ADDR_WIDTH-1:0]),
				.q_b (q),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b ({WIDTH{1'b1}}),
				.eccstatus (),
				.q_a (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_b (1'b0));
	defparam
		altsyncram_component.address_aclr_b = "NONE",
		altsyncram_component.address_reg_b = "CLOCK0",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_input_b = "BYPASS",
		altsyncram_component.clock_enable_output_b = "BYPASS",
		altsyncram_component.enable_ecc = "FALSE",
		altsyncram_component.intended_device_family = "Stratix V",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = (1 << ADDR_WIDTH),
		altsyncram_component.numwords_b =  (1 << ADDR_WIDTH),
		altsyncram_component.operation_mode = "DUAL_PORT",
		altsyncram_component.outdata_aclr_b = "NONE",
		altsyncram_component.outdata_reg_b = "UNREGISTERED",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.ram_block_type = "M20K",
		altsyncram_component.read_during_write_mode_mixed_ports = "DONT_CARE",
		altsyncram_component.widthad_a = ADDR_WIDTH,
		altsyncram_component.widthad_b = ADDR_WIDTH,
		altsyncram_component.width_a = WIDTH,
		altsyncram_component.width_b = WIDTH,
		altsyncram_component.width_byteena_a = 1;

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  3.0 LUTs
// BENCHMARK INFO :  Total registers : 36
// BENCHMARK INFO :  Total pins : 34
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 16,384
// BENCHMARK INFO :  Comb ALUTs :                         ; 47                  ;       ;
// BENCHMARK INFO :  ALMs : 26 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.538 ns, From raddr[3], To altsyncram:altsyncram_component|altsyncram_ki62:auto_generated|ram_block1a0~porta_we_reg}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.547 ns, From waddr[6], To altsyncram:altsyncram_component|altsyncram_ki62:auto_generated|ram_block1a0~porta_we_reg}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.623 ns, From waddr[1], To altsyncram:altsyncram_component|altsyncram_ki62:auto_generated|ram_block1a0~porta_we_reg}
