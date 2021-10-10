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
// baeckler - 08-20-2012

module delay_dynamic #(
	parameter WIDTH = 16,
	parameter TARGET_CHIP = 2, //  currently restricted to 2=S5
	parameter SIM_EMULATE = 1'b0
)(
	input clk,
	input [4:0] delta, 
		// ? avoid delta = 1, r/w collision
		//  minimum delta=2, latency of 1 tick
		//  ...
		//  delta = 1f,      latency of 30 ticks
		//  delta = 0		 latency of 31 ticks
	input din_valid,
	input [WIDTH-1:0] din_reg,
	output [WIDTH-1:0] dout	
);

// synthesis translate_off
generate 
	if (TARGET_CHIP != 2 && TARGET_CHIP != 5) begin
		initial begin
			$display ("ERROR:  %m using unsupported TARGET_CHIP of %d",TARGET_CHIP);
			$stop();
		end	
	end
endgenerate
// synthesis translate_on

localparam ADDR_WIDTH = 5;
reg [ADDR_WIDTH-1:0] waddr = {ADDR_WIDTH{1'b0}};
reg [ADDR_WIDTH-1:0] raddr = {ADDR_WIDTH{1'b0}};

always @(posedge clk) begin
	if (din_valid) begin
		raddr <= raddr + 1'b1;
		waddr <= raddr + delta;
	end
end

genvar i;
generate
   if (TARGET_CHIP == 2) begin
      s5mlab s5m (
	.wclk(clk),
	.wena(1'b1),
	.waddr_reg(waddr),
	.wdata_reg(din_reg),
	.raddr(raddr),
	.rdata(dout)		
      );
      defparam s5m .WIDTH = WIDTH;
      defparam s5m .ADDR_WIDTH = ADDR_WIDTH;
      defparam s5m .SIM_EMULATE = SIM_EMULATE;
   end
   else begin
      a10mlab a10m (
	.wclk(clk),
	.wena(1'b1),
	.waddr_reg(waddr),
	.wdata_reg(din_reg),
	.raddr(raddr),
	.rdata(dout)		
      );
      defparam a10m .WIDTH = WIDTH;
      defparam a10m .ADDR_WIDTH = ADDR_WIDTH;
      defparam a10m .SIM_EMULATE = SIM_EMULATE;
   end
endgenerate

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.4 LUTs
// BENCHMARK INFO :  Total registers : 10
// BENCHMARK INFO :  Total pins : 39
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 11              ;       ;
// BENCHMARK INFO :  ALMs : 16 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.355 ns, From raddr[0], To raddr[2]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.356 ns, From raddr[0], To raddr[2]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.355 ns, From raddr[0], To raddr[2]}
