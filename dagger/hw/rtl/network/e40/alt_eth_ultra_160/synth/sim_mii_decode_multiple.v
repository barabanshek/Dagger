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
// Copyright 2009 Altera Corporation. All rights reserved.  
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

// baeckler - 01-16-2009

module sim_mii_decode_multiple #(
	parameter BLOCK_LEN = 66,
	parameter NUM_BLOCKS = 5
)
(
	input clk,arst,ena,
        input rx_fault_en, rx_test_en, hi_ber, align_status,
	input [BLOCK_LEN*NUM_BLOCKS-1:0] rx_blocks, // bit 0 first
	output reg [8*NUM_BLOCKS-1:0] mii_rxc,
	output reg [64*NUM_BLOCKS-1:0] mii_rxd		// bit 0 first	
);

localparam MII_ERROR = 8'hfe;			// E
localparam EBLOCK_R = {8'hff,{8{MII_ERROR}}};
localparam LBLOCK_R =  {8'h1, 8'h0, 8'h0, 8'h0, 8'h0, 8'h1, 8'h0, 8'h0, 8'h9c};


localparam 	RX_C = 2'd0,
			RX_D = 2'd1,
			RX_T = 2'd2,
			RX_E = 2'd3;

// create a decoder for each block

wire [8*NUM_BLOCKS-1:0] rxc;
wire [64*NUM_BLOCKS-1:0] rxd;
wire [3*NUM_BLOCKS-1:0] tag;

reg  insert_lblock;
always @(posedge clk) insert_lblock <= rx_fault_en && (rx_test_en || hi_ber || !align_status);

genvar i;
generate 
	for (i=0; i<NUM_BLOCKS; i=i+1) 
	begin : dec
		// prelim decode of the current block
		sim_block_decoder bd (
			.clk(clk),
			.arst(arst),
			.ena(ena),
                        .insert_lblock(insert_lblock),
			.rx_block(rx_blocks[BLOCK_LEN*i+BLOCK_LEN-1:BLOCK_LEN*i]),
			.mii_rxc(rxc[8*i+7:8*i]),
			.mii_rxd(rxd[64*i+63:64*i]),	
			.behavior_tag(tag[3*i+2:3*i])	
		);				
	end
endgenerate

// stall the prelim decode, we need to look at the
// next block's tag to make state decisions

reg [8*NUM_BLOCKS-1:0] rxc_r,rxc_rr;
reg [64*NUM_BLOCKS-1:0] rxd_r,rxd_rr;
reg [3*NUM_BLOCKS-1:0] tag_r;

always @(posedge clk or posedge arst) begin
	if (arst) begin
		rxc_r <= {NUM_BLOCKS{LBLOCK_R[71:64]}};
		rxd_r <= {NUM_BLOCKS{LBLOCK_R[63:0]}};
		rxc_rr <= {NUM_BLOCKS{LBLOCK_R[71:64]}};
		rxd_rr <= {NUM_BLOCKS{LBLOCK_R[63:0]}};
		tag_r <= 0;
	end
	else if (insert_lblock) begin
		rxc_r <= {NUM_BLOCKS{LBLOCK_R[71:64]}};
		rxd_r <= {NUM_BLOCKS{LBLOCK_R[63:0]}};
		rxc_rr <= {NUM_BLOCKS{LBLOCK_R[71:64]}};
		rxd_rr <= {NUM_BLOCKS{LBLOCK_R[63:0]}};
		tag_r <= 0;
	end
	else if (ena) begin
		rxc_r <= rxc;
		rxd_r <= rxd;
		rxc_rr <= rxc_r;
		rxd_rr <= rxd_r;
		tag_r <= tag;
	end
end
		
wire [2*(NUM_BLOCKS+1)-1:0] state;
wire [NUM_BLOCKS-1:0] next_start_or_control;
wire [NUM_BLOCKS-1:0] revise_to_err_w;
reg [NUM_BLOCKS-1:0] revise_to_err;

always @(posedge clk or posedge arst) begin
	if (arst) revise_to_err <= {NUM_BLOCKS{1'b1}};
	else if (ena) revise_to_err <= revise_to_err_w;
end

generate		
	for (i=0; i<NUM_BLOCKS; i=i+1) 
	begin : st
		
		// look at the tag for the next data block
		// to see if it is start or control type
				
		if (i == (NUM_BLOCKS-1)) begin
			// wrap around into the previous pipe stage			
			assign next_start_or_control[i] = (tag[2:1] == 2'b00);
		end
		else begin
			// grab the i+1 word tag
			assign next_start_or_control[i] = 
				(tag_r[(i+1)*3+2:(i+1)*3+1] == 2'b00);
		end		
										
		// next decode state (pure comb)
		sim_block_decoder_ns ns (
			.state(state[2*i+1:2*i]),
			.next_start_or_control(next_start_or_control[i]),
			.behavior_tag(tag_r[3*i+2:3*i]),
			.next_state(state[2*(i+1)+1:2*(i+1)])	
		);
		
		// ammend the decoding to "error" if there was an
		// otherwise good block that put us in the error
		// state, e.g. start,start
		assign revise_to_err_w [i] = 
			(state[2*(i+1)+1:2*(i+1)] == RX_E);
		
	end
endgenerate

// state registers
reg [1:0] state_reg /* synthesis preserve */;
always @(posedge clk or posedge arst) begin
	if (arst) state_reg <= RX_C;
	else if (ena) begin
		state_reg <= state[2*NUM_BLOCKS+1:2*NUM_BLOCKS];
	end
end
assign state [1:0] = state_reg;

// output registers
generate 
	for (i=0; i<NUM_BLOCKS; i=i+1) 
	begin : oreg
		always @(posedge clk or posedge arst) begin
			if (arst) begin
				{mii_rxc[8*i+7:8*i], mii_rxd[64*i+63:64*i]} <= 
						LBLOCK_R;
			end
			else if (ena) begin
				{mii_rxc[8*i+7:8*i], mii_rxd[64*i+63:64*i]} <= 
					insert_lblock ? LBLOCK_R :
					revise_to_err[i] ? EBLOCK_R :
						{rxc_rr[8*i+7:8*i], rxd_rr[64*i+63:64*i]};		
			end
		end
	end
endgenerate

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  6.0 LUTs
// BENCHMARK INFO :  Total registers : 1858
// BENCHMARK INFO :  Total pins : 697
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 1,244           ;       ;
// BENCHMARK INFO :  ALMs : 1,005 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.142 ns, From tag_r[8], To state_reg[0]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.291 ns, From tag_r[3], To state_reg[0]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.125 ns, From tag_r[1], To state_reg[1]}
