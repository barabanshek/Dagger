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

`timescale 1 ps / 1 ps

// note the JTAG hub signals and parameters will be magically
// updated during compile.

module jtag_shift_reg #(
	parameter   NODE_ID = 8'h33,
	parameter   INSTANCE_ID = 8'h0,
    parameter   SLD_NODE_INFO = {5'h01,NODE_ID[7:0],11'h06E,INSTANCE_ID[7:0]},
                         // node_ver[31:27], node_id[26:19], mfg_id[18:8], inst_id[7:0]
    parameter   SLD_AUTO_INSTANCE_INDEX = "YES",
    parameter   NODE_IR_WIDTH = 1,
    parameter   DAT_WIDTH = 64
)
(
	// Hub sigs
	input       raw_tck,                // raw node clock;
	input       tdi,                    // node data in;
	input       usr1,                   // Indicates that current instruction in the JSM is the USER1 instruction;
	input       clrn,                   // Asynchronous clear;
	input       ena,                    // Indicates that the current instruction in the Hub is for Node
	input       [NODE_IR_WIDTH-1:0] ir_in,  // Node IR;
	output      tdo,                    // Node data out
	output      [NODE_IR_WIDTH-1:0] ir_out, // Node IR capture port
	input       jtag_state_cdr,         // Indicates that the JSM is in the Capture_DR(CDR) state;
	input       jtag_state_sdr,         // Indicates that the JSM is in the Shift_DR(SDR) state;
	input       jtag_state_udr,         // Indicates that the JSM is in the Update_DR(UDR) state;

	// internal sigs
	// data to and from host PC
	input core_clock,
	
	output [DAT_WIDTH-1:0] dat_from_jtag,
	output dat_from_jtag_valid,
	
	input [DAT_WIDTH-1:0] dat_to_jtag,
	input dat_to_jtag_valid,
	output dat_to_jtag_ack
);

assign ir_out = ir_in;

reg [DAT_WIDTH-1:0] sr;
wire dr_select = ena & ~usr1;

reg	[DAT_WIDTH-1:0] dat_from_jtag_i;
reg	dat_from_jtag_valid_i;
wire [DAT_WIDTH-1:0] dat_to_jtag_i;
reg  dat_to_jtag_ack_i;	

/////////////////////////////////////////
// shift out data from FPGA to JTAG host
/////////////////////////////////////////

always @(posedge raw_tck or negedge clrn) begin
	if (!clrn) begin
		sr <= 0;
		dat_to_jtag_ack_i <= 1'b0;
	end
	else begin
		dat_to_jtag_ack_i <= 1'b0;
		if (dr_select) begin
			if (jtag_state_cdr) begin
				sr <= dat_to_jtag_i;
				dat_to_jtag_ack_i <= 1'b1;
			end

			if (jtag_state_sdr) begin
				sr <= {tdi,sr[DAT_WIDTH-1:1]};
			end			
		end
		else begin
			sr[0] <= tdi;
		end		
	end
end
assign tdo = sr[0];

////////////////////////////////////
// grab data from JTAG host to FPGA
////////////////////////////////////

always @(posedge raw_tck or negedge clrn) begin
	if (!clrn) begin
		dat_from_jtag_valid_i <= 1'b0;
		dat_from_jtag_i <= 0;
	end
	else begin
		dat_from_jtag_valid_i <= 1'b0;
		if (dr_select & jtag_state_udr) begin
			dat_from_jtag_i <= sr;
			dat_from_jtag_valid_i <= 1'b1;
		end		
	end
end

////////////////////////////////////
// cross clocks between FPGA to JTAG
////////////////////////////////////
cross_sparse_valid hc0 (
	.din_clk(raw_tck),
	.din_valid(dat_from_jtag_valid_i),
	.din(dat_from_jtag_i),
	
	.dout_clk(core_clock),
	.dout(dat_from_jtag),
	.dout_valid(dat_from_jtag_valid)
);
defparam hc0 .WIDTH = DAT_WIDTH;

wire dat_to_jtag_valid_i;
wire [DAT_WIDTH-1:0] dat_to_jtag_fifo_i;

// don't replay data, black it out if not ready to respond
assign dat_to_jtag_i = dat_to_jtag_valid_i ? dat_to_jtag_fifo_i : {DAT_WIDTH{1'b0}};

cross_handshake hc1 (
	.din_clk(core_clock),
	.din_valid(dat_to_jtag_valid),
	.din(dat_to_jtag),
	.din_ack(dat_to_jtag_ack),
	
	.dout_clk(raw_tck),
	.dout_ack(dat_to_jtag_ack_i),
	.dout(dat_to_jtag_fifo_i),
	.dout_valid(dat_to_jtag_valid_i)	
);
defparam hc1 .WIDTH = DAT_WIDTH;

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  2.0 LUTs
// BENCHMARK INFO :  Total registers : 412
// BENCHMARK INFO :  Total pins : 143
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 19              ;       ;
// BENCHMARK INFO :  ALMs : 126 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.702 ns, From cross_sparse_valid:hc0|launch[53], To cross_sparse_valid:hc0|capture[53]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.608 ns, From cross_sparse_valid:hc0|launch[27], To cross_sparse_valid:hc0|capture[27]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.949 ns, From cross_handshake:hc1|capture_valid, To sr[15]}
