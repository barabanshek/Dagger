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

// baeckler - 01-09-2012
// master to be driven over JTAG by an external C program

module jtag_master #(
	parameter OP_TIMEOUT = 9
)(
	input clk,
	output reg wr,
	output reg rd,
	output [15:0] addr,
	output [31:0] wdata,
	input [31:0] rdata,
	input rdata_valid	
);

/////////////////////////////////////////////////////
// connect to JTAG shift reg, 64 bit

wire [63:0] dat_from_jtag;
reg [63:0] dat_to_jtag = 0;
wire dat_from_jtag_valid;
reg dat_to_jtag_valid = 1'b0;
wire dat_to_jtag_ack;

jtag_shift_reg jsr (
	// Hub sigs excluded - automatic connection

	.core_clock(clk),
	
	.dat_from_jtag(dat_from_jtag),
	.dat_from_jtag_valid(dat_from_jtag_valid),
	
	.dat_to_jtag(dat_to_jtag),
	.dat_to_jtag_valid(dat_to_jtag_valid),
	.dat_to_jtag_ack(dat_to_jtag_ack)	
);

/////////////////////////////////////////////////////
// parse into r/w bus transactions

assign {addr,wdata} = dat_from_jtag[47:0];

reg [1:0] st = 2'h0 /* synthesis preserve dont_replicate */;

reg cmd_r = 1'b0;
reg cmd_w = 1'b0;
reg check_pass = 1'b0;

localparam ST_READY = 2'h0,
		ST_CHECK_OP = 2'h1,
		ST_REPLY = 2'h2,
		ST_REPLY_ACK = 2'h3;

wire [7:0] rdata_check;
dip8_48 rdip (
	.d({addr,rdata}),
	.p(rdata_check)
);

wire [7:0] jdata_check;
dip8_48 jdip (
	.d(dat_from_jtag[47:0]),
	.p(jdata_check)
);
reg [7:0] jdata_check_r = 8'h0;
reg dat_from_jtag_valid_r = 1'b0;

wire timeout;

always @(posedge clk) begin
	wr <= 1'b0;
	rd <= 1'b0;
	
	// Note : this is fudging the latency of the data from JTAG,
	// it needs to hold a few cycles after the pulse
	
	cmd_r <= (dat_from_jtag[63:56] == "r");
	cmd_w <= (dat_from_jtag[63:56] == "w");
	jdata_check_r <= jdata_check;
	check_pass <= (dat_from_jtag[55:48] == jdata_check_r);
	dat_from_jtag_valid_r <= dat_from_jtag_valid;
	
	case (st) 
		ST_READY : begin
			dat_to_jtag_valid <= 1'b0;
			if (dat_from_jtag_valid_r) st <= ST_CHECK_OP;			
		end	
		ST_CHECK_OP : begin
			st <= ST_READY;
			if (cmd_w && check_pass) begin
				wr <= 1'b1;
			end
			if (cmd_r && check_pass) begin
				rd <= 1'b1;
				st <= ST_REPLY;
			end			
		end	
		ST_REPLY : begin
			dat_to_jtag[31:0] <= rdata;
			dat_to_jtag[47:32] <= addr;
			dat_to_jtag[55:48] <= rdata_check;
			dat_to_jtag[63:56] <= "d";								
			
			if (rdata_valid) begin
				dat_to_jtag_valid <= 1'b1;
				st <= ST_REPLY_ACK;
			end		
		end
		ST_REPLY_ACK : begin
			if (dat_to_jtag_ack) begin
				dat_to_jtag_valid <= 1'b0;
				st <= ST_READY;
			end
		end
	endcase	
	
	// watchdog rule, must return to ready frequently
	if (timeout) st <= ST_READY;
end

watchdog_timer wd (
	.clk(clk),
	.srst(st == ST_READY),
	.expired(timeout)
);
defparam wd .CNTR_BITS = OP_TIMEOUT;

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  2.9 LUTs
// BENCHMARK INFO :  Total registers : 578
// BENCHMARK INFO :  Total pins : 84
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 177             ;       ;
// BENCHMARK INFO :  ALMs : 231 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.722 ns, From sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|irsr_reg[0], To sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|tdo}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.625 ns, From sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|irsr_reg[1], To sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|tdo}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.679 ns, From sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|virtual_ir_scan_reg, To sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|tdo}
