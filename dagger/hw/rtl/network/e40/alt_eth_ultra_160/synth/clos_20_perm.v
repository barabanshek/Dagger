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


// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/hsl18/clos_20_perm.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
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

// baeckler - 08-26-2012


// to cut down pins for testing -
// set_instance_assignment -name VIRTUAL_PIN ON -to din
// set_instance_assignment -name VIRTUAL_PIN ON -to dout

module clos_20_perm #(
	parameter WIDTH = 320
)(
	input [WIDTH-1:0] din,
	output [WIDTH-1:0] dout	
);

localparam WORD_WIDTH = WIDTH / 20;

wire [WORD_WIDTH-1:0] w0,w1,w2,w3, w4,w5,w6,w7, w8,w9,wa,wb, wc,wd,we,wf, wg,wh,wi,wj;
assign {w0,w1,w2,w3, w4,w5,w6,w7, w8,w9,wa,wb, wc,wd,we,wf, wg,wh,wi,wj} = din;


assign dout =
	{w0,w4,w8,wc,wg, w1,w5,w9,wd,wh, w2,w6,wa,we,wi, w3,w7,wb,wf,wj};


endmodule


// BENCHMARK INFO :  5SGXEA7N2F45C2ES
// BENCHMARK INFO :  Max depth :  0.0 LUTs
// BENCHMARK INFO :  Combinational ALUTs : 0
// BENCHMARK INFO :  Memory ALUTs : 0
// BENCHMARK INFO :  Dedicated logic registers : 0
// BENCHMARK INFO :  Total block memory bits : 0
