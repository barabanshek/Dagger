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
// baeckler - 02-21-2012

module compressor_4to3 #(
	parameter TARGET_CHIP = 0
)(
	input clk,
	input [3:0] din,
	output [2:0] sum
);

reg [2:0] sum_r = 3'b0 /* synthesis preserve */;

always @(posedge clk) begin
    case (din)
      4'd0: sum_r <= 3'd0;
      4'd1: sum_r <= 3'd1;
      4'd2: sum_r <= 3'd1;
      4'd3: sum_r <= 3'd2;
      4'd4: sum_r <= 3'd1;
      4'd5: sum_r <= 3'd2;
      4'd6: sum_r <= 3'd2;
      4'd7: sum_r <= 3'd3;
      4'd8: sum_r <= 3'd1;
      4'd9: sum_r <= 3'd2;
      4'd10: sum_r <= 3'd2;
      4'd11: sum_r <= 3'd3;
      4'd12: sum_r <= 3'd2;
      4'd13: sum_r <= 3'd3;
      4'd14: sum_r <= 3'd3;
      4'd15: sum_r <= 3'd4;
      default: sum_r <= 3'd0;
    endcase
end

assign sum = sum_r;

endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 3
// BENCHMARK INFO :  Total pins : 8
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 4               ;       ;
// BENCHMARK INFO :  ALMs : 2 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From clk~inputCLKENA0FMAX_CAP_FF0, To clk~inputCLKENA0FMAX_CAP_FF1}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From clk~inputCLKENA0FMAX_CAP_FF0, To clk~inputCLKENA0FMAX_CAP_FF1}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From clk~inputCLKENA0FMAX_CAP_FF0, To clk~inputCLKENA0FMAX_CAP_FF1}
