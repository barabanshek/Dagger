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

// baeckler - 01-15-2009

// Decode  66 bit block from PCS to a MII (8)(64) block 
// Assume the state makes the block reasonable, may
// need to ammend that downstream.

module sim_block_decoder (
	input clk,arst,ena,
        input insert_lblock,	
	input [65:0] rx_block,	// bit 0 received first

	output reg [7:0] mii_rxc,
	output reg [63:0] mii_rxd,	// bit 0 received first
	
	output reg [2:0] behavior_tag		// 1xx error
										// 0 start
										// 1 control
										// 2 terminating
										// 3 data

);

localparam MII_IDLE = 8'h7,			// I
		MII_START = 8'hfb,			// S
		MII_TERMINATE = 8'hfd,		// T
		MII_ERROR = 8'hfe,			// E
		MII_SEQ_ORDERED = 8'h9c,	// Q aka O
		MII_SIG_ORDERED = 8'h5c;	// Fsig aka O

localparam EBLOCK_R = {8'hff,{8{MII_ERROR}}};
localparam LBLOCK_R =  {8'h1, 8'h0, 8'h0, 8'h0, 8'h0, 8'h1, 8'h0, 8'h0, 8'h9c};

		
localparam BLK_CTRL = 8'h1e,
			BLK_START = 8'h78,
			BLK_OS_A = 8'h4b,	// for Q
			BLK_OS_B = 8'h55,	// for Fsig
			BLK_TERM0 = 8'h87,
			BLK_TERM1 = 8'h99,
			BLK_TERM2 = 8'haa,
			BLK_TERM3 = 8'hb4,
			BLK_TERM4 = 8'hcc,
			BLK_TERM5 = 8'hd2,
			BLK_TERM6 = 8'he1,
			BLK_TERM7 = 8'hff;
	
wire type_8c = (rx_block[1:0] == 2'b01) &&
			  (rx_block[9:2] == BLK_CTRL) &&
			  rx_block[65:10] == {8{7'b0}};

wire type_os = (rx_block[1:0] == 2'b01) &&
			  (rx_block[9:2] == BLK_OS_A ||
			   rx_block[9:2] == BLK_OS_B);
			   
wire type_s = (rx_block[1:0] == 2'b01) &&
			  (rx_block[9:2] == BLK_START);

wire type_d = (rx_block[1:0] == 2'b10);

// 00 and 1e are legal 7 bit control chars
wire [7:0] legal_control;
genvar i;
generate
	for (i=0; i<8; i=i+1)
	begin : ctrl
		wire [6:0] tmp_ctrl = rx_block[i*7+16:i*7+10];
		
		// help a little bit with the decomp
		assign legal_control[i] = 
				!tmp_ctrl[6] & !tmp_ctrl[5] & !tmp_ctrl[0] &
				(tmp_ctrl[4:1] == 4'hf || tmp_ctrl[4:1] == 4'h0);
	end
endgenerate

wire [7:0] type_t;
assign type_t[0] = (rx_block[1:0] == 2'b01) &&
				  (rx_block[9:2] == BLK_TERM0) &&
				  (&legal_control[7:1]);
assign type_t[1] = (rx_block[1:0] == 2'b01) &&
				  (rx_block[9:2] == BLK_TERM1) &&
				  (&legal_control[7:2]);
assign type_t[2] = (rx_block[1:0] == 2'b01) &&
				  (rx_block[9:2] == BLK_TERM2) &&
				  (&legal_control[7:3]);
assign type_t[3] = (rx_block[1:0] == 2'b01) &&
				  (rx_block[9:2] == BLK_TERM3) &&
				  (&legal_control[7:4]);
assign type_t[4] = (rx_block[1:0] == 2'b01) &&
				  (rx_block[9:2] == BLK_TERM4) &&
				  (&legal_control[7:5]);
assign type_t[5] = (rx_block[1:0] == 2'b01) &&
				  (rx_block[9:2] == BLK_TERM5) &&
				  (&legal_control[7:6]);
assign type_t[6] = (rx_block[1:0] == 2'b01) &&
				  (rx_block[9:2] == BLK_TERM6) &&
				  legal_control[7];
assign type_t[7] = (rx_block[1:0] == 2'b01) &&
				  (rx_block[9:2] == BLK_TERM7);

///////////////////////////////////////////
// Register checkpoint
	
reg [11:0] next_flags = 0 /* synthesis preserve */;
reg [65:0] next_rx_coded = 0 /* synthesis preserve */;

always @(posedge clk or posedge arst) begin
	if (arst) begin
		next_flags <= 0;
		next_rx_coded <= 0;		
	end	
	else if (ena) begin
		next_flags <= {type_d,type_s,type_8c,type_os,type_t};
		next_rx_coded <= rx_block;	
	end
end

///////////////////////////////////////////

wire next_flags_d,next_flags_s,next_flags_8c,next_flags_os;
wire [7:0] next_flags_t;
assign {next_flags_d,next_flags_s,next_flags_8c,next_flags_os,next_flags_t} =
	next_flags;
//wire next_flags_sorc = next_flags_s | next_flags_8c | next_flags_os;

// unpack error and idle control words from 7 bit format to
// MII format
wire [63:0] decoded_control;
generate
	for (i=0; i<8; i=i+1) 
	begin : unpk
		assign decoded_control[i*8+7:i*8] =
			next_rx_coded [i*7+10+5] ? MII_ERROR : MII_IDLE;		
	end
endgenerate

always @(posedge clk or posedge arst) begin
	if (arst) begin
		behavior_tag <= 3'b100;
		{mii_rxc,mii_rxd} <= LBLOCK_R;		
	end	
	else if (insert_lblock) begin
		behavior_tag <= 3'b100;
		{mii_rxc,mii_rxd} <= LBLOCK_R;		
	end	
	else begin
		if (ena) begin
			// summarize the block for state decisions
			//	 1xx error
			//	 0 start
			//   1 control
			//   2 terminating
			//   3 data
					
			behavior_tag <= 
				next_flags_d ? 3'b011 :					// 3 data
				(|next_flags_t) ? 3'b010 :				// 2 terminating
				(next_flags_8c | next_flags_os) ? 3'b001 : // 1 control
				next_flags_s ? 3'b000 :					// 0 start
				3'b100;									// 1xx error
						
			// assume error as a starting point
			{mii_rxc,mii_rxd} <= EBLOCK_R;
		
			// data
			{mii_rxc,mii_rxd} <= {8'h0,next_rx_coded[65:2]};
		
			if (next_flags_s) begin
				{mii_rxc,mii_rxd} <= {8'h1,next_rx_coded[65:10],MII_START};
			end
			if (next_flags_8c) begin
				{mii_rxc,mii_rxd} <= {8'hff,decoded_control};
			end
			if (next_flags_os) begin
				if (!next_rx_coded[6])
					{mii_rxc,mii_rxd} <= {8'h1,next_rx_coded[65:10],MII_SEQ_ORDERED};
				else
					{mii_rxc,mii_rxd} <= {8'h1,next_rx_coded[65:10],MII_SIG_ORDERED};				
			end
			if (next_flags_t[0]) begin
				{mii_rxc,mii_rxd} <= {8'hff,decoded_control[63:8],MII_TERMINATE};				
			end			
			if (next_flags_t[1]) begin
				{mii_rxc,mii_rxd} <= {8'hfe,decoded_control[63:16],MII_TERMINATE,next_rx_coded[17:10]};				
			end			
			if (next_flags_t[2]) begin
				{mii_rxc,mii_rxd} <= {8'hfc,decoded_control[63:24],MII_TERMINATE,next_rx_coded[25:10]};				
			end						
			if (next_flags_t[3]) begin
				{mii_rxc,mii_rxd} <= {8'hf8,decoded_control[63:32],MII_TERMINATE,next_rx_coded[33:10]};				
			end			
			if (next_flags_t[4]) begin
				{mii_rxc,mii_rxd} <= {8'hf0,decoded_control[63:40],MII_TERMINATE,next_rx_coded[41:10]};				
			end			
			if (next_flags_t[5]) begin
				{mii_rxc,mii_rxd} <= {8'he0,decoded_control[63:48],MII_TERMINATE,next_rx_coded[49:10]};				
			end			
			if (next_flags_t[6]) begin
				{mii_rxc,mii_rxd} <= {8'hc0,decoded_control[63:56],MII_TERMINATE,next_rx_coded[57:10]};				
			end			
			if (next_flags_t[7]) begin
				{mii_rxc,mii_rxd} <= {8'h80,MII_TERMINATE,next_rx_coded[65:10]};				
			end							
		end		
	end
end

endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  4.0 LUTs
// BENCHMARK INFO :  Total registers : 151
// BENCHMARK INFO :  Total pins : 145
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 161             ;       ;
// BENCHMARK INFO :  ALMs : 91 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.719 ns, From next_flags[3], To mii_rxd[38]~reg0}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.639 ns, From next_flags[5], To behavior_tag[1]~reg0}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.615 ns, From next_flags[1], To mii_rxd[20]~reg0}
