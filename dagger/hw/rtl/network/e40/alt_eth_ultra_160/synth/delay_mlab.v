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

// baeckler - 01-17-2012

module delay_mlab #(
	parameter WIDTH = 32,
	parameter LATENCY = 5, // minimum of 2, maximum of 33 for s5, 32 for s4
	parameter TARGET_CHIP = 1, // 1 S4, 2 S5
	parameter FRACTURE = 1   // duplicate the addressing
)(
	input clk,
	input [WIDTH-1:0] din,
	output [WIDTH-1:0] dout	
);

//////////////////////////////////////////////////
// figure out the addressing

// Stratix 4 and 5 have slightly different write latency
localparam ADDR_WIDTH = (TARGET_CHIP == 2) ? (
							 (LATENCY > 17) ? 5 : 
							 (LATENCY > 9) ? 4 :
							 (LATENCY > 5) ? 3 : 2)
					     : (
							 (LATENCY > 16) ? 5 : 
							 (LATENCY > 8) ? 4 :
							 (LATENCY > 4) ? 3 : 2);					     
							 
localparam FRAC_WIDTH = WIDTH / FRACTURE;

genvar i;
generate
	for (i=0; i<FRACTURE; i=i+1) begin : fl

		//////////////////////////////////////////////////
		// pointers - local to this fracture group

		reg [ADDR_WIDTH-1:0] waddr = {ADDR_WIDTH{1'b0}} /* synthesis preserve */;
		reg [ADDR_WIDTH-1:0] raddr = {ADDR_WIDTH{1'b0}} /* synthesis preserve */;

		always @(posedge clk) begin
			raddr <= raddr + 1'b1;
			waddr <= raddr + LATENCY[ADDR_WIDTH-1:0];
		end

		//////////////////////////////////////////////////
		// storage

		wire [FRAC_WIDTH-1:0] ram_q;
		reg [FRAC_WIDTH-1:0] wdata = {FRAC_WIDTH{1'b0}};

		always @(posedge clk) begin
			wdata <= din[(i+1)*FRAC_WIDTH-1:i*FRAC_WIDTH]; 
		end

		if (TARGET_CHIP == 0) begin : tc0
			// fake MLAB, synthesis not recommended / guaranteed
			s5mlab s5m (
				.wclk(clk),
				.wena(1'b1),
				.waddr_reg(waddr),
				.wdata_reg(wdata),
				.raddr(raddr),
				.rdata(ram_q)		
			);
			defparam s5m .WIDTH = FRAC_WIDTH;
			defparam s5m .ADDR_WIDTH = ADDR_WIDTH;
			defparam s5m .SIM_EMULATE = 1'b1;        
		end
		else if (TARGET_CHIP == 1) begin : tc4
			s4mlab s4m (
				.wclk(clk),
				.wena(1'b1),
				.waddr_reg(waddr),
				.wdata_reg(wdata),
				.raddr(raddr),
				.rdata(ram_q)		
			);
			defparam s4m .WIDTH = FRAC_WIDTH;
			defparam s4m .ADDR_WIDTH = ADDR_WIDTH;
		end
		else if (TARGET_CHIP == 2) begin : tc5
			s5mlab s5m (
				.wclk(clk),
				.wena(1'b1),
				.waddr_reg(waddr),
				.wdata_reg(wdata),
				.raddr(raddr),
				.rdata(ram_q)		
			);
			defparam s5m .WIDTH = FRAC_WIDTH;
			defparam s5m .ADDR_WIDTH = ADDR_WIDTH;
		end
		else if (TARGET_CHIP == 5) begin : tc10
			a10mlab a10m (
				.wclk(clk),
				.wena(1'b1),
				.waddr_reg(waddr),
				.wdata_reg(wdata),
				.raddr(raddr),
				.rdata(ram_q)		
			);
			defparam a10m .WIDTH = FRAC_WIDTH;
			defparam a10m .ADDR_WIDTH = ADDR_WIDTH;
		end
		else begin
			// synthesis translate_off
			initial begin
				$display ("Fatal %m : Unknown target chip");
				$stop();
			end
			// synthesis translate_on
		end

		assign dout[(i+1)*FRAC_WIDTH-1:i*FRAC_WIDTH] = ram_q;
	end
endgenerate

endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 36
// BENCHMARK INFO :  Total pins : 65
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 4               ;       ;
// BENCHMARK INFO :  ALMs : 31 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.345 ns, From fl[0].wdata[16], To s5mlab:fl[0].tc5.s5m|ml[16].lrm~OBSERVABLEPORTADATAINREGOUT0}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.328 ns, From fl[0].wdata[9], To s5mlab:fl[0].tc5.s5m|ml[9].lrm~OBSERVABLEPORTADATAINREGOUT0}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.380 ns, From fl[0].wdata[2], To s5mlab:fl[0].tc5.s5m|ml[2].lrm~OBSERVABLEPORTADATAINREGOUT0}
