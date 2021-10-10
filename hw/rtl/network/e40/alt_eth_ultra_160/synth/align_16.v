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
module align_16 (
	input clk,
	input [3:0] pos,
	input din_valid,
	input [15:0] din,	// lsbit first
	output reg [15:0] dout  // lsbit first
);

initial dout = 0;
reg [16+15-1:0] mid = 0;

always @(posedge clk) begin
	if (din_valid) begin
		case (pos[3:2]) 
			2'b00 : mid <= {din,mid[30:16]};
			2'b01 : mid <= {4'b0,din,mid[26:16]};
			2'b10 : mid <= {8'h0,din,mid[22:16]};
			2'b11 : mid <= {12'h0,din,mid[18:16]};
		endcase		
	end
end

always @(posedge clk) begin
	case (pos[1:0]) 
		2'b00 : dout <= mid[15:0];
		2'b01 : dout <= mid[16:1];
		2'b10 : dout <= mid[17:2];
		2'b11 : dout <= mid[18:3];
	endcase		
end

endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 47
// BENCHMARK INFO :  Total pins : 38
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 46              ;       ;
// BENCHMARK INFO :  ALMs : 26 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.103 ns, From mid[3], To dout[1]~reg0}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.044 ns, From mid[7], To dout[5]~reg0}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.138 ns, From mid[5], To dout[3]~reg0}
