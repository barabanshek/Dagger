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

// baeckler 05-23-2012
`timescale 1ps/1ps
// DESCRIPTION
// 
// This is a single lane 40 bit client that is intended for quickly testing SERDES lanes. It has independently
// functioning TX and RX sides. The TX generates a PRBS pattern, intended for LSB first transmission. The
// RX will follow the pattern on a cycle by cycle basis and indicate problems with a small error counter.
// When functioning properly the error count output will stop moving.
// 

// CONFIDENCE
// This has been used successfully in multiple SERDES test designs.
// 

module alt_lfsr_client_40b #(
	parameter SEED = 32'h12345678
)(
	input clk_tx,
	input srst_tx,
	output [39:0] tx_sample, // lsbit first
	
	input clk_rx,
	input srst_rx,
	input [39:0] rx_sample,	 // lsbit first
	output [3:0] err_cnt
);

localparam WIDTH = 40;

// send scrambled 0's
alt_scrambler sc (
	.clk(clk_tx),
	.srst(srst_tx),
	.ena(1'b1),
	.din({WIDTH{1'b0}}),		// bit 0 is to be sent first
	.dout(tx_sample)
);
defparam sc .WIDTH = WIDTH;
defparam sc .SCRAM_INIT = 58'h3ff_ffff_ffff_ffff ^ {SEED[15:0],SEED[31:0]};

wire [WIDTH-1:0] rx_dsc;
alt_descrambler ds (
	.clk(clk_rx),
	.srst(srst_rx),
	.ena(1'b1),
	.din(rx_sample),		// bit 0 is used first
	.dout(rx_dsc)
);
defparam ds .WIDTH = WIDTH;

// when working properly it should descramble to all 0's
wire rx_err;
alt_or_r oo (
	.clk(clk_rx),
	.din(rx_dsc),
	.dout(rx_err)
);
defparam oo .WIDTH = WIDTH;

reg [3:0] err_cnt_r = 4'b0;
always @(posedge clk_rx) begin
	if (srst_rx) err_cnt_r <= 4'b0;
	else err_cnt_r <= err_cnt_r + rx_err;
end
assign err_cnt = err_cnt_r;

endmodule

// BENCHMARK INFO :  10AX115U2F45I2SGE2
// BENCHMARK INFO :  Quartus II 64-Bit Version 15.1.0 Internal Build 58 04/28/2015 SJ Full Version
// BENCHMARK INFO :  Uses helper file :  alt_lfsr_client_40b.v
// BENCHMARK INFO :  Uses helper file :  alt_scrambler.v
// BENCHMARK INFO :  Uses helper file :  alt_descrambler.v
// BENCHMARK INFO :  Uses helper file :  alt_or_r.v
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 291
// BENCHMARK INFO :  Total pins : 88
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :  211                
// BENCHMARK INFO :  ALMs : 129 / 427,200 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : -0.320 ns, From err_cnt_r[1], To err_cnt_r[2]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : -0.571 ns, From err_cnt_r[0], To err_cnt_r[3]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : -0.137 ns, From err_cnt_r[0], To err_cnt_r[2]}
