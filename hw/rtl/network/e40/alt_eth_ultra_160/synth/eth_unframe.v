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


// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/hsl18/eth_unframe.v#1 $
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
// baeckler - 08-21-2012

module eth_unframe #(
	parameter WORDS = 4,
	parameter LATENCY = 2
)(
	input clk,
	input [66*WORDS-1:0] din,
	output [2*WORDS-1:0] dout_frame_lag,
	output [64*WORDS-1:0] dout_data	
);

wire [2*WORDS-1:0] dout_frame;
genvar i;
generate
	for (i=0; i<WORDS; i=i+1) begin : lp
		// split the framing and data bits
		assign 
            {dout_data[(i+1)*64-1:i*64],
             dout_frame[(i+1)*2-1:i*2]} = din[(i+1)*66-1:i*66];
    end
endgenerate	

// delay the framing bits 
delay_regs dr0 (
	.clk(clk),
	.din (dout_frame),
	.dout (dout_frame_lag)
);
defparam dr0 .WIDTH = 2*WORDS;
defparam dr0 .LATENCY = LATENCY;

endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2ES
// BENCHMARK INFO :  Max depth :  0.0 LUTs
// BENCHMARK INFO :  Combinational ALUTs : 0
// BENCHMARK INFO :  Memory ALUTs : 0
// BENCHMARK INFO :  Dedicated logic registers : 16
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.531 ns, From delay_regs:dr0|storage[5], To delay_regs:dr0|storage[13]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.534 ns, From delay_regs:dr0|storage[6], To delay_regs:dr0|storage[14]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.536 ns, From delay_regs:dr0|storage[4], To delay_regs:dr0|storage[12]}
