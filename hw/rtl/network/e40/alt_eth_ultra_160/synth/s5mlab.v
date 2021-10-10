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

// baeckler - 01-16-2012

module s5mlab #(
	parameter WIDTH = 20,
	parameter ADDR_WIDTH = 5,
	parameter SIM_EMULATE = 1'b0   // this may not be exactly the same at the fine grain timing level 
)
(
	input wclk,
	input wena,
	input [ADDR_WIDTH-1:0] waddr_reg,
	input [WIDTH-1:0] wdata_reg,
	input [ADDR_WIDTH-1:0] raddr,
	output [WIDTH-1:0] rdata		
);

genvar i;
generate
	if (!SIM_EMULATE) begin
		/////////////////////////////////////////////
		// hardware cells

		for (i=0; i<WIDTH; i=i+1)  begin : ml
			wire wclk_w = wclk;  // workaround strange modelsim warning due to cell model tristate
			stratixv_mlab_cell lrm (
				.clk0(wclk_w),
				.ena0(wena),
				
				// synthesis translate_off
				.clk1(1'b0),
				.ena1(1'b1),
				.ena2(1'b1),
				.clr(1'b0),
				.devclrn(1'b1),
				.devpor(1'b1),
				// synthesis translate_on			

				.portabyteenamasks(1'b1),
				.portadatain(wdata_reg[i]),
				.portaaddr(waddr_reg),
				.portbaddr(raddr),
				.portbdataout(rdata[i])			
				
			);

			defparam lrm .mixed_port_feed_through_mode = "dont_care";
			defparam lrm .logical_ram_name = "lrm";
			defparam lrm .logical_ram_depth = 1 << ADDR_WIDTH;
			defparam lrm .logical_ram_width = WIDTH;
			defparam lrm .first_address = 0;
			defparam lrm .last_address = (1 << ADDR_WIDTH)-1;
			defparam lrm .first_bit_number = i;
			defparam lrm .data_width = 1;
			defparam lrm .address_width = ADDR_WIDTH;
		end
	end
	else begin
		/////////////////////////////////////////////
		// sim equivalent

		localparam NUM_WORDS = (1 << ADDR_WIDTH);
		reg [WIDTH-1:0] storage [0:NUM_WORDS-1];
		integer k = 0;
		initial begin
			for (k=0; k<NUM_WORDS; k=k+1) begin
				storage[k] = 0;
			end
		end

		always @(posedge wclk) begin
			if (wena) storage [waddr_reg] <= wdata_reg;	
		end

		reg [WIDTH-1:0] rdata_b = 0;
		always @(*) begin
			rdata_b = storage[raddr];
		end
		
		assign rdata = rdata_b;
	end
	
endgenerate

endmodule	

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  0.0 LUTs
// BENCHMARK INFO :  Total registers : 0
// BENCHMARK INFO :  Total pins : 52
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 1               ;       ;
// BENCHMARK INFO :  ALMs : 11 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From wclk~inputCLKENA0FMAX_CAP_FF0, To wclk~inputCLKENA0FMAX_CAP_FF1}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From wclk~inputCLKENA0FMAX_CAP_FF0, To wclk~inputCLKENA0FMAX_CAP_FF1}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From wclk~inputCLKENA0FMAX_CAP_FF0, To wclk~inputCLKENA0FMAX_CAP_FF1}
