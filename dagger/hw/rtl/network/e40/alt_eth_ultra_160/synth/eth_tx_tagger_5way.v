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
// baeckler - 06-07-2012

module eth_tx_tagger_5way #(
	parameter TARGET_CHIP = 2, 
	parameter VLANE_SET = 1 // 0..3
)(
	input clk,
	input sclr,
	input [65:0] din,
	input am_insert,  // discard the din, insert alignment
	output [65:0] dout
);

// this is cut and paste from the spec table, lanes 0..19
//  for obvious compatability
wire [64*20-1:0] marker_table_raw = {
    8'hc1,8'h68,8'h21,8'h00,8'h3e,8'h97,8'hde,8'h00,    // lane 0
    8'h9d,8'h71,8'h8e,8'h00,8'h62,8'h8e,8'h71,8'h00,
    8'h59,8'h4b,8'he8,8'h00,8'ha6,8'hb4,8'h17,8'h00,
    8'h4d,8'h95,8'h7b,8'h00,8'hb2,8'h6a,8'h84,8'h00,
    8'hf5,8'h07,8'h09,8'h00,8'h0a,8'hf8,8'hf6,8'h00,
    8'hdd,8'h14,8'hc2,8'h00,8'h22,8'heb,8'h3d,8'h00,
    8'h9a,8'h4a,8'h26,8'h00,8'h65,8'hb5,8'hd9,8'h00,
    8'h7b,8'h45,8'h66,8'h00,8'h84,8'hba,8'h99,8'h00,
    8'ha0,8'h24,8'h76,8'h00,8'h5f,8'hdb,8'h89,8'h00,
    8'h68,8'hc9,8'hfb,8'h00,8'h97,8'h36,8'h04,8'h00,
    8'hfd,8'h6c,8'h99,8'h00,8'h02,8'h93,8'h66,8'h00,    // lane 10
    8'hb9,8'h91,8'h55,8'h00,8'h46,8'h6e,8'haa,8'h00,
    8'h5c,8'hb9,8'hb2,8'h00,8'ha3,8'h46,8'h4d,8'h00,
    8'h1a,8'hf8,8'hbd,8'h00,8'he5,8'h07,8'h42,8'h00,
    8'h83,8'hc7,8'hca,8'h00,8'h7c,8'h38,8'h35,8'h00,
    8'h35,8'h36,8'hcd,8'h00,8'hca,8'hc9,8'h32,8'h00,
    8'hc4,8'h31,8'h4c,8'h00,8'h3b,8'hce,8'hb3,8'h00,
    8'had,8'hd6,8'hb7,8'h00,8'h52,8'h29,8'h48,8'h00,
    8'h5f,8'h66,8'h2a,8'h00,8'ha0,8'h99,8'hd5,8'h00,
    8'hc0,8'hf0,8'he5,8'h00,8'h3f,8'h0f,8'h1a,8'h00     // lane 19
};

// Fix it up so lane 0, LSB, 1st to send is in
// position 0.
wire [64*20-1:0] marker_table;
genvar i;
generate
    for (i=0; i<8*20; i=i+1)
    begin : fix
        assign marker_table[(8*20-i)*8-1-:8] = marker_table_raw[(i*8)+7:i*8];
    end
endgenerate

// assemble the desired tags
wire [7:0] bip;
reg [7:0] last_bip = 8'h0;
wire [65:0] vlane_tag;
		
always @(posedge clk) last_bip <= bip;

wire [65:0] vlane_tag_const0 = {marker_table[(VLANE_SET+1)*64-1:VLANE_SET*64],2'b01};
wire [65:0] vlane_tag_const1 = {marker_table[(VLANE_SET+5)*64-1:(VLANE_SET+4)*64],2'b01};
wire [65:0] vlane_tag_const2 = {marker_table[(VLANE_SET+9)*64-1:(VLANE_SET+8)*64],2'b01};
wire [65:0] vlane_tag_const3 = {marker_table[(VLANE_SET+13)*64-1:(VLANE_SET+12)*64],2'b01};
wire [65:0] vlane_tag_const4 = {marker_table[(VLANE_SET+17)*64-1:(VLANE_SET+16)*64],2'b01};

reg [2:0] cntr = 3'b0;
always @(posedge clk) begin
	if (sclr || cntr[2]) cntr <= 3'b0;
	else cntr <= cntr + 1'b1;
end

// mux up all the constants, hopefully maps right  CHECK ME
reg [65:0] vlane_tag_const;
always @(*) begin
	case (cntr) 
		3'd0 : vlane_tag_const = vlane_tag_const0;
		3'd1 : vlane_tag_const = vlane_tag_const1;
		3'd2 : vlane_tag_const = vlane_tag_const2;
		3'd3 : vlane_tag_const = vlane_tag_const3;
		default : vlane_tag_const = vlane_tag_const4;
	endcase		
end

assign vlane_tag = vlane_tag_const | {~last_bip,24'b0,last_bip,24'b0,2'b0};

////////////////////////////////

wire bx_restart;

bip_xor_5way bx (
	.clk(clk),
	.restart(bx_restart),
	.din(din),
	.dout(bip)
);
defparam bx .TARGET_CHIP = TARGET_CHIP;


reg [65:0] din_r = 66'b0 /* synthesis preserve */;
reg [65:0] din_rr = 66'b0 /* synthesis preserve */;
reg [65:0] dout_r = 66'b0 /* synthesis preserve */;
reg am_insert_r = 1'b0 /* synthesis preserve */;
reg am_insert_rr = 1'b0 /* synthesis preserve */;

assign bx_restart = am_insert_r;

always @(posedge clk) begin
	din_r <= din;
	din_rr <= din_r;
	am_insert_r <= am_insert | sclr;
	am_insert_rr <= am_insert_r;
	dout_r <= am_insert_rr ? vlane_tag : din_rr; 
end
assign dout = dout_r;

endmodule


// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 249
// BENCHMARK INFO :  Total pins : 135
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 70              ;       ;
// BENCHMARK INFO :  ALMs : 98 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.955 ns, From cntr[2], To dout_r[18]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.939 ns, From cntr[0], To dout_r[56]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.116 ns, From cntr[2], To dout_r[13]}
