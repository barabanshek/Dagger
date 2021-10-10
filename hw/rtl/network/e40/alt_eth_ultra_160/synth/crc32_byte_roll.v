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
// baeckler - 08-14-2012

module crc32_byte_roll #(
	parameter TARGET_CHIP = 2,
	parameter REDUCE_LATENCY = 1'b0
)(
    input clk,
    input [2:0] roll_bytes,
    input [31:0] pc, // previous CRC
    output [31:0] c 
);

reg roll1_r = 1'b0;
reg roll0_r = 1'b0;
reg roll0_rr = 1'b0;
reg roll1_rr = 1'b0;
reg roll0_rrr = 1'b0;
reg roll0_rrrr = 1'b0;

always @(posedge clk) begin
	roll1_r <= roll_bytes[1];
	roll1_rr <= roll1_r;

	roll0_r <= roll_bytes[0];
	roll0_rr <= roll0_r;
	roll0_rrr <= roll0_rr;
	roll0_rrrr <= roll0_rrr;
end

wire [31:0] cr4;
crc32_rev_4 r4 (
    .clk(clk),
    .thru(!roll_bytes[2]),
    .pc(pc), // previous CRC
    .c(cr4) 
);
defparam r4 .TARGET_CHIP = TARGET_CHIP;
defparam r4 .REDUCE_LATENCY = REDUCE_LATENCY;

wire [31:0] cr2;
crc32_rev_2 r2 (
    .clk(clk),
    .thru(REDUCE_LATENCY ? !roll1_r : !roll1_rr),
    .pc(cr4), // previous CRC
    .c(cr2) 
);
defparam r2 .TARGET_CHIP = TARGET_CHIP;
defparam r2 .REDUCE_LATENCY = REDUCE_LATENCY;

crc32_rev_1 r1 (
    .clk(clk),
    .thru(REDUCE_LATENCY ? !roll0_rr : !roll0_rrrr),
    .pc(cr2), // previous CRC
    .c(c) 
);
defparam r1 .TARGET_CHIP = TARGET_CHIP;
defparam r1 .REDUCE_LATENCY = REDUCE_LATENCY;

endmodule

// higher_latency INFO :  5SGXEA7N2F45C2ES
// higher_latency INFO :  Max depth :  2.0 LUTs
// higher_latency INFO :  Combinational ALUTs : 299
// higher_latency INFO :  Memory ALUTs : 0
// higher_latency INFO :  Dedicated logic registers : 457
// higher_latency INFO :  Total block memory bits : 0
// higher_latency INFO :  Worst setup path @ 468.75MHz : 0.897 ns, From crc32_rev_4:r4|thru_r, To crc32_rev_4:r4|xor_2tick_t:x3|xor_r_t:xh|dout_r~DUPLICATE}
// higher_latency INFO :  Worst setup path @ 468.75MHz : 0.969 ns, From crc32_rev_4:r4|xor_2tick_t:x10|xor_r_t:xh|dout_r~DUPLICATE, To crc32_rev_2:r2|xor_2tick_t:x19|xor_r:lp[0].xr|dout_r}
// higher_latency INFO :  Worst setup path @ 468.75MHz : 0.906 ns, From crc32_rev_4:r4|xor_2tick_t:x10|xor_r_t:xh|dout_r, To crc32_rev_2:r2|xor_2tick_t:x29|xor_r:lp[0].xr|dout_r}

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 457
// BENCHMARK INFO :  Total pins : 68
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 320             ;       ;
// BENCHMARK INFO :  ALMs : 202 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.052 ns, From crc32_rev_4:r4|xor_2tick_t:x31|xor_r:lp[2].xr|dout_r, To crc32_rev_4:r4|xor_2tick_t:x31|xor_r_t:xh|dout_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.962 ns, From crc32_rev_4:r4|thru_r, To crc32_rev_4:r4|xor_2tick_t:x4|xor_r_t:xh|dout_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.984 ns, From crc32_rev_2:r2|xor_2tick_t:x5|xor_r_t:xh|dout_r~DUPLICATE, To crc32_rev_1:r1|xor_2tick_t:x14|xor_r:lp[0].xr|dout_r}
