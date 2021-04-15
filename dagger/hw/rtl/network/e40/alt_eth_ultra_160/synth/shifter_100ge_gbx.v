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


// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/hsl18/shifter_100ge_gbx.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
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
// baeckler - 08-17-2012

module shifter_100ge_gbx #(
	parameter WORD_WIDTH = 66,
	parameter MAX_SHL = 66,
	parameter MIN_SHL = MAX_SHL - 14,
	parameter TARGET_CHIP = 2,
	parameter LD_MASK = 64'h0000000842108421,
	parameter ADD_SKEW = 0
)(
	input clk,
	input [WORD_WIDTH+14-1:0] din_sh,
	input [WORD_WIDTH+14-1:0] din_ns,
	input shft, 
	input ld_pos2,
	input [5:0] cnt,		
	output [15:0] dout	
);

////////////////////////////////////////////////////
// load control masks

wire ld_w; 

wys_lut w0 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(ld_w));
defparam w0 .MASK = LD_MASK;
defparam w0 .TARGET_CHIP = TARGET_CHIP;


reg ld = 0 /* synthesis preserve */; 
always @(posedge clk) begin
	ld <= ld_w;
end

////////////////////////////////////////////////////
// shifter
	
reg [MAX_SHL + WORD_WIDTH-1:0] storage = 0;
wire [MAX_SHL + WORD_WIDTH-1:0] ld_dat;

reg [WORD_WIDTH+14-1:0] ld_active = 0;
assign ld_dat = {(MAX_SHL+WORD_WIDTH){1'b0}} | (ld_active << MIN_SHL);

always @(posedge clk) begin
	storage <= (shft ? {16'h0,storage[MAX_SHL+WORD_WIDTH-1:16]} : storage) | ld_dat;
	
	// debug msg - happens during clr, or schedule bug
	// synthesis translate_off
	//if (|((shft ? {16'h0,storage[MAX_SHL+WORD_WIDTH-1:16]} : storage) & ld_dat)) begin
	//	$display ("Warning : stomping on data in shifter %m time %d",$time);
	//end	
	// synthesis translate_on
	
	ld_active <= ld ? (ld_pos2 ? din_sh : din_ns) : 0;
end

generate 
	if (ADD_SKEW == 0) begin
		assign dout = storage[15:0];
	end
	else begin
		// mess up the TX alignment semi randomly 
		wire [15:0] lag_dout;
		delay_regs_ena dr0 (
			.clk(clk),
			.ena(shft),
			.din(storage[15:0]),
			.dout(lag_dout)	
		);
		defparam dr0 .WIDTH = 16;
		defparam dr0 .LATENCY = 1 + (ADD_SKEW % 25);
		assign dout = lag_dout;
	end
endgenerate

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2ES
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Combinational ALUTs : 81
// BENCHMARK INFO :  Memory ALUTs : 0
// BENCHMARK INFO :  Dedicated logic registers : 213
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.220 ns, From ld, To ld_active[2]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.272 ns, From ld, To ld_active[59]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.206 ns, From ld, To ld_active[67]}
